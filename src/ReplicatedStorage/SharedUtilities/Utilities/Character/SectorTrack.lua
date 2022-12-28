local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local IS_SERVER = RunService:IsServer()
local UP = Vector3.new(0, 1, 0)

local Metadata = ReplicatedStorage.SharedData.Metadata
local CharacterUtils = ReplicatedStorage.SharedUtilities.Utilities.Character
local ClientFiles = ReplicatedStorage.ClientFiles
local VerifyCharacterExists = require(CharacterUtils.VerifyCharacterExists)
local SectorData = require(Metadata.Sector)
local HudController

do
    if not IS_SERVER then
        HudController = require(ClientFiles.UI.HUD)
    end
end

SectorData.init()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.IgnoreWater = true
raycastParams.FilterDescendantsInstances = SectorData.GetAllSectorBounds()

local SectorTrack = {}
SectorTrack.ServerPollRate = 0.5 --hz
SectorTrack.ClientPollRate = 1 --hz

local last_sector = nil

function SectorTrack.QueryPlayerSector(player, callback)
    local root = VerifyCharacterExists(player)
    if root then
        local raycastResult = workspace:Raycast(root.CFrame.Position, UP*600, raycastParams)
        if raycastResult and raycastResult.Instance then
            local sector = raycastResult.Instance.Parent.Name
            pcall(callback, sector)

            last_sector = sector
        end
    end
end

function SectorTrack.Poll()
    if IS_SERVER then
        for _, player in ipairs(Players:GetPlayers()) do
            SectorTrack.QueryPlayerSector(player, function(newSector)
                player:SetAttribute("Sector", newSector)
            end)
        end
    else
        SectorTrack.QueryPlayerSector(Players.LocalPlayer, function(newSector)
            if newSector ~= last_sector then
                HudController.ChangeSector(newSector, SectorData.GetSectorData(newSector))
            end
        end)
    end
end

function SectorTrack.init()
    local elapsed = 100
    local pollRate = IS_SERVER and SectorTrack.ServerPollRate or SectorTrack.ClientPollRate

    RunService.Stepped:Connect(function(dt)
        elapsed += dt
        if (elapsed < pollRate) then return end
        elapsed = 0
    
        SectorTrack.Poll()
    end)
end

return SectorTrack

