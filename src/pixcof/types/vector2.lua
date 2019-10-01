local Class = require("pixcof.class")
local Vector2 = Class:extend("Vector2")

function Vector2.zero()
	return Vector2()
end

function Vector2.right()
	return Vector2(1, 0)
end

function Vector2.up()
	return Vector2(0, -1)
end

function Vector2.left()
	return Vector2(-1, 0)
end

function Vector2.down()
	return Vector2(0, 1)
end

function Vector2:constructor(x, y)
	self.x = x or 0
	self.y = y or 0
end

function Vector2:__add(vector)
	local xx = self.x + vector.x
	local yy = self.y + vector.y
	return Vector2(xx, yy)
end

function Vector2:__sub(vector)
	local xx = self.x - vector.x
	local yy = self.y - vector.y
	return Vector2(xx, yy)
end

function Vector2.__mul(val1, val2)
	local xx = 0
	local yy = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x * val2
		yy = val1.y * val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x * val1
		yy = val2.y * val1
	end
	return Vector2(xx, yy)
end

function Vector2.__div(val1, val2)
	local xx = 0
	local yy = 0
	if type(val1) == "table" and type(val2) == "number" then
		xx = val1.x / val2
		yy = val1.y / val2
	elseif type(val2) == "table" and type(val1) == "number" then
		xx = val2.x / val1
		yy = val2.y / val1
	end
	return Vector2(xx, yy)
end

function Vector2:__tostring()
	return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end

function Vector2:setX(x)
	self.x = x or self.x
end

function Vector2:setY(y)
	self.y = y or self.y
end

function Vector2:set(x, y)
	self:setX(x)
	self:setY(y)
end

return Vector2