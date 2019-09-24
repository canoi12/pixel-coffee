local Class = require("pixcof.class")
local Entity = Class:extends("Entity")

function Entity:constructor(x, y)
	self.x = x or 0
	self.y = y or 0
	self.angle = 0
	self.scale = {
		x = 1,
		y = 1
	}
	self.center = {
		x = 0,
		y = 0
	}
	--[[self.centerx = 0
	self.centery = 0]]
end

function Entity:update(dt)
end

function Entity:draw()
end

function Entity:debug(active)
	local image = {32, 32}
	if not self.width or not self.height then
		if self.animation then image = {self.animation.width, self.animation.height}
		elseif self.image then image = {self.image:getDimensions()} end
		print(image[1], image[2])
		self.width = image[1]
		self.height = image[2]
	end
	love.graphics.setColor(1, 1, 1, 1)
	if active then love.graphics.setColor(1, 0, 0, 1) end
	love.graphics.rectangle("line", self.x-self.center.x, self.y-self.center.y, self.width*self.scale.x, self.height*self.scale.y)
	love.graphics.setColor(1, 1, 1, 1)
end

function Entity:isHovering(x, y)
	local xx = self.x - self.center.x
	local yy = self.y - self.center.y
	local ww = xx + self.width * self.scale.x
	local hh = yy + self.height * self.scale.y
	if x >= xx and x <= ww and y >= yy and y <= hh then
		return true
	end
	return false
end

return Entity