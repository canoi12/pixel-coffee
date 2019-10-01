local Entity = require("pixcof.entity")
local SpriteComponent = require("pixcof.components.spritecomponent")
local SpriteObject = Entity:extend("SpriteObject")

function SpriteObject:constructor(x, y, image)
	self.super.constructor(self, x, y)
	self.name = image
	self:addComponent(SpriteComponent(self, image))
end

return SpriteObject