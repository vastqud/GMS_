local TweenService = game:GetService("TweenService")

local Doors = {}

local function getPos(primaryPart)
    local model = primaryPart.Parent.Parent
    local offset = model:GetAttribute("Offset")
    local middle = model:WaitForChild("Middle", 1)
    if not middle then return end

    local rightVector = middle.CFrame.RightVector
    local left_pos = middle.Position + (rightVector * offset)
    local right_pos = middle.Position - (rightVector * offset)

    return {Left = left_pos, Right = right_pos, Middle = middle.Position}
end

function Doors.updateState(primaryPart) --update state instantly (door just loaded in)
    local pos = getPos(primaryPart)
    local state = primaryPart.Parent.Parent:GetAttribute("State")
    if not pos then return end

    if not state then --opening
        primaryPart.Attachment.AlignPosition.Position = pos[primaryPart.Parent.Name]
    else --closing
        primaryPart.Attachment.AlignPosition.Position = pos.Middle
    end
end

function Doors.toggle(primaryPart) --tween
    local pos = getPos(primaryPart)
    local state = primaryPart.Parent.Parent:GetAttribute("State")
    if not pos then return end

    if not state then --opening
        local new = pos[primaryPart.Parent.Name]
        TweenService:Create(primaryPart.Attachment.AlignPosition, TweenInfo.new(1), {Position = new}):Play()
    else
        local new = pos.Middle
        TweenService:Create(primaryPart.Attachment.AlignPosition, TweenInfo.new(1), {Position = new}):Play()
    end
end

return Doors