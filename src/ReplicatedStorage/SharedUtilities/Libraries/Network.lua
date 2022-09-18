--!strict
local import = require(game.ReplicatedStorage:WaitForChild("SharedUtilities"):WaitForChild("Utilities"):WaitForChild("Import")):registerFile(script);

-- Containers
local NetworkFolder = game:GetService("ReplicatedStorage"):WaitForChild("Network");
local RemoteEvents = NetworkFolder:WaitForChild("RemoteEvents");
local RemoteFunctions = NetworkFolder:WaitForChild("RemoteFunctions");

-- Modules
local PathUtility = import("/Paths");

-- Declarations
local IsServer: boolean = game:GetService("RunService"):IsServer();
local Network = {};

local function _findInstanceFromPath(name: string, path: string, className: string): any
    path = path .. "/" .. name;

    local root = if className == "RemoteEvent" then RemoteEvents else RemoteFunctions;
    local found: Instance? = PathUtility:FindInstanceFromPath(path, root);

    if (found) and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then  --  If the network instance was found at the path, return it
        return found;
    end;
    --  Network instance not found
    if IsServer then  --  Server will create the instance and parent it to the correct path
        local new = Instance.new(className, found);
        new.Name = name;

        return new;
    end;

    return;
end;

function Network.getRemoteEvent(name: string, path: string): RemoteEvent
    return _findInstanceFromPath(name, path, "RemoteEvent");
end;

function Network.getRemoteFunction(name: string, path: string): RemoteFunction
    return _findInstanceFromPath(name, path, "RemoteFunction");
end;

return Network;