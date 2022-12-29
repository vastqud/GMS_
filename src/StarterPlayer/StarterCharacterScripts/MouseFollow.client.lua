wait(2)

local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local Camera = workspace.CurrentCamera

local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")
local Neck = Head:WaitForChild("Neck")

local Torso = Character:WaitForChild("UpperTorso")
local Waist = Torso:WaitForChild("Waist")

local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local NeckOriginC0 = Neck.C0
local WaistOriginC0 = Waist.C0

Neck.MaxVelocity = 1/3

local humSit = false
local function resetToDefaults()
	if not humSit then
		Neck.C0 = NeckOriginC0
		Waist.C0 = WaistOriginC0
		humSit = true
	end
end

RunService.RenderStepped:Connect(function() 
	if Humanoid.Sit then resetToDefaults() return end
	humSit = false
	local CameraCFrame = Camera.CoordinateFrame
	
	if Character:FindFirstChild("UpperTorso") and Character:FindFirstChild("Head") then
		local TorsoLookVector = Torso.CFrame.lookVector
		local HeadPosition = Head.CFrame.p
		
		if Neck and Waist then
			if Camera.CameraSubject:IsDescendantOf(Character) or Camera.CameraSubject:IsDescendantOf(Player) then
				local Point = PlayerMouse.Hit.p
				
				local Distance = (Head.CFrame.p - Point).magnitude
				local Difference = Head.CFrame.Y - Point.Y

				Neck.C0 = Neck.C0:lerp(NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.3), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.7, 0), 0.5 / 2)
				Waist.C0 = Waist.C0:lerp(WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.45), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.4, 0), 0.5 / 2)
			end
		end
	end	
end)