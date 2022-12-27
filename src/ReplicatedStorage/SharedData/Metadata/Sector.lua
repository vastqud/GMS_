local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("GlobalConstants")
local TypeToInstanceMap = require(Globals.TypeToInstanceMap)

local SECTOR_INSTANCES = workspace:FindFirstChild("SectorBounds")
local SECTOR_CONFIG_TEMPLATE = { --defaults
    Protected = true
}

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

local function fill_data(name, model)
    for dataField, defaultValue in pairs(SECTOR_CONFIG_TEMPLATE) do
        if not model.Configuration:FindFirstChild(dataField) then
            local newVal = Instance.new(TypeToInstanceMap[typeof(defaultValue)])
            newVal.Name = dataField
            newVal.Value = defaultValue
        end

        Sectors.SectorData[name][dataField] = model.Configuration:FindFirstChild(dataField).Value
    end
end

function Sectors.GetAllSectorBounds()
    local output = {}

    for _, sector_bound_parts in ipairs(SECTOR_INSTANCES:GetChildren()) do
        for _, part in ipairs(sector_bound_parts:GetChildren()) do
            table.insert(output, part)
        end
    end

    return output
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

return Sectors