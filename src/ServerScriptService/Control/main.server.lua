local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local SharedUtils = ReplicatedStorage.SharedUtilities
local CharUtils = SharedUtils.Utilities.Character
local SectorTrack = require(CharUtils.SectorTrack)
local FastFlags = require(ReplicatedStorage.SharedData.GlobalConstants.FastFlags)
local Plots = require(ServerScriptService.Game.PlotHandler)
SectorTrack.init()

local function PlayerAdded(player)
    player:SetAttribute("Armor", 75)

    local plot = Plots.new(player)
    plot:Load()

    player.CharacterAdded:Connect(function()
        plot:TeleportOwnerBlocking()
    end)
end

local function PlayerRemoved(player)
    Plots.remove(player)
end

local function returnGameTime(player)
    return workspace.DistributedGameTime
end

local function returnRegion(player)
    local url = "http://ip-api.com/json/"
    
    local getasyncinfo = HttpService:GetAsync(url) 
    local decodedinfo = HttpService:JSONDecode(getasyncinfo) 

    if not decodedinfo then return "N/A" end

    local regionName = decodedinfo.regionName or "N/A"
    local city = decodedinfo.city or "N/A"
    
    return city .. ", " .. regionName
end

for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoved)

do
    if FastFlags.Health_Debug then
        ReplicatedStorage.Network.Events.Health_Debug.OnServerEvent:Connect(function(player, dir)
            player.Character.Humanoid:TakeDamage(9*dir)
        end)
    end
end

ReplicatedStorage.Network.Functions.GetGameTime.OnServerInvoke = returnGameTime
ReplicatedStorage.Network.Functions.GetRegion.OnServerInvoke = returnRegion