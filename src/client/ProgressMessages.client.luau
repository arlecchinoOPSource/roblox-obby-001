--!strict

-- Presentation only. The server decides progress; this script shows the messages it sends.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("ObbyShared")
local CourseConfig = require(shared:WaitForChild("CourseConfig") :: ModuleScript) :: any
local remote = ReplicatedStorage:WaitForChild(CourseConfig.remoteName) :: RemoteEvent

local MESSAGE_SECONDS = 3

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ObbyProgress"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = playerGui

-- Top centre keeps the bottom corners free for touch movement and jump controls.
local label = Instance.new("TextLabel")
label.Name = "Message"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0, 16)
label.Size = UDim2.fromOffset(320, 44)
label.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
label.BackgroundTransparency = 0.15
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.TextWrapped = true
label.Visible = false
label.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = label

local latest = 0

remote.OnClientEvent:Connect(function(text: unknown)
	if typeof(text) ~= "string" then
		return
	end

	latest += 1
	local mine = latest
	label.Text = text
	label.Visible = true

	task.delay(MESSAGE_SECONDS, function()
		if latest == mine then
			label.Visible = false
		end
	end)
end)
