local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local TWEEN_INFO = TweenInfo.new(0.2)

local Leaderboard = {}
Leaderboard.Enabled = true
Leaderboard.UI = nil

function Leaderboard.init(ui)
    Leaderboard.UI = ui

    local header = Leaderboard.UI.Header
    local arrow = header.Arrow
    header.Players.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers

    for _, player in ipairs(Players:GetPlayers()) do
        Leaderboard.AddPlayer(player)
    end

    Players.PlayerAdded:Connect(Leaderboard.AddPlayer)
    Players.PlayerRemoving:Connect(Leaderboard.RemovePlayer)
end

function Leaderboard.Enable()
    Leaderboard.Enabled = true
    local arrow = Leaderboard.UI.Header.Arrow
    local list = Leaderboard.UI.List

    TweenService:Create(arrow, TWEEN_INFO, {Rotation = 0}):Play()
    TweenService:Create(list, TWEEN_INFO, {Position = UDim2.new(1, 0, 0, 30)}):Play()

    list.Visible = true
end

function Leaderboard.Close()
    Leaderboard.Enabled = false
    local arrow = Leaderboard.UI.Header.Arrow
    local list = Leaderboard.UI.List

    TweenService:Create(arrow, TWEEN_INFO, {Rotation = 180}):Play()
    local tween = TweenService:Create(list, TWEEN_INFO, {Position = UDim2.new(2, 0, 0, 30)})

    tween:Play()
    tween.Completed:Wait()
    tween = nil

    if not Leaderboard.Enabled then
        list.Visible = false
    end
end

function Leaderboard.AddPlayer(player)
    local template = Leaderboard.UI.Playertemplate:Clone()
    local header = Leaderboard.UI.Header
    template:SetAttribute("Player", player.UserId)

    if player == Player then
        template.LayoutOrder = 0
    end

    template.Username.Text = player.Name
    template.Parent = Leaderboard.UI.List
    template.Visible = true

    header.Players.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
end

function Leaderboard.RemovePlayer(player)
    local list = Leaderboard.UI.List
    local header = Leaderboard.UI.Header

    for _, entry in ipairs(list:GetChildren()) do
        if entry:GetAttribute("Player") == player.UserId then
            entry:Destroy()
        end
    end

    header.Players.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
end

return Leaderboard