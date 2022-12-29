local function YieldUntilLoaded(model, expectedDescendants)
    local cancel = false
    repeat
        task.wait(0.05)
        if model.Parent == nil then
            cancel = true
        end
    until (#model:GetDescendants() >= expectedDescendants) or (cancel)

    if cancel then print("Model " .. model.Name .. " loading canceled") return end
    return model
end

return YieldUntilLoaded