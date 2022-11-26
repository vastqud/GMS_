local AttachmentLib = {}

function AttachmentLib.getAttPosFromWorldPos(objectPos, pos)
    local difference = pos - objectPos
    return -difference
end

return AttachmentLib