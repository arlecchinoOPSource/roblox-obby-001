--!strict

-- Server-owned course progress. Landings, checkpoints, recovery and the finish are decided
-- here from the character's server-side state. Clients only receive display messages and
-- cannot report or authorize progress.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CourseConfig = require(ReplicatedStorage.ObbyShared.CourseConfig)
local ProgressRules = require(script.Parent.ProgressRules)

local SPEED_SAMPLE_SECONDS = 0.25
local LANDING_RAY_LENGTH = 8
local LANDING_MARGIN = 2
local RESPAWN_HEIGHT = 3.5

local tower = Workspace:WaitForChild("Tower", 10)
if not tower then
	warn("[Obby 001][Progress] Workspace.Tower is missing; progress is disabled")
	return
end

local remote = Instance.new("RemoteEvent")
remote.Name = CourseConfig.remoteName
remote.Parent = ReplicatedStorage

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { tower }

type Session = {
	player: Player,
	state: ProgressRules.State,
	lastPosition: Vector3?,
	lastSampleTime: number,
	ignoreLandingsUntil: number,
}

local sessions: { [Player]: Session } = {}

local function getPad(index: number): BasePart?
	local pad = tower:FindFirstChild(CourseConfig.padName(index))
	if pad and pad:IsA("BasePart") then
		return pad
	end
	return nil
end

local function padIndexOf(instance: Instance): number?
	local digits = string.match(instance.Name, "^Pad(%d%d)$")
	if digits and instance.Parent == tower then
		return tonumber(digits)
	end
	return nil
end

local function padTop(pad: BasePart): number
	return pad.Position.Y + pad.Size.Y / 2
end

local function publish(session: Session)
	-- Read-only mirrors of server state, useful for display and for tests.
	session.player:SetAttribute("ObbyPad", session.state.progress)
	session.player:SetAttribute("ObbyCheckpoint", session.state.checkpoint)
	session.player:SetAttribute("ObbyCompleted", session.state.completed)
end

local function placeOnPad(character: Model, index: number)
	local pad = getPad(index)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not pad or not root or not root:IsA("BasePart") then
		return
	end

	local pivot = character:GetPivot()
	local facing = pivot - pivot.Position
	local target = Vector3.new(pad.Position.X, padTop(pad) + RESPAWN_HEIGHT, pad.Position.Z)
	character:PivotTo(CFrame.new(target) * facing)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function recover(session: Session, character: Model, notify: boolean)
	local padIndex = ProgressRules.recover(session.state)
	placeOnPad(character, padIndex)
	session.lastPosition = nil
	session.ignoreLandingsUntil = os.clock() + CourseConfig.landingGrace
	publish(session)

	if notify then
		if padIndex == 0 then
			remote:FireClient(session.player, CourseConfig.messages.recoveredEntrance)
		else
			remote:FireClient(session.player, CourseConfig.messages.recoveredCheckpoint)
		end
	end
end

local function onCharacterAdded(session: Session, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end

	session.lastPosition = nil
	session.ignoreLandingsUntil = os.clock() + CourseConfig.landingGrace

	-- A fresh session already spawns on the entrance SpawnLocation. After death or reset,
	-- return to the earned checkpoint and clear intermediate route markers.
	if session.state.progress > 0 or session.state.checkpoint > 0 then
		recover(session, character, false)
	end
end

local function step(session: Session, now: number)
	local character = session.player.Character
	if not character then
		session.lastPosition = nil
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		session.lastPosition = nil
		return
	end

	local position = root.Position

	-- Sample movement at a fixed interval. Network updates arrive in bursts, so per-frame
	-- deltas would look faster than they are. Implausibly fast movement pauses landings.
	local elapsed = now - session.lastSampleTime
	if session.lastPosition == nil then
		session.lastPosition = position
		session.lastSampleTime = now
	elseif elapsed >= SPEED_SAMPLE_SECONDS then
		local delta = position - session.lastPosition
		local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude / elapsed
		local rising = delta.Y / elapsed
		if horizontal > CourseConfig.maxSpeed or rising > CourseConfig.maxSpeed then
			session.ignoreLandingsUntil = now + CourseConfig.landingGrace
		end
		session.lastPosition = position
		session.lastSampleTime = now
	end

	-- Fall recovery: once per fall, because the character is moved above the boundary.
	local safePad = getPad(session.state.progress)
	if safePad and position.Y < padTop(safePad) - CourseConfig.failDepth then
		recover(session, character, true)
		return
	end

	-- Landing: grounded, standing on a numbered pad, and past any grace period.
	if now < session.ignoreLandingsUntil or humanoid.FloorMaterial == Enum.Material.Air then
		return
	end

	local hit = Workspace:Raycast(position, Vector3.new(0, -LANDING_RAY_LENGTH, 0), rayParams)
	if not hit then
		return
	end

	local pad = padIndexOf(hit.Instance)
	if not pad then
		return
	end

	local offset = position - hit.Instance.Position
	local halfSize = hit.Instance.Size / 2
	if math.abs(offset.X) > halfSize.X + LANDING_MARGIN or math.abs(offset.Z) > halfSize.Z + LANDING_MARGIN then
		return
	end

	local result = ProgressRules.land(session.state, pad)
	if result == "ignored" then
		return
	end

	publish(session)
	if result == "checkpoint" then
		remote:FireClient(session.player, CourseConfig.messages.checkpoint)
	elseif result == "finished" then
		remote:FireClient(session.player, CourseConfig.messages.finish)
	end
end

local function onPlayerAdded(player: Player)
	local session: Session = {
		player = player,
		state = ProgressRules.new(),
		lastPosition = nil,
		lastSampleTime = os.clock(),
		ignoreLandingsUntil = 0,
	}
	sessions[player] = session
	publish(session)

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(session, character)
	end)

	local existing = player.Character
	if existing then
		task.spawn(onCharacterAdded, session, existing)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	sessions[player] = nil
end)

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, session in sessions do
		step(session, now)
	end
end)
