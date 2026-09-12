local NumberUtil = {}

local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}

function NumberUtil.format(value)
	value = tonumber(value) or 0
	local sign = value < 0 and "-" or ""
	value = math.abs(value)
	local index = 1
	while value >= 1000 and index < #suffixes do
		value /= 1000
		index += 1
	end
	if index == 1 then
		return sign .. tostring(math.floor(value + 0.5))
	end
	local text = value >= 100 and string.format("%.0f", value)
		or value >= 10 and string.format("%.1f", value)
		or string.format("%.2f", value)
	text = text:gsub("%.?0+$", "")
	return sign .. text .. suffixes[index]
end

return NumberUtil
