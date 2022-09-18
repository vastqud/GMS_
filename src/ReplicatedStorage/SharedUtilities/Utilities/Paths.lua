--!strict
local _ReplicatedStorage = game:GetService("ReplicatedStorage");
local IsServer: boolean = game:GetService("RunService"):IsServer();

local PathUtil = {};
PathUtil._Timeout = 10;

function PathUtil:FindInstanceFromPath(path: string, root: Instance?, timeOutLastBranch: number?): Instance?  --  Assumes that the path does indeed exist at build-time (yields for loading clients)
    if not root then
        root = _ReplicatedStorage;
    end;
    assert(root ~= nil, "Root does not exist");

    local paths = string.split(path, "/");
    local current = root;

    for index, n in paths do
        local previousCurrent = current;
        local timeout = if index == #paths then (timeOutLastBranch or self._Timeout) else self._Timeout;

        current = if IsServer then current:FindFirstChild(n) else current:WaitForChild(n, timeout);  --  Yields on client in the case that the game hasn't fully loaded

        if not current then  --  Will return the end of the path to this point
            current = previousCurrent;
            break;
        end;
    end;

    return current;
end;

return PathUtil;