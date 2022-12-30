local function YieldUntilLoaded(model, expectedDescendants, timeOut)
    local cancel = false
    local timedOut = false
    local elapsed = 0
    if not timeOut then timeOut = 30 end

    repeat
        task.wait(0.05)
        elapsed += 0.05

        if model.Parent == nil then
            cancel = true
        end
        if elapsed >= timeOut then
            timedOut = true
        end
    until (#model:GetDescendants() >= expectedDescendants) or (cancel) or (timedOut)

    if cancel then print("Model " .. model.Name .. " loading canceled") return end
    return model
end

return YieldUntilLoaded