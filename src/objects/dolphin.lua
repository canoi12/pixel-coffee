local Enemy = require("objects.enemy")
local Animation = require("pixcof.animation")
local SpriteComponent = require("pixcof.components.spritecomponent")
local BoxComponent = require("pixcof.components.boxcomponent")
local Dolphin = Enemy:extend("Dolphin")

function Dolphin:constructor(x, y)
	self.super.constructor(self, x, y)
	local spcomp = SpriteComponent(self, "dolphin")
	local collider = BoxComponent(self)
	collider:setBounds(1, 7, 15, 16)
	spcomp:setOrigin("center", "center")
	self:addComponent(spcomp)
	self:addComponent(collider)
end

return Dolphin