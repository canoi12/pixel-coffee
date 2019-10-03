local Entity = require("pixcof.entity")
local Player = Entity:extend("Player")
local Components = require("pixcof.components")

function Player:constructor(x, y)
	Entity.constructor(self, x, y)
	local spcomp = Components.SpriteComponent(self, "knight")
	spcomp:setOrigin("center", "center")
	self:addComponent(spcomp)
	self:addComponent(Components.BoxComponent(self):setBounds(22, 30, 41, 41))
end

return Player

