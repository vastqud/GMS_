local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)

local ObjectController = {}

local function setCenter(part)
    part.Parent:SetAttribute("Center", part.Position.Y)
end

function ObjectController.update(dt)
    for _, part in ipairs(CollectionService:GetTagged("DroneSign")) do
        local model = part.Parent
        local center = model:GetAttribute("Center")
        local newOffset = math.sin(2*math.pi*0.8*tick())
        local currentCf = part.CFrame

        model:SetPrimaryPartCFrame(currentCf * CFrame.new(0, newOffset, 0))
    end
end

CollectionService:GetInstanceAddedSignal("DroneSign"):Connect(setCenter)
for _, part in ipairs(CollectionService:GetTagged("DroneSign")) do
    setCenter(part)
end

RunService.RenderStepped:Connect(ObjectController.update)

return ObjectController