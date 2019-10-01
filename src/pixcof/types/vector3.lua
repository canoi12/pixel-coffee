local Class = require("pixcof.class")
local Vector3 = Class:extend("Vector3")

function Vector3.zero()
	return Vector3()
end

function Vector3.right()
	return Vector3(1, 0, 0)
end

function Vector3.up()
	return Vector3(0, -1, 0)
end

function Vector3.left()
	return Vector3(-1, 0, 0)
end

function Vector3.down()
	return Vector3(0, 1, 0)
end

function Vector3:constructor(x, y, z)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
end

function Vector3:__add(vector)
	local xx = self.x + vector.x
	local yy = self.y + vector.y
	local zz = self.z + vector.z
	return Vector3(xx, yy, zz)
end

function Vector3:__sub(vector)
	local xx = self.x - vector.x
	local yy = self.y - vector.y
	local zz = self.z - vector.z
	return Vector3(xx, yy, zz)
end

function Vector3.__mul(val1, val2)
	local xx = 0
	local yy = 0
	local zz = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x * val2
		yy = val1.y * val2
		zz = val1.z * val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x * val1
		yy = val2.y * val1
		zz = val2.z * val1
	end
	return Vector3(xx, yy, zz)
end

function Vector3.__div(val1, val2)
	local xx = 0
	local yy = 0
	local zz = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x / val2
		yy = val1.y / val2
		zz = val1.z / val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x / val1
		yy = val2.y / val1
		zz = va21.z / val1
	end
	return Vector3(xx, yy, zz)
end

function Vector3:__tostring()
	return "Vector3(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

function Vector3:setX(x)
	self.x = x or self.x
end

function Vector3:setY(y)
	self.y = y or self.y
end

function Vector3:setZ(z)
	self.z = z or self.z
end

function Vector3:set(x, y, z)
	self:setX(x)
	self:setY(y)
	self:setZ(z)
end

return Vector3