local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.SharedUtilities.Libraries.Enums)

local PermissionEnums = {
    Actions = {
        Interact = Enums.new("Interact", {}),
        Drag = Enums.new("Drag", {}),
        Visit = Enums.new("Visit", {}),
        Sit = Enums.new("Sit", {}),
        Drive = Enums.new("Drive", {})
    }
}

return PermissionEnums