local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RequestNeverStreamOut = require(ReplicatedStorage.SharedUtilities.Utilities.Misc.RequestNeverStreamOut)

local PARTICLE_EMIT_RATE_STATIC = 5
local PARTICLE_EMIT_RATE_MOVING = 50
local PLANE = ReplicatedStorage:WaitForChild("spaceship")

local Battles = {}
Battles.Station = nil
Battles.initted = false
Battles.SpawnPoints = nil

local REGISTERED_PARTICLES_STATIC = {}
local PLANES = {}
local LAST_EMIT_STATIC = 0
local LAST_EMIT_MOVING = 0

local function update(dt)
    if not Battles.initted then return end

    local emitting_static = false
    local emitting_moving = false
    if (tick() - LAST_EMIT_STATIC >= (1/PARTICLE_EMIT_RATE_STATIC)) then
        emitting_static = true
        LAST_EMIT_STATIC = tick()
    end
    if (tick() - LAST_EMIT_MOVING >= (1/PARTICLE_EMIT_RATE_MOVING)) then
        emitting_moving = true
        LAST_EMIT_MOVING = tick()
    end

    if emitting_static then
        for _, emitter in ipairs(REGISTERED_PARTICLES_STATIC) do
            emitter:Emit(50)
        end
    end

    if emitting_moving then
        for _, plane in pairs(PLANES) do
            for _, emitter in ipairs(plane.Emitters) do
                emitter:Emit(20)
            end
        end
    end

    local newCf = Battles.Station.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(dt*0.01), 0)
    Battles.Station:SetPrimaryPartCFrame(newCf)

    for _, plane in pairs(PLANES) do
        plane = plane.Plane

        local currentCf = plane.PrimaryPart.CFrame
        local rot = currentCf - currentCf.Position
        local newPos = currentCf.Position - currentCf.RightVector * 0.875 * dt
        local rot_offset = CFrame.Angles(math.rad(0.2*math.sin(2*math.pi*0.8*tick())), 0, 0)

        plane:SetPrimaryPartCFrame(CFrame.new(newPos) * rot * rot_offset)
    end
end

local function start_plane()
    if not Battles.initted then return end

    local new_plane = PLANE:Clone()
    local end_bind = Instance.new("BindableEvent")
    PLANES[new_plane] = {Plane = new_plane, Emitters = {}, EndBind = end_bind}
    new_plane.Parent = workspace
    new_plane:SetPrimaryPartCFrame(Battles.SpawnPoints.spawn_point.CFrame)
    new_plane.PrimaryPart.Sound:Play()
    for _, obj in ipairs(new_plane:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            table.insert(PLANES[new_plane].Emitters, obj)
        end
    end

    task.spawn(function()
        task.wait(13)
        end_bind:Fire()
    end)
    end_bind.Event:Wait()

    PLANES[new_plane].Plane = nil; PLANES[new_plane].Emitters = nil; PLANES[new_plane] = nil
    new_plane:Destroy()
end

function Battles.init()
    local station = RequestNeverStreamOut.RequestFromClient(workspace:WaitForChild("spacestation"))
    local spawn_points = RequestNeverStreamOut.RequestFromClient(workspace:WaitForChild("plane_spawns"))

    if station and spawn_points then
        workspace:FindFirstChild("spacestation"):Destroy()
        workspace:FindFirstChild("plane_spawns"):Destroy()
        spawn_points.Parent = workspace
        station.Parent = workspace

        Battles.Station = station
        Battles.SpawnPoints = spawn_points

        RequestNeverStreamOut.FinishedClient(station.Name)
        RequestNeverStreamOut.FinishedClient(spawn_points.Name)

        for _, obj in ipairs(station:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                table.insert(REGISTERED_PARTICLES_STATIC, obj)
            end
        end
        
        Battles.initted = true
        RunService.Stepped:Connect(update)
        ReplicatedStorage.Network.Events.PlaneSpawn.OnClientEvent:Connect(start_plane)

        task.spawn(function()
            while true do
                wait(10)
                print("starting plane")
                start_plane()
            end
        end)
    end
end

return Battles