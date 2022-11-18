local Enum = {}

local function constructMetatable(enumName, valueId, value, valueOtherData)
	valueOtherData = valueOtherData or {}
	local index = {Name = value, Id = valueId, Data = valueOtherData, EnumName = enumName}

	setmetatable(index, {
		__index = function(t, k)
			local val = rawget(index.Data, k)
			if val == nil then
				error(string.format("Enum %s member %s does not exist", value, k), 2)
			end
			return val
		end
	})
	setmetatable(valueOtherData, {
		__index = function(t, k)
			local val = rawget(t, k)
			if val == nil then
				error(string.format("Enum %s member %s does not exist", value, k), 2)
			end
			return val
		end,
		__newindex = function() error("Enums are read-only", 2) end
	})

	return {
		__index = index,
		__newindex = function() error("Enum values are read-only", 2) end,
		__tostring = function()
			return value
		end,
		__eq = function(thisEnum, otherEnum)
			local enumNameEquals = thisEnum.EnumName == otherEnum.EnumName
			local nameEquals = thisEnum.Name == otherEnum.Name

			return enumNameEquals and nameEquals
		end
	}
end

--[[
    local NameplateEnums = {
        PlayerAttribute = Enums.new("PlayerAttribute", {
            {Name = "RoleplayName"},
            {Name = "NameplateTag"}
        })
    }
]]

function Enum.new(enumName, enumValues)
	local values = {}
	local newEnum = {}

	setmetatable(
		values,
		{
			__index = function(t, k)
				local val = rawget(t, k)
                if k == "Name" then val = enumName end
				if val == nil then
					error(string.format("Enum member %s does not exist", k), 2)
				end
				return val
			end
		}
	)

	for index, valueData in ipairs(enumValues) do
		local o = {}
		setmetatable(o, constructMetatable(enumName, index, valueData.Name, valueData.Data))

		values[index] = o; values[valueData.Name] = o
	end

	setmetatable(
		newEnum,
		{
			__index = values,
			__tostring = function() return string.format("Enum %s", enumName) end,
			__newindex = function() error("Enums are read-only", 2) end
		}
	)

	return newEnum
end

return Enum