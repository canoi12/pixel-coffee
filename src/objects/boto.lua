local Enemy = require("objects.enemy")
local Resources = require("pixcof.resources")
local Boto = Enemy:extends("Boto")

function Boto:constructor(x, y)
	Enemy.constructor(self, x, y)
	self.image = Resources:getImage("boto.png")
end

function Boto:draw()
	love.graphics.draw(self.image, self.x, self.y, math.rad(self.angle), self.scale.x, self.scale.y)
end

return Boto