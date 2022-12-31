local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedUtils = ReplicatedStorage:WaitForChild("SharedUtilities")
local SharedData = ReplicatedStorage:WaitForChild("SharedData")
local RequestNeverStreamOut = require(SharedUtils.Utilities.Misc.RequestNeverStreamOut)
local Constants = require(SharedData.GlobalConstants.Constants)

local Settings = Constants.AtmosphereSettings
local CurrentCover = Settings.Clouds.Range.Default[1]
local CoverDirection = 1
local Connection

local AtmosphereController = {}
AtmosphereController.Mode = "Default"
AtmosphereController.StarsModel = nil
AtmosphereController.Clouds = nil

local function update(dt)
    local star_speed = Settings.StarSpeed[AtmosphereController.Mode]
    local cloud_speed = Settings.Clouds.Speed[AtmosphereController.Mode]
    local cloud_range = Settings.Clouds.Range[AtmosphereController.Mode]

    local newCf = AtmosphereController.StarsModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(star_speed), 0)
    local newCover = math.clamp(CurrentCover+(dt*cloud_speed*CoverDirection), cloud_range[1], cloud_range[2])

    if newCover >= cloud_range[2] then
        CoverDirection = -1
    elseif newCover <= cloud_range[1] then
        CoverDirection = 1
    end

    AtmosphereController.StarsModel:SetPrimaryPartCFrame(newCf)
    AtmosphereController.Clouds.Cover = newCover
    CurrentCover = newCover
end

function AtmosphereController.init()
    local stars = RequestNeverStreamOut.RequestFromClient(workspace:WaitForChild("Stars")):Clone()

    if stars then
        workspace:FindFirstChild("Stars"):Destroy()
        stars.Parent = workspace
        RequestNeverStreamOut.FinishedClient(stars.Name)
        
        AtmosphereController.StarsModel = stars
        AtmosphereController.Clouds = workspace.Terrain:WaitForChild("Clouds")
        AtmosphereController.enable(true)
    end
end

function AtmosphereController.enable(on)
    if on then
        if not Connection then
            Connection = RunService.RenderStepped:Connect(update)
        end
    else
        if Connection then
            Connection:Disconnect(); Connection = nil
        end
    end
end

return AtmosphereController