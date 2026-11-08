--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	local SmokeTest = require(ReplicatedStorage.ObbyShared.SmokeTest)
	print("[Obby 001][Server]", SmokeTest.message)
end
