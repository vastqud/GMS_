local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)

local Items = {}
Items.Enums = {
    FluidType = Enums.new("Fluid", {}),
    ObjectType = Enums.new("Object", {}),
    PowerType = Enums.new("Power", {})
}

function Items:GetNameFromId(id)
    if Items.ItemMap[id] then
        return Items.ItemMap[id].Name
    end
    return
end

function Items:GetItemField(id, field)
    if (not id) or (not field) then return end
    if not Items:GetNameFromId(id) then return end

    if Items.ItemMap[id][field] then
        return Items.ItemMap[id][field]
    end
end

Items.ItemMap = {
    ["iron"] = {
        Name = "Iron",
        ItemType = Items.Enums.ObjectType
    },
    ["oxygen"] = {
        Name = "Oxygen",
        ItemType = Items.Enums.FluidType
    },
    ["iron_oxide"] = {
        Name = "Iron Oxide",
        ItemType = Items.Enums.ObjectType
    }
}

return Items