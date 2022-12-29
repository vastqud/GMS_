local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PLOT_MODELS = workspace:FindFirstChild("Plots")
local TELEPORT_OFFSET = Vector3.new(0, 10, 0)

local Plots = {}
Plots.prototype = {}
Plots.list = {}

local function findVacantPlot()
    for _, model in ipairs(PLOT_MODELS:GetChildren()) do
        if not model:GetAttribute("Owner") then
            return model
        end
    end
end

function Plots.find(owner)
    if Plots.list[owner.UserId] then
        return Plots.list[owner.UserId]
    end
end

function Plots.remove(owner)
    local plot = Plots.find(owner)

    if plot then
        plot:Cleanup()

        Plots.list[owner.UserId] = nil
    end
end

function Plots.new(owner)
    local self = {}
    setmetatable(self, {__index = Plots.prototype})

    self.Owner = owner
    self.Model = findVacantPlot()

    self.Model:SetAttribute("Owner", owner.UserId)

    Plots.list[owner.UserId] = self
    owner:SetAttribute("Plot", self.Model.Name)

    return self
end

function Plots.prototype:TeleportOwner()
    local char = self.Owner.Character
    if not char then
        char = self.Owner.CharacterAdded:Wait()
    end
    task.wait(0.1)

    char:SetPrimaryPartCFrame(CFrame.new(self.Model.PrimaryPart.Position+TELEPORT_OFFSET))
end

function Plots.prototype:Cleanup()
    self.Model:SetAttribute("Owner", nil)
end

return Plots