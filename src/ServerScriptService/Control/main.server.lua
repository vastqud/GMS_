local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerModules = ServerScriptService.Game.Player
local SharedUtils = ReplicatedStorage.SharedUtilities
local CharUtils = SharedUtils.Utilities.Character
local SectorTrack = require(CharUtils.SectorTrack)
local FastFlags = require(ReplicatedStorage.SharedData.GlobalConstants.FastFlags)
SectorTrack.init()

local function PlayerAdded(player)
    player:SetAttribute("Armor", 75)
end

for _, player in ipairs(Players:GetPlayers()) do
    PlayerAdded(player)
end
Players.PlayerAdded:Connect(PlayerAdded)

do
    if FastFlags.Health_Debug then
        ReplicatedStorage.Network.Events.Health_Debug.OnServerEvent:Connect(function(player, dir)
            player.Character.Humanoid:TakeDamage(9*dir)
        end)
    end
end