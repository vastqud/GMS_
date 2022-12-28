local TweenService = game:GetService("TweenService")

local NEW_SECTOR_TWEEN = TweenInfo.new(0.2)
local PROTECTED = "Protected Sector"
local NOT_PROTECTED = "Contested Sector"
local ANIMATING = false

local PROTECTED_COLOR = Color3.fromRGB(58, 186, 255)
local HOSTILE_COLOR = Color3.fromRGB(255, 0, 0)
local BLACK = Color3.fromRGB(0, 0, 0)
local RED_TRANSPARENCY = 0.8
local BLACK_TRANSPARENCY = 0.7

local anims = {}
anims.InfoEnabled = false

function anims.newSector(newSectorName, newSectorData, sectorUi)
    local isProtected = newSectorData.Protected
    local final_transparency = isProtected and BLACK_TRANSPARENCY or RED_TRANSPARENCY
    local inTween = TweenService:Create(sectorUi.Glow, NEW_SECTOR_TWEEN, {ImageTransparency = 0.2})

    sectorUi.Glow.ImageColor3 = isProtected and BLACK or HOSTILE_COLOR
    sectorUi.Sector.Text = string.upper(newSectorName)
    sectorUi.Status.Text = isProtected and PROTECTED or NOT_PROTECTED
    sectorUi.Status.TextColor3 = isProtected and PROTECTED_COLOR or HOSTILE_COLOR
    sectorUi.Status.UIStroke.Color = isProtected and PROTECTED_COLOR or HOSTILE_COLOR

    ANIMATING = true
    inTween:Play()
    inTween.Completed:Wait()
    inTween = nil
    ANIMATING = false

    TweenService:Create(sectorUi.Glow, NEW_SECTOR_TWEEN, {ImageTransparency = final_transparency}):Play()
end
--{0.9, 0},{1.5, 0}
function anims.infoPane(sectorUi)
    local pane = sectorUi.InfoPane

    if pane.Visible then --close
        anims.InfoEnabled = false

        local tween = TweenService:Create(pane, NEW_SECTOR_TWEEN, {Size = UDim2.fromScale(0, 0)})
        tween:Play()
        tween.Completed:Wait()
        tween:Destroy(); tween = nil

        if not anims.InfoEnabled then
            pane.Visible = false
        end
    else --open
        anims.InfoEnabled = true

        pane.Visible = true
        TweenService:Create(pane, NEW_SECTOR_TWEEN, {Size = UDim2.fromScale(0.9, 1.5)}):Play()
    end
end

return anims