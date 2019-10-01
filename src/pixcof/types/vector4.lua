local Class = require("pixcof.class")
local Vector4 = Class:extend("Vector4")

function Vector4.zero()
	return Vector4()
end

function Vector4.right()
	return Vector4(1, 0, 0, 0)
end

function Vector4.up()
	return Vector4(0, -1, 0, 0)
end

function Vector4.left()
	return Vector4(-1, 0, 0, 0)
end

function Vector4.down()
	return Vector4(0, 1, 0, 0)
end

function Vector4:constructor(x, y, z, w)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.w = w or 0
end

function Vector4:__add(vector)
	local xx = self.x + vector.x
	local yy = self.y + vector.y
	local zz = self.z + vector.z
	local ww = self.w + vector.w
	return Vector4(xx, yy, zz, ww)
end

function Vector4:__sub(vector)
	local xx = self.x - vector.x
	local yy = self.y - vector.y
	local zz = self.z - vector.z
	local ww = self.w - vector.w
	return Vector4(xx, yy, zz, ww)
end

function Vector4.__mul(val1, val2)
	local xx = 0
	local yy = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x * val2
		yy = val1.y * val2
		zz = val1.z * val2
		ww = val1.w * val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x * val1
		yy = val2.y * val1
		zz = val2.z * val1
		ww = val2.w * val1
	end
	return Vector4(xx, yy, zz, ww)
end

function Vector4.__div(val1, val2)
	local xx = 0
	local yy = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x / val2
		yy = val1.y / val2
		zz = val1.z / val2
		ww = val1.w / val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x / val1
		yy = val2.y / val1
		zz = val2.z / val1
		ww = val2.w / val1
	end
	return Vector4(xx, yy, zz, ww)
end

function Vector4:__tostring()
	return "Vector4(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w .. ")"
end

function Vector4:setX(x)
	self.x = x or self.x
end

function Vector4:setY(y)
	self.y = y or self.y
end

function Vector4:setZ(z)
	self.z = z or self.z
end

function Vector4:setW(w)
	self.w = w or self.w
end

function Vector4:set(x, y, z, w)
	self:setX(x)
	self:setY(y)
	self:setZ(z)
	self:setW(w)
end

return Vector4