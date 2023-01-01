local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Plane = {}
Plane.prototype = {}

local PLANE_HEIGHT = 950
local PLANE_SPAWN_RADIUS = 6750
local PLANE = ReplicatedStorage:WaitForChild("spaceship")

function Plane.new(rand)
    local self = {}
    setmetatable(self, {__index = Plane.prototype})

    self.Random = rand
    self.EndBind = Instance.new("BindableEvent")
    self.Model = PLANE:Clone()
    self.Emitters = {}
    self.Speed = self.Random:NextInteger(950, 1300)

    for _, obj in ipairs(self.Model:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            table.insert(self.Emitters, obj)
        end
    end

    return self
end

function Plane.prototype:update(dt)
    local currentCf = self.Model.PrimaryPart.CFrame
    local rot = currentCf - currentCf.Position
    local newPos = currentCf.Position - (currentCf.RightVector * self.Speed * dt)
    local rot_offset = CFrame.Angles(math.rad(0.2*math.sin(2*math.pi*0.8*tick())), 0, 0)

    self.Model:SetPrimaryPartCFrame(CFrame.new(newPos) * rot * rot_offset)
end

function Plane.prototype:SetStart()
    local theta = self.Random:NextInteger(0, 360)
    local x = PLANE_SPAWN_RADIUS * math.cos(theta)
    local y = PLANE_SPAWN_RADIUS * math.sin(theta)

    local start_pos = Vector3.new(x, PLANE_HEIGHT, y)
    local offset = self.Random:NextNumber(-10, 10)
    local cf = CFrame.lookAt(start_pos, Vector3.new(0, PLANE_HEIGHT, 0)) * CFrame.Angles(0, math.rad(-90+offset), 0)

    self.Model.Parent = workspace
    self.Model:SetPrimaryPartCFrame(cf)
    self.Model.PrimaryPart.Sound:Play()
end

function Plane.prototype:Destroy()
    self.EndBind:Destroy()
    self.Model:Destroy()
    self = nil
end

return Plane