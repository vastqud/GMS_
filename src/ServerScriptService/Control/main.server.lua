local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerModules = ServerScriptService.Game.Player
local SharedUtils = ReplicatedStorage.SharedUtilities
local CharUtils = SharedUtils.Utilities.Character
local SectorTrack = require(CharUtils.SectorTrack)
SectorTrack.init()