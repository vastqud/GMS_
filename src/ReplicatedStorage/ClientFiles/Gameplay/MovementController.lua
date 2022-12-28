local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UIFiles = ReplicatedStorage.ClientFiles.UI
local HUDController = require(UIFiles.HUD)

local Player = Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()
local sprinting = false
local cam = workspace.CurrentCamera

local MovementController = {}
MovementController.SprintBound = false
MovementController.MaximumStamina = 100
MovementController.StaminaDrain = 5 --units/s
MovementController.StaminaGain = 2
MovementController.StaminaGainDelay = 3 --s
MovementController.Stamina = MovementController.MaximumStamina

local stopped_sprint_time = tick()

local function handleSprint(on)
	if not char then return end
	if not char:FindFirstChild("Humanoid") then return end
	if not char.PrimaryPart then return end
	local hum = char.Humanoid

	if on then
		if char.PrimaryPart.Velocity.Magnitude <= 5 then return end
		if hum.SeatPart then return end
		if sprinting then return end
        if MovementController.Stamina <= 0 then return end

		sprinting = true
		hum.WalkSpeed = 19.75
		TweenService:Create(cam, TweenInfo.new(0.35), {FieldOfView = 75}):Play()
	else
		if not sprinting then return end

		sprinting = false
		hum.WalkSpeed = 14
        stopped_sprint_time = tick()
		TweenService:Create(cam, TweenInfo.new(0.35), {FieldOfView = 70}):Play()
	end
end

local function update_stamina(dt)
    local updated_raw = MovementController.Stamina --no change by default

    if sprinting then
        updated_raw = MovementController.Stamina - (MovementController.StaminaDrain * dt)

        if updated_raw <= 0 then handleSprint(false) end
    else
        if (tick() - stopped_sprint_time) >= MovementController.StaminaGainDelay then
            updated_raw = MovementController.Stamina + (MovementController.StaminaGain * dt)
        end
    end

    MovementController.Stamina = math.clamp(updated_raw, 0, MovementController.MaximumStamina)
    HUDController.UpdateVitalsBar("Stamina", MovementController.Stamina, MovementController.MaximumStamina)
end

local function processSprint(_, state, _)
    if state == Enum.UserInputState.Begin then
        handleSprint(true)
    elseif state == Enum.UserInputState.End then
        handleSprint(false)
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

Player.CharacterAdded:Connect(function(chara)
    char = chara
end)
RunService.Heartbeat:Connect(update_stamina)

return MovementController