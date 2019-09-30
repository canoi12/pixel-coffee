local Enemy = require("objects.enemy")
local Animation = require("pixcof.animation")
local SpriteComponent = require("pixcof.components.spritecomponent")
local Dolphin = Enemy:extend("Dolphin")

function Dolphin:constructor(x, y)
	self.super.constructor(self, x, y)
	local spcomp = SpriteComponent(self, "dolphin")
	spcomp:setOrigin("center", "center")
	self:addComponent(spcomp)
end

return Dolphin