local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(script.Parent.MachineEnums)
local Items = require(ReplicatedStorage.SharedData.Metadata.Items)

local InputChannels = {}
InputChannels.prototype = {}

function InputChannels.new(data, channelNumber)
    local self = {}
    setmetatable(self, {__index = InputChannels.prototype})
    
    self.Priority = data[4]
    self.ItemType = data[1]
    self.MaxCapacity = typeof(data[2]) == "number" and data[2] or nil
    self.Channel = channelNumber

    self.Container = {}
    self.CurrentCapacity = 0
    self.CurrentProcess = nil
    self.ProcessTick = 0

    if data[3] then
        local table
        if data[3].Whitelist then self.FilterInputType = Enums.Whitelist table = data[3].Whitelist end
        if data[3].Blacklist then self.FilterInputType = Enums.Blacklist table = data[3].Blacklist end

        self.FilterItemTable = table
    end

    return self
end

function InputChannels.prototype:CanItemInput(item)
    if Items:GetItemField(item.Name, "ItemType") ~= self.ItemType then return end --is the type wrong?

    if self.FilterInputType == Enums.Whitelist then --is it not in the whitelist or in the blacklist?
        if not table.find(self.FilterItemTable, item.Name) then return end
    elseif self.FilterInputType == Enums.Blacklist then
        if table.find(self.FilterItemTable, item.Name) then return end
    end

    --if all above works, the last thing to check is if the item has a valid process in this machine for an output
    --and also if the channel is over capacity. if it's over capacity, then we will add the item to the buffer
    --those dont necessarily have anything to do with an input channel, so the machine object will do it
    return true
end

function InputChannels.prototype:CanAddQuantity(quantity) 
    if not self.MaxCapacity then return true end

    return (self.MaxCapacity - self.CurrentCapacity) >= quantity
end

function InputChannels.prototype:Add(item, quantity) --item is a model
    if not quantity then quantity = 1 end

    local alreadyFound = false
    for _, itemData in ipairs(self.Container) do
        if itemData.Item == item then
            itemData.Quantity += quantity
            alreadyFound = true
        end
    end

    if not alreadyFound then
        local index = #self.Container+1
        table.insert(self.Container, {
            Item = item,
            Quantity = quantity
        })
    end

    self.CurrentCapacity += quantity
end

function InputChannels.prototype:Remove(quantity, fifo) --fifo behavior
    if not quantity then quantity = 1 end

    if fifo then
        self.CurrentCapacity -= self.Container[1].Quantity
        table.remove(self.Container, 1)
        return
    end

    if self.Container[1] then
        self.Container[1].Quantity -= quantity
        if self.Container[1].Quantity <= 0 then
            self.CurrentCapacity -= self.Container[1].Quantity
            table.remove(self.Container, 1)
        else
            self.CurrentCapacity -= quantity
        end
    end
end

function InputChannels.prototype:Destroy()
    self = nil
end

return InputChannels