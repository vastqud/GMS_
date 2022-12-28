local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local SectorAnimation = require(script.SectorAnimation)
local LeaderboardHandler = require(script.Leaderboard)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local HudController = {}
HudController.HUD = PlayerGui:WaitForChild("HUD")

function HudController.ToggleHud(on) --on should be true or false (otherwise it will be !enabled)
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

function HudController.ToggleLeaderboard(on, state) --on should be true or false (otherwise it will be !enabled)
    if (state) and (state ~= Enum.UserInputState.Begin) then return end

    if not ((on == true) or (on == false)) then
        on = not LeaderboardHandler.Enabled
    end

    if on then
        LeaderboardHandler.Enable()
    else
        LeaderboardHandler.Close()
    end
end

function HudController.InitConnections()
    local arrow = HudController.HUD.Master.Leaderboard.Header.Arrow

    arrow.ImageButton.MouseButton1Click:Connect(function()
        HudController.ToggleLeaderboard()
    end)
end

HudController.ToggleHud(false) --toggle hud off initially
HudController.InitConnections()
LeaderboardHandler.init(HudController.HUD.Master.Leaderboard)
ContextActionService:BindAction("ToggleLeaderboard", HudController.ToggleLeaderboard, false, Enum.KeyCode.Tab)

return HudController