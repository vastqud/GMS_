local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)
local Doors = require(script.Doors)

local ObjectController = {}

local function setCenter(part)
    part.Parent:SetAttribute("Center", part.Position.Y)
end

local function controlDoor(doorModel)
    Doors.toggle(doorModel.Left.PrimaryPart)
    Doors.toggle(doorModel.Right.PrimaryPart)
end

function ObjectController.update(dt)
    for _, part in ipairs(CollectionService:GetTagged("DroneSign")) do
        local model = part.Parent
        local center = model:GetAttribute("Center")
        local newOffset = 0.4*math.sin(2*math.pi*0.4*tick())

        local currentCf = part.CFrame
        local currentPos = currentCf.Position
        local rot = currentCf - currentPos
        local new = CFrame.new(currentPos.X, center + newOffset, currentPos.Z) * rot

        model:SetPrimaryPartCFrame(new)
    end
end

CollectionService:GetInstanceAddedSignal("DroneSign"):Connect(setCenter)
CollectionService:GetInstanceAddedSignal("SlidingDoor"):Connect(Doors.updateState)
for _, part in ipairs(CollectionService:GetTagged("DroneSign")) do
    setCenter(part)
end
for _, part in ipairs(CollectionService:GetTagged("SlidingDoor")) do
    Doors.updateState(part)
end

RunService.RenderStepped:Connect(ObjectController.update)
ReplicatedStorage.Network.Events.Door.OnClientEvent:Connect(controlDoor)

task.spawn(function()
    local door = workspace.SlidingDoor1
    while true do
        wait(10)
        door:SetAttribute("State", not door:GetAttribute("State"))
        print("moving")
        controlDoor(door)
    end
end)

return ObjectController