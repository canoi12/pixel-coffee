local Enemy = require("objects.enemy")
local Rabbit = Enemy:extend("Rabbit")

function Rabbit:constructor(x, y)
	self.super.constructor(self, x, y)
	self:addComponent(pixcof.Components.SpriteComponent, "rabbit")
end

return Rabbit
