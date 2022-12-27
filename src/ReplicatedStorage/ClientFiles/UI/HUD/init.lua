local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SectorAnimation = require(script.SectorAnimation)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local HudController = {}
HudController.HUD = PlayerGui:FindFirstChild("HUD")

function HudController.ToggleHud(on) --on should be true or false (otherwise it will be !enabled)
    if not HudController.HUD then HudController.HUD = PlayerGui:WaitForChild("HUD") end

    if (on == true) or (on == false) then
        HudController.HUD.Enabled = on
    else
        HudController.HUD.Enabled = not HudController.HUD.Enabled
    end
end

function HudController.ChangeSector(newSectorName, newSectorData)
    local sectorUi = HudController.HUD.Master.Sector
    task.spawn(SectorAnimation, newSectorName, newSectorData, sectorUi)
end

HudController.ToggleHud(false) --toggle hud off initially

return HudController