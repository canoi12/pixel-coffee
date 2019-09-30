local Entity = require("pixcof.entity")
local Player = Entity:extend("Player")
local SpriteComponent = require("pixcof.components.spritecomponent")

function Player:constructor(x, y)
	Entity.constructor(self, x, y)
	local spcomp = SpriteComponent(self, "knight")
	spcomp:setOrigin("center", "center")
	self:addComponent(spcomp)
end

return Player