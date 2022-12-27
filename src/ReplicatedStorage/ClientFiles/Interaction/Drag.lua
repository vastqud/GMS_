local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SharedData = ReplicatedStorage.SharedData
local SharedUtilities = ReplicatedStorage.SharedUtilities
local GlobalTags = require(SharedData.GlobalConstants.Tags)
local Constants = require(SharedData.GlobalConstants.Constants)
local AttachmentsLib = require(SharedUtilities.Libraries.Attachments)
local Permissions = require(SharedUtilities.Utilities.Permissions)

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local Drag = {}
Drag.Dragging = false
Drag.UpdateConnection = nil

local function createPhysicsMoverAtPoint(object, point) --creates the alignposition on the object
    if object:FindFirstChild("DragMover") then return end

    local newAtt = Instance.new("Attachment")
    local newMover = Instance.new("AlignPosition")
    
    newAtt.Position = AttachmentsLib.getAttPosFromWorldPos(object.Position, point)
    newMover.ApplyAtCenterOfMass = false
    newMover.Mode = Enum.PositionAlignmentMode.OneAttachment
    newMover.RigidityEnabled = true

    newMover.Parent = newAtt; newAtt.Name = "DragMover"; newAtt.Parent = object
end

function Drag.queryRaycast() --queries mouse position
    local loc = UserInputService:GetMouseLocation()
    local mouseX, mouseY = loc.X, loc.Y
    local unitRay = Camera:ScreenPointToRay(mouseX, mouseY)
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction*Constants.DragDistance, raycastParams)

    if raycastResult then
        return raycastResult.Instance, raycastResult.Position
    else --raycast operation did not hit anything, so just return the end point of the ray
        return nil, unitRay.Origin + unitRay.Direction * Constants.DragDistance
    end
end

function Drag.initiateDrag() --checks if the mouse is over a draggable object when clicked
    if Drag.Dragging then return Enum.ContextActionResult.Pass end

    local objectClicked, position = Drag.queryRaycast()

    if (not objectClicked) or (not CollectionService:HasTag(objectClicked, GlobalTags.GlobalInteract)) then --not interactable or raycast didnt hit anything
        return Enum.ContextActionResult.Pass
    elseif objectClicked and CollectionService:HasTag(objectClicked, GlobalTags.GlobalInteract) then --object is interactable
        if not objectClicked:GetAttribute(GlobalTags.Draggable) then --not a draggable object
            return Enum.ContextActionResult.Pass
        elseif not Permissions:IsPlayerAuthorizedWith(Player, objectClicked, Permissions.Enums.Drag) then --is draggable, but player does not have permission to do so
            return Enum.ContextActionResult.Pass
        end
    end

    createPhysicsMoverAtPoint(objectClicked, position)
    Drag.Dragging = objectClicked
end

function Drag.endDrag()
    if not Drag.Dragging then return Enum.ContextActionResult.Pass end

    if Drag.UpdateConnection then
        Drag.UpdateConnection:Disconnect(); Drag.UpdateConnection = nil
    end
    if Drag.Dragging:FindFirstChild("DragMover") then
        Drag.Dragging.DragMover:Destroy()
    end

    Drag.Dragging = false
end

function Drag.processEvent(_, state, _)
    if state == Enum.UserInputState.Begin then
        Drag.initiateDrag()
    elseif state == Enum.UserInputState.End then
        Drag.endDrag()
    end
end

function Drag.bind(bind)
    if bind then
        ContextActionService:BindAction("ClickToDrag", Drag.processEvent, false, Enum.UserInputType.MouseButton1)
        Drag.UpdateConnection = RunService.Heartbeat:Connect(Drag.update)
    else
        ContextActionService:UnbindAction("ClickToDrag")
        Drag.endDrag()
    end
end

function Drag.update(dt)
    if not Drag.Dragging then return end

    local _, mousePos = Drag.queryRaycast()
    Drag.Dragging.DragMover.AlignPosition.Position = mousePos
end

do
    if Player.Character then
        raycastParams.FilterDescendantsInstances = {Player.Character}
    end

    Player.CharacterAdded:Connect(function(char)
        raycastParams.FilterDescendantsInstances = {char}
    end)

    ContextActionService:BindAction("EndDrag", Drag.processEvent, false, Enum.UserInputType.MouseButton1) --this should always be bound, so it is not bound on Drag.bind
    Drag.bind(true) --initialize module
end

return Drag