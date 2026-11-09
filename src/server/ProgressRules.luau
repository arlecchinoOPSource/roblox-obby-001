--!strict

-- Pure per-session progress rules. No Roblox instances are used, so the same
-- logic can be exercised from any script. The server owns every transition.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CourseConfig = require(ReplicatedStorage.ObbyShared.CourseConfig)

export type State = {
	-- Highest route marker (pad index) earned this session. 0 is the entrance.
	progress: number,
	-- Pad index of the earned checkpoint: 0 for the entrance, otherwise the checkpoint pad.
	checkpoint: number,
	-- True once a valid finish has been recorded for this session.
	completed: boolean,
}

export type LandResult = "advanced" | "checkpoint" | "finished" | "ignored"

local ProgressRules = {}

function ProgressRules.new(): State
	return {
		progress = 0,
		checkpoint = 0,
		completed = false,
	}
end

-- Applies a grounded landing on `pad`. Only the next marker in order advances progress.
-- Repeats, lower pads, and skipped markers are ignored, and a finish is recorded once.
function ProgressRules.land(state: State, pad: number): LandResult
	if pad ~= state.progress + 1 then
		return "ignored"
	end

	state.progress = pad

	if pad == CourseConfig.checkpointPad then
		state.checkpoint = pad
		return "checkpoint"
	end

	if pad == CourseConfig.finishPad and not state.completed then
		state.completed = true
		return "finished"
	end

	return "advanced"
end

-- Resets intermediate route markers to the earned checkpoint and returns the pad to respawn on.
-- Death, reset, and falls all use this, so the earned checkpoint is always kept.
function ProgressRules.recover(state: State): number
	state.progress = state.checkpoint
	return state.checkpoint
end

return ProgressRules
