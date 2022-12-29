local Math = {}

function Math.lerp(start, target, t)
	return start * (1 - t) + target * t
end

return Math