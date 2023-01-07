local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(script.Parent.Parent.Machine.MachineEnums)
local ItemEnums = require(ReplicatedStorage.SharedData.Metadata.Items).Enums

local MolecularReassembler = {
    InputOutputMap = { --main input processed with secondary input yields output in time ticks
        {Main = "iron", Secondary = "oxygen", Output = "iron_oxide", Time = 200}
    },
    InputChannels = {--item type, capacity, specific items table (if applicable), channel priority
        {ItemEnums.PowerType, 5000, nil, Enums.PowerChannel},
        {ItemEnums.FluidType, 5000, {Whitelist = {"Oxygen", "Water"}}, Enums.Secondary},
        {ItemEnums.ObjectType, 1, nil, Enums.Main}
    },
    OutputChannels = { --capacity
        {Enums.Unlimited}
    }
}

return MolecularReassembler