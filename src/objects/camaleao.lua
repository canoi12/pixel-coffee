local Entity = require("pixcof.entity")
local Animation = require("pixcof.animation")
local SpriteComponent = require("pixcof.components.spritecomponent")
local KinematicBody = require("pixcof.components.kinematiccomponent")
local Camaleao = Entity:extend("Camaleao")

function Camaleao:constructor(x, y)
	Entity.constructor(self, x, y)
	--[[self.animation = Animation("camaleao", 4)
	self.origin.x = self.animation.width/2
	self.origin.y = self.animation.height/2
	self.width = self.animation.width
	self.height = self.animation.height]]
	local spcomp = SpriteComponent(self, "camaleao")
	spcomp:setOrigin("center", "center")
	self.animation = spcomp
	self.body = KinematicBody(self, 100)
	self:addComponent(spcomp)
	self:addComponent(self.body)
	-- body
end

function Camaleao:update(dt)
	self.super.update(self, dt)
	if lk.isDown("left") then
		self.body:move(-1, 0)
		self.animation:play("walk")
	elseif lk.isDown("right") then
		--self.x = self.x + 100 * dt
		self.body:move(1, 0)
		self.animation:play("walk")
	else
		self.animation:play("idle")
	end
end

return Camaleao