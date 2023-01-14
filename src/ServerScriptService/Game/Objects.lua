local CollectionService = game:GetService("CollectionService")

local Objects = {}
Objects.Doors = {}

local function find(list, part)
    for _, obj in ipairs(list) do
        if obj == part then
            return true
        end
    end
end

local function registerDoor(part)
    local parent = part.Parent.Parent
    if Objects.Doors[parent] then return end

    local hitbox = parent.Hitbox.Part
    Objects.Doors[parent] = {Inside = {}}

    hitbox.Touched:Connect(function(part)
        if part.Name == "HumanoidRootPart" and part.Parent:FindFirstChild("Humanoid") then
            if find(Objects.Doors[parent].Inside, part) then return end
            table.insert(Objects.Doors[parent].Inside, part)
            parent:SetAttribute("State", false)
        end
    end)
    hitbox.TouchEnded:Connect(function(part)
        if part.Name == "HumanoidRootPart" and part.Parent:FindFirstChild("Humanoid") then
            for index, thisPart in ipairs(Objects.Doors[parent].Inside) do
                if part == thisPart then
                    table.remove(Objects.Doors[parent].Inside, index)
                    break
                end
            end

            if #Objects.Doors[parent].Inside == 0 then
                parent:SetAttribute("State", true)
            end
        end
    end)
end

do
    for _, part in ipairs(CollectionService:GetTagged("SlidingDoor")) do
        registerDoor(part)
    end
end

return Objects