local Enemy = require("objects.enemy")
local Resources = require("pixcof.resources")
local SpriteComponent = require("pixcof.components.spritecomponent")
local Boto = Enemy:extend("Boto")

function Boto:constructor(x, y)
	Enemy.constructor(self, x, y)
	--[[self.image = Resources:getImage("boto.png")
	self.width, self.height = self.image:getDimensions()]]
	local spcomp = SpriteComponent(self, "boto")
	spcomp:setOrigin("center", "center")
	self:addComponent(spcomp)
end

return Boto