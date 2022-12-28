local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local HUD = PlayerGui:WaitForChild("HUD")
local nav = HUD:WaitForChild("Master"):WaitForChild("Compass")
local northVector = Vector3.new(0, 0, 1)

local char = Player.Character or Player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera
local increment = 1.944444444
local points = {}

local function getDetAndDot(between, x_axis_relative)
	local dot = between.X * x_axis_relative.X + between.Y * x_axis_relative.Y
	local det = between.X * x_axis_relative.Y - between.Y * x_axis_relative.X

	return det, dot
end

local function getAngleFromVector3(vector)
	local v1 = Vector2.new(-vector.X, vector.Z)
	local v2 = Vector2.new(northVector.X, northVector.Z)
	local det, dot = getDetAndDot(v1, v2)
	
	return math.deg(math.atan2(det, dot))
end

RunService.Heartbeat:Connect(function()
	local camangle = getAngleFromVector3(cam.CFrame.LookVector)

	local pixel = (camangle * increment) + 175
	nav.compass.scroll.Position = UDim2.new(0, pixel, 0, 0)
end)

Player.CharacterAdded:Connect(function(character)
	char = character
	root = character:WaitForChild("HumanoidRootPart")
end)