local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RequestNeverStreamOut = require(ReplicatedStorage.SharedUtilities.Utilities.Misc.RequestNeverStreamOut)
local Planes = require(script.Plane)

local PARTICLE_EMIT_RATE_STATIC = 5
local PARTICLE_EMIT_RATE_MOVING = 50
local PLANE_HEIGHT = 950
local PLANE_SPAWN_RADIUS = 6750
local RAND = nil
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

    local newCf = Battles.Station.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(dt*30), 0)
    Battles.Station:SetPrimaryPartCFrame(newCf)

    for _, plane in pairs(PLANES) do
        plane:update(dt)
    end
end

local function createPlane()
    local new_plane = Planes.new(RAND)
    local index = #PLANES+1

    PLANES[index] = new_plane
    new_plane:SetStart()

    return new_plane, index
end

local function start_plane()
    if not Battles.initted then return end

    local new_plane, index = createPlane()
    local end_bind = new_plane.EndBind
    local sound = new_plane.Model.PrimaryPart.Sound

    task.spawn(function()
        task.wait(13)
        end_bind:Fire()
    end)
    end_bind.Event:Wait()
    TweenService:Create(sound, TweenInfo.new(1), {Volume = 0}):Play()
    task.wait(1)

    PLANES[index] = nil; new_plane:Destroy(); 
end

local function initate_planes(seed)
    RAND = Random.new(seed)

    local amt = RAND:NextInteger(1, 3)
    for i = 1, amt do
        task.spawn(start_plane)
        task.wait(RAND:NextNumber(1, 4))
    end
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
        RunService.RenderStepped:Connect(update)
        ReplicatedStorage.Network.Events.PlaneSpawn.OnClientEvent:Connect(initate_planes)
    end
end

return Battles