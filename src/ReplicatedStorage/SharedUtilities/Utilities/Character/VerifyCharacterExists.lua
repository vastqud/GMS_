local function VerifyCharacterExists(player)
    if typeof(player) == "Instance" then
        if player.Character then
            local char = player.Character

            if char:IsDescendantOf(workspace) and char:FindFirstChild("Humanoid") then
                if char:FindFirstChild("HumanoidRootPart") then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root:IsDescendantOf(workspace) then
                        return root
                    end
                end
            end
        end
    end
end

return VerifyCharacterExists