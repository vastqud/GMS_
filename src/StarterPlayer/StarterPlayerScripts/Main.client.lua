--**Main client module loader & logic handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedUtils = ReplicatedStorage:WaitForChild("SharedUtilities")
local ClientFiles = ReplicatedStorage:WaitForChild("ClientFiles")
local CharUtils = SharedUtils.Utilities.Character
local UiFiles = ClientFiles.UI

local Permissions = require(SharedUtils.Utilities.Permissions)
local Drag = require(ClientFiles.Interaction.Drag) --start click to drag system
local SectorTrack = require(CharUtils.SectorTrack)
local HUDController = require(UiFiles.HUD)
SectorTrack.init()

repeat task.wait() until game:IsLoaded()
task.wait(2)

HUDController.ToggleHud(true)