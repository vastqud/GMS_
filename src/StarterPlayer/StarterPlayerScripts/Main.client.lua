--**Main client module loader & logic handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedUtils = ReplicatedStorage:WaitForChild("SharedUtilities")
local ClientFiles = ReplicatedStorage:WaitForChild("ClientFiles")
local CharUtils = SharedUtils.Utilities.Character

local Permissions = require(SharedUtils.Utilities.Permissions)
local Drag = require(ClientFiles.Interaction.Drag) --start click to drag system
local SectorTrack = require(CharUtils.SectorTrack)
SectorTrack.init()