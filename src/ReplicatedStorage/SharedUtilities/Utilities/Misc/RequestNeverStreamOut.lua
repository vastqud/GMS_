local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RunService:IsServer()
local STREAM_BUFFER = ReplicatedStorage:WaitForChild("STREAM_BUFFER")
local REQUEST_REMOTE = ReplicatedStorage.Network.Functions.NeverStreamRequest
local GET_DESCENDANTS = ReplicatedStorage.Network.Functions.RequestDescendants
local FINISHED_REMOTE = ReplicatedStorage.Network.Events.NeverStreamFinished
local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)

local YieldModelLoad
do
    if not IS_SERVER then
        YieldModelLoad = require(ReplicatedStorage.ClientFiles.Gameplay.YieldModelLoad)
    end
end

local NeverStreamOut = {}
NeverStreamOut.Enums = {
    ValidModelTag = Enums.new("PersistentModel", {})
}

function NeverStreamOut.RequestFromClient(model)
    if not model then return end

    if STREAM_BUFFER:FindFirstChild(model.Name) then
        local desc = GET_DESCENDANTS:InvokeServer(model)

        if desc then
            return YieldModelLoad(model, desc)
        end
    end

    local status, modelName, descendants = REQUEST_REMOTE:InvokeServer(model)

    if status then
        local model = STREAM_BUFFER:WaitForChild(modelName, 3)

        if model then
            return YieldModelLoad(model, descendants)
        end
    end
end

function NeverStreamOut.FinishedClient(modelName)
    FINISHED_REMOTE:FireServer(modelName)
end

function NeverStreamOut.ProcessRequestServer(player, model)
    if not IS_SERVER then return end

    if not model then return end
    if not typeof(model) == "Instance" then return end
    if not CollectionService:HasTag(model, NeverStreamOut.Enums.ValidModelTag.Name) then return end

    if STREAM_BUFFER:FindFirstChild(model.Name) then
        return true, model.Name, #STREAM_BUFFER:FindFirstChild(model.Name):GetDescendants()
    end

    local clone = model:Clone(); clone.Parent = STREAM_BUFFER

    return true, clone.Name, #clone:GetDescendants()
end

function NeverStreamOut.ReturnDescendants(player, model)
    if not IS_SERVER then return end
    if not CollectionService:HasTag(model, NeverStreamOut.Enums.ValidModelTag.Name) then return end

    return #model:GetDescendants()
end

do
    if IS_SERVER then
        REQUEST_REMOTE.OnServerInvoke = NeverStreamOut.ProcessRequestServer
        GET_DESCENDANTS.OnServerInvoke = NeverStreamOut.ReturnDescendants
        FINISHED_REMOTE.OnServerEvent:Connect(function(player, name)
            if STREAM_BUFFER:FindFirstChild(name) then
                --STREAM_BUFFER:FindFirstChild(name):Destroy()
            end
        end)
    end
end

return NeverStreamOut