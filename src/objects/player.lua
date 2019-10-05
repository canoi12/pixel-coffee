local Entity = require("pixcof.entity")
local Player = Entity:extend("Player")
local Components = require("pixcof.components")

function Player:constructor(x, y)
	Entity.constructor(self, x, y)
	--[[local spcomp = Components.SpriteComponent(self, "knight")
	spcomp:setOrigin("center", "center")]]
	self:addComponent(Components.SpriteComponent, "knight")
	self:addComponent(Components.BoxComponent, 20, 31, 40, 40)
end

return Player
