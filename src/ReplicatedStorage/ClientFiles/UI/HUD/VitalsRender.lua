local TweenService = game:GetService("TweenService")

local last_vitals = {
    Health = 100,
    Armor = 100
}
local fake_bars = {
    Health = {}, --[1] = fake bar, [2] = tween, [3] = increase tween
    Armor = {}
}
local glow = {
    Health = Color3.fromRGB(0, 226, 26),
    Armor = Color3.fromRGB(0, 102, 226)
}
local info = TweenInfo.new(0.3, Enum.EasingStyle.Linear)

local renderer = {}
renderer.Vitals = nil

local function getFakeBar(bar, oldSize, newSize, colorCode)
    local new = bar:Clone()
    local delta = (oldSize - newSize)

    new.Position = UDim2.fromScale(newSize, 0)
    new.Size = UDim2.fromScale(delta, 1)
    new.UIGradient:Destroy()
    new.UICorner:Destroy()
    new.BorderSizePixel = 0
    new.BackgroundColor3 = colorCode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

    return new
end

local function makeNewTween(fakeBar, which)
    local tween = TweenService:Create(fakeBar, info, {Size = UDim2.fromScale(0, 1)})
    fake_bars[which][2] = tween
    tween:Play()
    tween.Completed:Connect(function(state)
        if state ~= Enum.PlaybackState.Completed then return end
        fakeBar:Destroy(); tween:Destroy(); tween = nil; fake_bars[which][2] = nil; fake_bars[which][1] = nil
    end)
end

function renderer.updateVitalsBar(which, newVal)
    local which_bar = renderer.Vitals:FindFirstChild(which)

    if which ~= "Stamina" then
        local lastVal = last_vitals[which]
        local newSize = newVal / 100
        local oldSize = lastVal / 100
        local bar = which_bar.Bar

        if newSize < oldSize then
            bar.Size = UDim2.fromScale(newSize, 1)
            fake_bars[3]:Cancel()

            if not fake_bars[which][1] then --create new fake bar and tween it
                local fakeBar = getFakeBar(bar, oldSize, newSize, true)
                fake_bars[which][1] = fakeBar
                fakeBar.Parent = bar.Parent
    
                makeNewTween(fakeBar, which)
            else --resize existing fake bar and start a new tween on it
                local fakeBar = fake_bars[which][1]
                local delta = oldSize - newSize
    
                local current_size = fakeBar.Size.X.Scale
                local current_pos = fakeBar.Position.X.Scale
    
                fake_bars[which][2]:Cancel()
    
                fakeBar.Size = UDim2.fromScale(current_size + delta, 1)
                fakeBar.Position = UDim2.fromScale((current_pos - delta), 0)
                
                makeNewTween(fakeBar, which)
            end
        else
            fake_bars[3] = TweenService:Create(bar, info, {Size = UDim2.fromScale(newSize, 1)})
            fake_bars[3]:Play()
        end

        if newVal < 45 then
            which_bar.Glow.ImageColor3 = Color3.fromRGB(255, 0, 0)
        else
            which_bar.Glow.ImageColor3 = glow[which]
        end

        last_vitals[which] = newVal
    end
end

function renderer.init(ui)
    renderer.Vitals = ui
end

return renderer