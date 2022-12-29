local Formatting = {}

function Formatting.RoundTo(num, nearest)
	--return math.floor(num / nearest) * nearest
	return math.floor(num * 100 + 0.5) / 100;
end

function Formatting.AddCommas(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")

	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function Formatting.GetTimeString(timeInSeconds, hours)
	if not hours then
		local minutes = math.floor(timeInSeconds / 60)
		local seconds = timeInSeconds - (minutes * 60)
		local secondsString = (seconds < 10) and "0" .. seconds or seconds

		return minutes .. ":" .. secondsString
	else
		local hours = math.floor(timeInSeconds / 3600)
		local minutes = (math.floor(timeInSeconds / 60) - (hours * 60))
		local seconds = timeInSeconds - (minutes * 60) - (hours*3600)
		
		local secondsString = (seconds < 10) and "0" .. seconds or seconds
		local minuteString = (minutes < 10) and "0" .. minutes or minutes
		local hourString = (hours < 10) and "0" .. hours or hours

		return hourString .. ":" .. minuteString .. ":" .. secondsString
	end
end

return Formatting