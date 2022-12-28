local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VerifyCharacterExists = require(ReplicatedStorage.SharedUtilities.Utilities.Character.VerifyCharacterExists)
local VitalsRender = require(script.VitalsRender)
local SectorAnimation = require(script.SectorAnimation)
local LeaderboardHandler = require(script.Leaderboard)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Char

local HudController = {}
HudController.HUD = PlayerGui:WaitForChild("HUD")

local function characterAdded(char)
    Char = char

    local hum = Char:WaitForChild("Humanoid")
    hum.HealthChanged:Connect(function()
        VitalsRender.updateVitalsBar("Health", hum.Health)
    end)
    VitalsRender.updateVitalsBar("Health", hum.Health)
    VitalsRender.updateVitalsBar("Armor", Player:GetAttribute("Armor"))
end

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

    Player.CharacterAdded:Connect(characterAdded)
    Player:GetAttributeChangedSignal("Armor"):Connect(function()
        VitalsRender.updateVitalsBar("Armor", Player:GetAttribute("Armor"))
    end)
end

HudController.ToggleHud(false) --toggle hud off initially
HudController.InitConnections()
LeaderboardHandler.init(HudController.HUD.Master.Leaderboard)
VitalsRender.init(HudController.HUD.Master.Vitals)
ContextActionService:BindAction("ToggleLeaderboard", HudController.ToggleLeaderboard, false, Enum.KeyCode.Tab)

do
    if Player.Character then
        characterAdded(Player.Character)
    end
end

return HudController