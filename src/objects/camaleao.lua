local Entity = require("pixcof.entity")
local Animation = require("pixcof.animation")
local Components = require("pixcof.components")
local Camaleao = Entity:extend("Camaleao")

function Camaleao:constructor(x, y)
	Entity.constructor(self, x, y)
	--[[self.animation = Animation("camaleao", 4)
	self.origin.x = self.animation.width/2
	self.origin.y = self.animation.height/2
	self.width = self.animation.width
	self.height = self.animation.height]]
	--[[local spcomp = Components.SpriteComponent(self, "camaleao")
	spcomp:setOrigin("center", 18)
	self.animation = spcomp
	local collider = Components.BoxComponent(self)
	collider:setBounds(7, 16, 26, 26)
	self.body = Components.KinematicComponent(self, 100)]]
	self:addComponent(Components.SpriteComponent, "camaleao", "center", "center")
	self.animation = self:getComponent("SpriteComponent")
	self:addComponent(Components.KinematicComponent)
	self.body = self:getComponent("KinematicComponent")
	self:addComponent(Components.BoxComponent, 10, 16, 24, 27)
	--self:addComponent(self.body)
	--self:addComponent(collider)
	-- body
end

function Camaleao:update(dt)
	self.super.update(self, dt)
	if lk.isDown("left") then
		self.body:move(-1, 0)
		self.animation:play("walk")
		self.scale.x = -1
	elseif lk.isDown("right") then
		--self.x = self.x + 100 * dt
		self.body:move(1, 0)
		self.animation:play("walk")
		self.scale.x = 1
	else
		self.animation:play("idle")
	end
end

return Camaleao

