local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local loadingScreen = ReplicatedFirst.loading
loadingScreen.Parent = PlayerGui
loadingScreen.Enabled = true

ReplicatedFirst:RemoveDefaultLoadingScreen()