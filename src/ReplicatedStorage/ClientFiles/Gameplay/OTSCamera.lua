local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local ViewportSize = Cam.ViewportSize

local WaistC0

game.Workspace.Retargeting = Enum.AnimatorRetargetingMode.Disabled

local OTS = {}
OTS.Enabled = false
OTS.WeaponMode = false

OTS.CurrentShoulder = 1
OTS.Aimed = false

OTS.Settings = {
    Default = {
        ShoulderOffset = Vector3.new(2.5, 2.5, 10)
    },
    WeaponMode = {
        ShoulderOffset = Vector3.new(2.2, 1.95, 5.5)
    },
    Aimed = {
        ShoulderOffset = Vector3.new(1.75, 2.5, 5)
    }
}

OTS.XAngle = 0
OTS.YAngle = 0
OTS.Sensitivity = 10

local function getCharacter()
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    return char
end

function OTS:Update(dt)
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    Cam.CameraType = Enum.CameraType.Scriptable

    local char = getCharacter(); if not char then return end
    local root = char.HumanoidRootPart
    char.Humanoid.AutoRotate = not OTS.WeaponMode

    local delta = UserInputService:GetMouseDelta() * OTS.Sensitivity
    OTS.YAngle -= delta.X / ViewportSize.X
    OTS.XAngle -= delta.Y / ViewportSize.Y
    OTS.XAngle = math.clamp(OTS.XAngle, -math.pi/2, math.pi/2)

    local offset = OTS.WeaponMode and OTS.Settings.WeaponMode.ShoulderOffset or OTS.Settings.Default.ShoulderOffset
    offset = offset * Vector3.new(OTS.CurrentShoulder, 1, 1)
    
    local newCf = CFrame.new(root.Position) * CFrame.Angles(0, OTS.YAngle, 0) * CFrame.Angles(OTS.XAngle, 0, 0) * CFrame.new(offset)
    newCf = Cam.CFrame:Lerp(newCf, 0.75)

    local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(root.Position, newCf.Position - root.Position, raycastParams)

	if raycastResult then
        local dont = false
        if raycastResult.Instance.Transparency then
            if raycastResult.Instance.Transparency > 0 then
                dont = true
            end
        end

        if not dont then
            local vector = raycastResult.Position - root.Position
            local newPos = root.Position + (vector.Unit * (vector.Magnitude - 0.05))
            local rot = newCf - newCf.Position
            newCf = CFrame.new(newPos) * rot
        end
	end

    local rot = root.CFrame - root.CFrame.Position
    local newRootCf = CFrame.new(root.Position) * (rot:Lerp(CFrame.Angles(0, self.YAngle, 0), 0.5))
    if OTS.WeaponMode then
        root.CFrame = newRootCf--root.CFrame:Lerp(newRootCf, 0.4)

        local waist = char.UpperTorso.Waist
        local angle = CFrame.Angles(OTS.XAngle, 0, 0)

        waist.C0 = waist.C0:Lerp(WaistC0 * angle, 0.85)
    end

    Cam.CFrame = newCf
end

function OTS:SetWeaponMode(on)
    OTS.WeaponMode = on

    if not on then
        local char = Player.Character
        local waist = char.UpperTorso.Waist
        waist.C0 = WaistC0
    end
end

function OTS:SetShoulder(val)
    OTS.CurrentShoulder = val
end

function OTS:Enable()
    OTS.Enabled = true

    RunService:BindToRenderStep("CamUpdate", Enum.RenderPriority.Camera.Value - 1, function(dt)
        if OTS.Enabled then
            OTS:Update(dt)
        end
    end)

    local waist = Player.Character:WaitForChild("UpperTorso").Waist
    WaistC0 = waist.C0
end

function OTS:Disable()
    OTS.Enabled = false

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    RunService:UnbindFromRenderStep("CamUpdate")
end

return OTS