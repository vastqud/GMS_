local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)

local list = {
    Unlimited = Enums.new("-1", {}),
    Main = Enums.new("MainChannel", {}),
    Secondary = Enums.new("SecondaryChannel", {}),
    Whitelist = Enums.new("Whitelist", {}),
    Blacklist = Enums.new("Blacklist", {}),
    PowerChannel = Enums.new("PowerChannel", {}),
    OverCapacity = Enums.new("OverCapacity", {})
}

return list