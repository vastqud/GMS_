local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UIFiles = ReplicatedStorage.ClientFiles.UI
local GlobalConstants = ReplicatedStorage.SharedData.GlobalConstants
local HUDController = require(UIFiles.HUD)
local Constants = require(GlobalConstants.Constants)
local MathExtended = require(ReplicatedStorage.SharedUtilities.Libraries.Math)
local ControlModule = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
local FastFlags = require(ReplicatedStorage.SharedData.GlobalConstants.FastFlags)
local OTS = require(ReplicatedStorage.ClientFiles.Gameplay.OTSCamera)

local Player = Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid"); hum.WalkSpeed = 0
local sprinting = false
local cam = workspace.CurrentCamera

do
    --[[local animateScript = char:WaitForChild("Animate")
    local walk = animateScript:WaitForChild("walk")
    local run = animateScript:WaitForChild("run")

    walk.WalkAnim:Destroy()
    run.RunAnim:Destroy()

    local newAnimWalk = Instance.new("Animation")
    local newAnimRun = Instance.new("Animation")

    newAnimWalk.AnimationId = "http://www.roblox.com/asset/?id=913402848"
    newAnimRun.AnimationId = "http://www.roblox.com/asset/?id=913376220"
    newAnimRun:SetAttribute("LinearVelocity", Vector2.new(0, 12.8))
    newAnimWalk:SetAttribute("LinearVelocity", Vector2.new(0, 6.4))

    newAnimWalk.Parent = walk; newAnimRun.Parent = run]]
    OTS:Enable()
end

local WALKSPEED_TARGET = 0
local FOV_TARGET = 70

local MovementController = {}
MovementController.SprintBound = false
MovementController.MaximumStamina = Constants.DefaultMaxStamina
MovementController.StaminaDrain = Constants.StaminaDrain --units/s
MovementController.StaminaGain = Constants.StaminaGain
MovementController.StaminaGainDelay = Constants.StaminaGainDelay --s
MovementController.Stamina = MovementController.MaximumStamina
MovementController.Zoomed = false

local stopped_sprint_time = tick()

local function handleSprint(on)
	if not char then return end
	if not hum then return end
	if not char.PrimaryPart then return end

	if on then
		if hum.SeatPart then return end
		if sprinting then return end
        if MovementController.Stamina <= 0 then return end
        if ControlModule:GetMoveVector().Magnitude < 0.3 then return end

		sprinting = true
	else
		if not sprinting then return end

		sprinting = false
        stopped_sprint_time = tick()
	end
end

local function updateWalkspeed(dt)
    if not FastFlags.WalkSpeed_Lerp then
        hum.WalkSpeed = 13 
        return
    end

    local moveVector = ControlModule:GetMoveVector()

    if moveVector.Magnitude >= 0.3 then
        WALKSPEED_TARGET = sprinting and Constants.SprintWalkspeed or Constants.DefaultWalkspeed
    else
        WALKSPEED_TARGET = 0
    end

    hum.WalkSpeed = MathExtended.lerp(hum.WalkSpeed, WALKSPEED_TARGET, dt*4)
end

local function calculateFov()
    local base = sprinting and 75 or 70
    FOV_TARGET = MovementController.Zoomed and base-33.5 or base
end

local function update(dt)
    if not hum then return end

    updateWalkspeed(dt)
    calculateFov()
    local updated_raw = MovementController.Stamina --no change by default

    if sprinting then
        if ControlModule:GetMoveVector().Magnitude < 0.3 then handleSprint(false) end
        updated_raw = MovementController.Stamina - (MovementController.StaminaDrain * dt)

        if updated_raw <= 0 then handleSprint(false) end
    else
        if (tick() - stopped_sprint_time) >= MovementController.StaminaGainDelay then
            updated_raw = MovementController.Stamina + (MovementController.StaminaGain * dt)
        end
    end

    MovementController.Stamina = math.clamp(updated_raw, 0, MovementController.MaximumStamina)
    HUDController.UpdateVitalsBar("Stamina", MovementController.Stamina, MovementController.MaximumStamina)
    cam.FieldOfView = MathExtended.lerp(cam.FieldOfView, FOV_TARGET, dt*9)
end

local function processSprint(_, state, _)
    if state == Enum.UserInputState.Begin then
        handleSprint(true)
    elseif state == Enum.UserInputState.End then
        handleSprint(false)
    end
end

local function processMouseZoom(_, state, _)
    if state == Enum.UserInputState.Begin then
        MovementController.Zoomed = true
    elseif state == Enum.UserInputState.End then
        MovementController.Zoomed = false
    end
end

function MovementController.EnableSprint(on)    
    if on then
        if not MovementController.SprintBound then
            MovementController.SprintBound = true
            ContextActionService:BindAction("Sprint", processSprint, false, Enum.KeyCode.LeftShift)
        end
    else
        if MovementController.SprintBound then
            MovementController.SprintBound = false
            ContextActionService:UnbindAction("Sprint")
        end
    end
end

function MovementController.EnableMouseZoom(on)
    if on then
        ContextActionService:BindAction("MouseZoom", processMouseZoom, false, Enum.UserInputType.MouseButton2)
    else
        ContextActionService:UnbindAction("MouseZoom")
    end
end


local function enableWeapon(_, state)
    if state ~= Enum.UserInputState.Begin then return end
    OTS:SetWeaponMode(not OTS.WeaponMode)
end

local shoulder = 1
local function setShoulder(_, state)
    if state ~= Enum.UserInputState.Begin then return end
    shoulder = shoulder == 1 and -1 or 1
    OTS:SetShoulder(shoulder)
end

Player.CharacterAdded:Connect(function(chara)
    char = chara
    hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 0

    if not OTS.Enabled then
        OTS:Enable()
    end
end)
RunService.Heartbeat:Connect(update)
ContextActionService:BindAction("EnableWeapon", enableWeapon, false, Enum.KeyCode.G)
ContextActionService:BindAction("shoulder", setShoulder, false, Enum.KeyCode.F)

return MovementController