local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PLOT_MODELS = workspace:FindFirstChild("Plots"):GetChildren()
local RAY_PARAMS = RaycastParams.new()
local DOWN = Vector3.new(0, -1, 0)
local TELEPORT_OFFSET = Vector3.new(0, 15, 0)

local FastFlags = require(ReplicatedStorage.SharedData.GlobalConstants.FastFlags)

do
    table.sort(PLOT_MODELS, function(a, b)
        return a:GetAttribute("Order") < b:GetAttribute("Order")
    end)
end

local Plots = {}
Plots.prototype = {}
Plots.list = {}

local function findVacantPlot()
    for _, model in ipairs(PLOT_MODELS) do
        if not model:GetAttribute("Owner") then
            return model
        end
    end
end

local function verifyClientLoaded(player)
    local plot = Plots.find(player)
    if not plot then return end
    if plot.Loaded then return end

    plot.Loaded = true
    plot.LoadedBindable:Fire()
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
    end
end

function Plots.new(owner)
    local self = {}
    setmetatable(self, {__index = Plots.prototype})

    self.Owner = owner
    self.Model = findVacantPlot()

    self.Loaded = false
    self.LoadedBindable = Instance.new("BindableEvent")
    self.OnLoaded = self.LoadedBindable.Event

    self.Model:SetAttribute("Owner", owner.UserId)

    Plots.list[owner.UserId] = self
    owner:SetAttribute("Plot", self.Model.Name)

    return self
end

function Plots.prototype:Load()
    task.spawn(function()
        local rand = Random.new()
        for i = 1, 10 do
            local offset = Vector3.new(rand:NextInteger(-100, 100), 0, rand:NextInteger(-100, 100))
            local loaded_model = ReplicatedStorage.testmodel:Clone()
            loaded_model:SetPrimaryPartCFrame(CFrame.new(self.Model.PrimaryPart.Position + offset))
            loaded_model.Parent = self.Model
        end

        ReplicatedStorage.Network.Events.LoadPlotClient:FireClient(self.Owner, self.Model, #self.Model:GetDescendants())
        self.Owner:RequestStreamAroundAsync(self.Model.PrimaryPart.Position)
    end)
end

function Plots.prototype:TeleportOwnerBlocking()
    if FastFlags.Spawn_At_SpawnPoint then return end
    local char = self.Owner.Character
    if not char then
        char = self.Owner.CharacterAdded:Wait()
    end
    if not self.Loaded then self.OnLoaded:Wait() end
    task.wait(0.1)

    local origin = self.Model.PrimaryPart.Position + Vector3.new(0, 200, 0)
    local result = workspace:Raycast(origin, DOWN * 205, RAY_PARAMS)
    local pos = result.Position + TELEPORT_OFFSET
    char:SetPrimaryPartCFrame(CFrame.new(pos))
end

function Plots.prototype:Cleanup()
    self.Model:SetAttribute("Owner", nil)

    for _, obj in ipairs(self.Model:GetChildren()) do
        if obj.Name ~= "Base" then
            obj:Destroy()
        end
    end

    self:Destroy()
end

function Plots.prototype:Destroy()
    Plots.list[self.Owner.UserId] = nil

    self.LoadedBindable:Destroy()
    self.OnLoaded = nil
    self = nil
end

ReplicatedStorage.Network.Events.LoadPlotClient.OnServerEvent:Connect(verifyClientLoaded)

return Plots