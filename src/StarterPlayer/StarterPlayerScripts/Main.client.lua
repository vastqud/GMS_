--**Main client module loader & logic handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedUtils = ReplicatedStorage:WaitForChild("SharedUtilities")
local ClientFiles = ReplicatedStorage:WaitForChild("ClientFiles")

local Permissions = require(SharedUtils.Utilities.Permissions)
local Drag = require(ClientFiles.Interactions.Drag) --start click to drag system