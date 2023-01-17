--wait(2)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera
local VerifyCharacterExists = require(ReplicatedStorage.SharedUtilities.Utilities.Character.VerifyCharacterExists)

local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")
local Torso = Character:WaitForChild("UpperTorso")
local Neck = Head:FindFirstChild("Neck")
local Waist = Torso:FindFirstChild("Waist")

local NeckOriginC0 = Neck.C0
local WaistOriginC0 = Waist.C0
local Remote = ReplicatedStorage.Network.Events.ReplicateJoints
local Camera = workspace.CurrentCamera
local HitPoints = {}

Neck.MaxVelocity = 1/3

local function resetToDefaults(char)
	Neck.C0 = NeckOriginC0
	Waist.C0 = WaistOriginC0
end

local function updateJoints(Character, player)
	local Head = Character:FindFirstChild("Head")
	local Neck = Head:FindFirstChild("Neck")
	
	local Torso = Character:FindFirstChild("UpperTorso")
	local Waist = Torso:FindFirstChild("Waist")
	
	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

	if Humanoid.Sit then resetToDefaults(Character) return end
	
	if Character:FindFirstChild("UpperTorso") and Character:FindFirstChild("Head") then
		local TorsoLookVector = Torso.CFrame.lookVector
		local HeadPosition = Head.CFrame.p
		
		if Neck and Waist then
			local Point
			if player == Player then
				Point = HumanoidRootPart.CFrame.Position + Camera.CFrame.LookVector*10
				Remote:FireServer(Point)
			else
				Point = HitPoints[player.UserId]
			end
			if not Point then return end
				
			local Distance = (Head.CFrame.p - Point).magnitude
			local Difference = Head.CFrame.Y - Point.Y

			Neck.C0 = Neck.C0:lerp(NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.2), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.4, 0), 0.5 / 2)
			--Waist.C0 = Waist.C0:lerp(WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.3), 0, 0), 0.5 / 2)
		end
	end	
end

RunService.RenderStepped:Connect(function() 
	for _, player in ipairs(Players:GetPlayers()) do
		local char = VerifyCharacterExists(player)
		if char then
			updateJoints(char.Parent, player)
		end
	end
end)

Remote.OnClientEvent:Connect(function(player, point)
	HitPoints[player.UserId] = point
end)

Players.PlayerRemoving:Connect(function(player)
	HitPoints[player.UserId] = nil
end)