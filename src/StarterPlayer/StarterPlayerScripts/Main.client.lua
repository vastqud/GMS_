--**Main client module loader & logic handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local SharedUtils = ReplicatedStorage:WaitForChild("SharedUtilities")
local ClientFiles = ReplicatedStorage:WaitForChild("ClientFiles")
local CharUtils = SharedUtils.Utilities.Character
local UiFiles = ClientFiles.UI

local Permissions = require(SharedUtils.Utilities.Permissions)
local Drag = require(ClientFiles.Interaction.Drag) --start click to drag system
local SectorTrack = require(CharUtils.SectorTrack)
local HUDController = require(UiFiles.HUD)
local MovementController = require(ClientFiles.Gameplay.MovementController)
local YieldModelLoad = require(ClientFiles.Gameplay.YieldModelLoad)
local AtmosphereController = require(ClientFiles.Environment.Atmosphere)
local MiscObjects = require(ClientFiles.Environment.MiscObjects)

local function init()
    SectorTrack.init() --yields quite a bit
    AtmosphereController.init() --also yields
    require(ClientFiles.Environment.Battles).init() --yields
    HUDController.ToggleHud(true)
    MovementController.EnableSprint(true)
    MovementController.EnableMouseZoom(true)
end

local function removeLoadingScreen()
    local loadingScreen = PlayerGui:WaitForChild("loading")
    task.wait(1)
    loadingScreen:Destroy()
end

local function loadBlocking()
    local plotLoaded = false
    local loadingScreen = PlayerGui:WaitForChild("loading")

    local function loadPlot(model, desc)
        local model = YieldModelLoad(model, desc, 10)
        if model then
            ReplicatedStorage.Network.Events.LoadPlotClient:FireServer()
            plotLoaded = true
        end
    end

    loadingScreen.Frame.TextLabel.Text = "Loading Game"
    repeat task.wait() until game:IsLoaded()
    task.wait(2)

    loadingScreen.Frame.TextLabel.Text = "Loading Modules"
    init()
    ReplicatedStorage.Network.Events.LoadPlotClient.OnClientEvent:Connect(loadPlot)

    loadingScreen.Frame.TextLabel.Text = "Loading Refinery"
    repeat task.wait(0.05) until plotLoaded == true
    removeLoadingScreen()
end

loadBlocking()

