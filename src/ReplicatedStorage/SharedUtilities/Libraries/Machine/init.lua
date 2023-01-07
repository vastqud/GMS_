local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Machines = {}
local Enums = require(script.MachineEnums)
local InputChannel = require(script.InputChannels)
do
    for _, obj in ipairs(script.Parent.Machines:GetChildren()) do
        Machines[obj.Name] = require(obj)
    end
end

local function softProcessCheck(item, outputMap)
    for _, entry in ipairs(outputMap) do
        if (entry.Main == item.Name) or (entry.Secondary == item.Name) then
            return true
        end
    end
end

local Machine = {}
Machine.prototype = {}

function Machine.new(name)
    local self = {}
    setmetatable(self, {__index = Machine.prototype})

    self.MachineData = Machines[name]

    self.Connections = {}

    self.InputChannels = {}
    self.OutputChannels = {}
    self.InputBuffer = {}

    self:Setup()

    return self
end

function Machine.prototype:Update()
    --go through main channels, check if there's a process that matches items in secondary channels
    --if so, check if there's an available output channel
    --increase main channel tick number
    --once that gets to max val for the process, end and consume secondary resources and power
end
--[[
    ///***
    parent models in machine buffers to nil
    ***\\\
]]
function Machine.prototype:GetValidInputChannel(item, quantity) --item is a model
    local primaryChannels = self.InputChannels.Main
    local secondaryChannels = self.InputChannels.Secondary

    local function evaluate_channels(channels)
        for _, channel in ipairs(channels) do
            if channel:CanItemInput(item, quantity) and softProcessCheck(item, self.InputOutputMap) then
                if channel:CanAddQuantity(quantity) then
                    return channel
                else
                    return Enums.OverCapacity
                end
            end
        end
    end

    local primary_result = evaluate_channels(primaryChannels)
    if primary_result then return primary_result end

    local secondary_result = evaluate_channels(secondaryChannels)
    if secondary_result then return secondary_result end
end

function Machine.prototype:Setup()
    self.InputOutputMap = self.MachineData.InputOutputMap

    if self.MachineData.InputChannels then
        for _, data in ipairs(self.MachineData.InputChannels) do
            self:AddInputChannel(data)
        end
    end
    if self.MachineData.OutputChannels then
        for _, data in ipairs(self.MachineData.OutputChannels) do
            table.insert(self.OutputChannels, {
                Capacity = data[1],
                Container = {}
            })
        end
    end
end

function Machine.prototype:AddInputChannel(data)
    local priority = data[4]
    if not self.InputChannels[priority.Name] then
        self.InputChannels[priority.Name] = {}
    end

    local index = #self.InputChannels[priority.Name]
    table.insert(self.InputChannels[priority.Name], InputChannel.new(data, index))
end

function Machine.prototype:AddConnection(con)
    local index = #self.Connections+1
    table.insert(self.Connections, con)

    return index
end

function Machine.prototype:Destroy()
    for _, con in ipairs(self.Connections) do
        con:Disconnect()
        con = nil
    end
    for _, channels in pairs(self.InputChannels) do
        for i, channel in ipairs(channels) do
            channel:Destroy()
            channels[i] = nil
        end
    end
    self.Connections = nil
    self = nil
end

return Machine