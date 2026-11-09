--!strict

-- Constants shared by the server progress rules and the client message display.
-- Shared modules are visible to clients, so keep only values that are safe to publish.

local CourseConfig = {
	-- Pad00 is the entrance; Pad01-Pad20 are the route markers in order.
	finishPad = 20,
	-- Pad10 is the single earned checkpoint (checkpoint 1).
	checkpointPad = 10,
	-- Studs below the current safe landing at which a fall is recovered.
	failDepth = 20,
	-- Highest plausible speed in studs per second on any axis, excluding falling.
	maxSpeed = 70,
	-- Seconds during which landings are ignored after a respawn or implausible movement.
	landingGrace = 0.5,
	remoteName = "ObbyProgress",
	messages = {
		checkpoint = "Checkpoint saved for this session.",
		finish = "Tower complete.",
		recoveredEntrance = "Back at the entrance.",
		recoveredCheckpoint = "Back at the checkpoint.",
	},
}

function CourseConfig.padName(index: number): string
	return string.format("Pad%02d", index)
end

return CourseConfig
