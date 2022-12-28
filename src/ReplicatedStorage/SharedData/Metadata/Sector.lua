local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Globals = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("GlobalConstants")
local Utils = ReplicatedStorage.SharedUtilities.Libraries
local TypeToInstanceMap = require(Globals.TypeToInstanceMap)
local Enums = require(Utils.Enums)

local SECTOR_INSTANCES = workspace:FindFirstChild("SectorBounds")
local SECTOR_CONFIG_TEMPLATE = { --defaults
    Protected = true
}

local updated_bind = Instance.new("BindableEvent")

local Sectors = {}
Sectors.SectorData = {
    Basilisk = {},
    Kobra = {},
    Chimera = {},
    Phoenix = {},
    Cerberus = {},
    Griffin = {},
    Manticore = {},
    Hydra = {},
    Strix = {},
    Nessus = {},
    Orion = {}
}
Sectors.AllSectorBounds = {}
Sectors.Enums = {
    SectorBoundPartTag = Enums.new("SectorBound", {})
}
Sectors.SectorBoundsUpdated = updated_bind.Event

local function fill_data(name, model)
    for dataField, defaultValue in pairs(SECTOR_CONFIG_TEMPLATE) do
        if not model.Configuration:FindFirstChild(dataField) then
            local newVal = Instance.new(TypeToInstanceMap[typeof(defaultValue)])
            newVal.Name = dataField
            newVal.Value = defaultValue
        end

        Sectors.SectorData[name][dataField] = model.Configuration:FindFirstChild(dataField).Value
    end

    for _, obj in ipairs(model:GetChildren()) do
        if obj:IsA("BasePart") then
            table.insert(Sectors.AllSectorBounds, obj)
        end
    end
end

function Sectors.GetSectorData(name)
    return Sectors.SectorData[name]
end

function Sectors.init()
    for name, _ in pairs(Sectors.SectorData) do
        if SECTOR_INSTANCES:FindFirstChild(name) then
            fill_data(name, SECTOR_INSTANCES:FindFirstChild(name))
        else
            Sectors.SectorData[name] = nil
        end
    end
end

CollectionService:GetInstanceAddedSignal(Sectors.Enums.SectorBoundPartTag.Name):Connect(function(part)
    local alreadyFound = false
    for _, thisPart in ipairs(Sectors.AllSectorBounds) do
        if thisPart == part then
            alreadyFound = true
        end
    end

    if not alreadyFound then
        table.insert(Sectors.AllSectorBounds, part)
        updated_bind:Fire()
    end
end)

CollectionService:GetInstanceRemovedSignal(Sectors.Enums.SectorBoundPartTag.Name):Connect(function(part)
    for index, thisPart in ipairs(Sectors.AllSectorBounds) do
        if thisPart == part then
            table.remove(Sectors.AllSectorBounds, index)
            updated_bind:Fire()
        end
    end
end)

return Sectors