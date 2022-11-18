local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Libraries = ReplicatedStorage.SharedUtilities.Libraries
local TableUtil = require(Libraries.Table)

local IsServer = RunService:IsServer()
local PermissionReplication = ReplicatedStorage.Network.Events.UpdatePermissions

local Permissions = {}
Permissions.Enums = require(script.PermissionEnums)
Permissions.Players = {}

Permissions.ListTemplate = {
    Interact = false,
    Drag = false,
    Visit = true,
    Sit = false,
    Drive = false
}

--[[
    Permissions.Players = {
        [437437] = { --master
            [37284] = { --slave (this player's permissions with master)
                Interact = false,
                Drag = false,
                Visit = true,
                Sit = false,
                Drive = false --player 37284 CANNOT drive player 437437's vehicles
            }
        },
        [37284] = { --master
            [437437] = { --slave (this player's permissions with master)
                Interact = false,
                Drag = false,
                Visit = true,
                Sit = false,
                Drive = true --player 437437 CAN drive player 37284's vehicles
            }
        }
    }
]]

--[[
    For interactable models (with ProxPrompts like machines):
    Create ProximityPrompts on the client when the interact CollectionService tag is added to a model.
    When the interact tag is added, each client will call :IsPlayerAuthorizedWith for that model (with action Interact). If true, add the ProxPrompt.

    When a player's permissions are updated, get all interactable objects belonging to the player whose permissions they were updated for.
    Loop through those objects and call :IsPlayerAuthorizedWith again. If true, add (or do nothing) the ProxPrompt. If false, remove it if one exists.
    
    Only worry about ProxPrompts if the object is NOT draggable. Draggable objects will have a Draggable attribute.
]]

local function clearPlayerFromPermissionsList(player)
    if Permissions.Players[player.UserId] then
        Permissions.Players[player.UserId] = nil
    end

    for otherPlayerUid, slaves in pairs(Permissions.Players) do
        for uid, _ in pairs(slaves) do
            if uid == player.UserId then
                Permissions.Players[otherPlayerUid][player.UserId] = nil
            end
        end
    end
end

local function updatePermissionLocal(...)
    Permissions:UpdatePermissionForPlayer(...)
end

function Permissions:IsPlayerAuthorizedWith(player, object, action): boolean
    local owner = object:GetAttribute("Owner")
    if not owner then return true end --owned by the server

    if Permissions:ComparePlayerPermissions(owner, player, action) then --there is an owner, so check if the player has the correct permission for this action
        return true
    end

    return false
end

function Permissions:ComparePlayerPermissions(owner, player, action): boolean
    local listForPlayer
    if Permissions.Players[owner.UserId] then
        listForPlayer = Permissions.Players[owner.UserId][player.UserId] or Permissions.ListTemplate
    else
        listForPlayer = Permissions.ListTemplate
    end

    return listForPlayer[action.Name]
end

function Permissions:UpdatePermissionForPlayer(master, slave, action, newVal)
    if not Permissions.Players[master.UserId] then Permissions.Players[master.UserId] = {} end
    if not Permissions.Players[master.UserId][slave.UserId] then
        Permissions.Players[master.UserId][slave.UserId] = TableUtil.deepCopy(Permissions.ListTemplate)
    end

    local permissionList = Permissions.Players[master.UserId][slave.UserId]
    permissionList[action.Name] = newVal

    if IsServer then
        PermissionReplication:FireAllClients(master, slave, action, newVal)
    end
end

Players.PlayerRemoving:Connect(clearPlayerFromPermissionsList)
PermissionReplication.OnClientEvent:Connect(updatePermissionLocal)

return Permissions