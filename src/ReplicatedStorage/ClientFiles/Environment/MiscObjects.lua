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
        local newOffset = 0.2*math.sin(2*math.pi*0.4*tick())

        local currentCf = part.CFrame
        local currentPos = currentCf.Position
        local rot = currentCf - currentPos
        local new = CFrame.new(currentPos.X, center + newOffset, currentPos.Z) * rot

        model:SetPrimaryPartCFrame(new)
    end
end

CollectionService:GetInstanceAddedSignal("DroneSign"):Connect(setCenter)
for _, part in ipairs(CollectionService:GetTagged("DroneSign")) do
    setCenter(part)
end

RunService.RenderStepped:Connect(ObjectController.update)

return ObjectController