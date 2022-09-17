--!strict
local Import = {};

local PathUtility;
local import;

function Import.registerFile(file: Instance): any
    return function(path: string): any
        local paths = string.split(path, "/");
        local root = if paths[1] == "" then file else nil;
        
        local accessedFile: Instance? = PathUtility:FindInstanceFromPath(path, root);

        if accessedFile and accessedFile:IsA("ModuleScript") then
            return require(accessedFile);
        end
    end;
end;

import = Import.registerFile(script);
PathUtility = import("SharedUtilities/Utilities/Paths");

return Import;