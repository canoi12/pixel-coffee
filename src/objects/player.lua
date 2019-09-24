local Entity = require("pixcof.entity")
local Player = Entity:extends("Player")
local Animation = require("pixcof.animation")

function Player:constructor(x, y)
	Entity.constructor(self, x, y)
	self.animation = Animation:new("knight", 4)
	self.center.x = self.animation.width/2
	self.center.y = self.animation.height/2
end

function Player:update(dt)
	self.animation:update(dt)
end

function Player:draw()
	--lg.rectangle("fill", self.x, self.y, 16, 16)
	self.animation:draw(self.x, self.y, math.rad(self.angle), self.scale.x, self.scale.y, self.center.x, self.center.y)
end

return Player