local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Doors = {}
Doors.List = {}

local function registerDoor(part)
    local parent = part.Parent.Parent
    if not Doors.List[parent] then
        Doors.List[parent] = parent:GetAttributeChangedSignal("State"):Connect(function()
            Doors.TweenDoor(parent.Left.PrimaryPart)
            Doors.TweenDoor(parent.Right.PrimaryPart)
        end)
    end
end

local function setDoorLight(model, on)
    local mat = on and Enum.Material.Neon or Enum.Material.Foil
    local light1 = model:FindFirstChild("DoorLight")
    local light2 = model:FindFirstChild("DoorLight2")

    if light1 then
        light1.Material = mat
    end
    if light2 then
        light2.Material = mat
    end
end

function Doors.TweenDoor(pp)
    if not pp then return end
    local model = pp.Parent.Parent
    local state = model:GetAttribute("State")
    local middle = model:FindFirstChild("Middle")
    if not middle then return end

    local side = (pp.Parent.Name == "Left") and 1 or -1
    local offset = model:GetAttribute("Offset")
    local cf = pp.CFrame
    local rot = cf - pp.CFrame.Position
    local right = cf.RightVector
    local pos = (state) and middle.Position or middle.Position + right * offset * side
    local newcf = CFrame.new(pos) * rot

    TweenService:Create(pp, TweenInfo.new(1), {CFrame = newcf}):Play()
    setDoorLight(model, true)
    task.delay(1, setDoorLight, model, false)
end

do
    for _, door in ipairs(CollectionService:GetTagged("SlidingDoor")) do
        Doors.TweenDoor(door)
        registerDoor(door)
    end
end

CollectionService:GetInstanceAddedSignal("SlidingDoor"):Connect(function(part)
    Doors.TweenDoor(pp)
    registerDoor(part)
end)

return Doors