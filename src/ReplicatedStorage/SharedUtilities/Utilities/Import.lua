--!strict
local Import = {
    ValidRoots = {
        ["ServerScriptService"] = {
            Aliases = {
                "server"
            },
            Location = game:GetService("ServerScriptService")
        },
        ["ReplicatedStorage"] = {
            Aliases = {
                "shared",
                "client"
            },
            Location = game:GetService("ReplicatedStorage")
        }
    }
};

local PathUtility;
local import;

--[[
        Returns a function specific to the calling script that replaces require.
        The function will search the calling script for the dependency if no root is given ("/dependency") as path argument.
        If not searching for direct dependencies, it will search with ReplicatedStorage as the default root ("SharedUtilities/Utilities/Paths").
        A different root can be specified by prefixing it to the path argument ("ServerScriptService/path/to/file").
        Once the target file is found, the function will require and return that result.
]]

function Import:_getRoot(root: string): Instance?
    local lower_root: string = string.lower(root);

    if self.ValidRoots[root] then
        return self.ValidRoots[root].Location;
    end;

    for rootName, data in pairs(self.ValidRoots) do
        local lower_name: string = string.lower(rootName);

        if lower_root == lower_name then
            return data.Location;
        end;

        for _, alias in ipairs(data.Aliases) do
            if lower_root == alias then
                return data.Location;
            end
        end;
    end;

    return;
end

function Import:registerFile(file: Instance): any
    return function(path: string): any
        local paths = string.split(path, "/");
        local root;

        if paths[1] == "" then
            root = file;
        else
            root = self:_getRoot(paths[1])
        end;
        
        local accessedFile: Instance? = PathUtility:FindInstanceFromPath(path, root);

        if accessedFile and accessedFile:IsA("ModuleScript") then
            return require(accessedFile);
        end
    end;
end;

import = Import:registerFile(script);
PathUtility = import("SharedUtilities/Utilities/Paths");

return Import;