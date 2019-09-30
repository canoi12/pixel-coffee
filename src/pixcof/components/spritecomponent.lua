local Component = require("pixcof.components.component")
local Animation = require("pixcof.animation")
local SpriteComponent = Component:extend("SpriteComponent")

local animation = ""

function SpriteComponent:constructor(entity, animation, speed)
	Component.constructor(self, entity)
	self.animation = Animation(animation, speed or 8)
	self.origin = {
		x = 0,
		y = 0
	}
	self.width = self.animation.width
	self.height = self.animation.height
	animation = self.animation.currentAnimation
end

function SpriteComponent:setOrigin(vertical, horizontal)
	if type(vertical) == "string" then
		if vertical == "center" then
			self.origin.y = self.height/2
		elseif vertical == "top" then
			self.origin.y = 0
		elseif vertical == "bottom" then
			self.origin.y = self.height
		end
	elseif type(vertical) == "number" then
		self.origin.y = vertical
	end

	if type(horizontal) == "string" then
		if horizontal == "center" then
			self.origin.x = self.width/2
		elseif horizontal == "left" then
			self.origin.x = 0
		elseif horizontal == "right" then
			self.origin.x = self.width
		end
	elseif type(horizontal) == "number" then
		self.origin.x = horizontal
	end
end

function SpriteComponent:play(animation)
	self.animation:setAnimation(animation)
end

function SpriteComponent:update(dt)
	self.animation:update(dt)
end

function SpriteComponent:draw()
	self.animation:draw(self.entity.x + self.origin.x, self.entity.y + self.origin.y, self.entity.angle, self.entity.scale.x, self.entity.scale.y, self.origin.x, self.origin.y)
end

function SpriteComponent:debug()
	self.origin.x, self.origin.y = imgui.DragInt2("origin", self.origin.x, self.origin.y)
	local change = false
	animation = imgui.InputText("animation", animation, 32)
	animation = self.animation:setAnimation(animation) or animation
	self.animation.initial_speed = imgui.DragInt("speed", self.animation.initial_speed)
end

return SpriteComponent