local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Customize = {}

function Customize.RemovePackages(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		error("Character has no humanoid.")
	end
	
	local descriptionClone = humanoid:GetAppliedDescription()
	descriptionClone.Head = 0
	descriptionClone.LeftArm = 0
	descriptionClone.RightArm = 0
	descriptionClone.LeftLeg = 0
	descriptionClone.RightLeg = 0
	descriptionClone.Torso = 0

    if not humanoid:IsDescendantOf(workspace) then
		repeat wait(0.5) until humanoid:IsDescendantOf(workspace)
	end
	humanoid:ApplyDescription(descriptionClone)
end

function Customize.SetScaling(char)
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

	local desc = hum:GetAppliedDescription()

	desc.BodyTypeScale = 0
	desc.DepthScale = 1
	desc.HeadScale = 1
	desc.HeightScale = 1.1
	desc.ProportionScale = 0
	desc.WidthScale = 1

	if not hum:IsDescendantOf(workspace) then
		repeat wait(0.5) until hum:IsDescendantOf(workspace)
	end
	hum:ApplyDescription(desc)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAppearanceLoaded:Connect(function()
        local char = player.Character

        Customize.RemovePackages(char)
        Customize.SetScaling(char)
    end)
end)

return Customize