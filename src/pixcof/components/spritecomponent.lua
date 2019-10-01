local Component = require("pixcof.components.component")
local Sprite = require("pixcof.types.sprite")
local Vector2 = require("pixcof.types.vector2")
local SpriteComponent = Component:extend("SpriteComponent")

local animation = ""

function SpriteComponent:constructor(entity, sprite, speed)
	Component.constructor(self, entity)
	self.sprite = Sprite(sprite, speed)
	self.origin = Vector2()
	self.width = self.sprite.width or 16
	self.height = self.sprite.height or 16
	animation = self.sprite.currentAnimation
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
	self.sprite:setAnimation(animation)
end

function SpriteComponent:update(dt)
	self.sprite:update(dt)
end

function SpriteComponent:draw()
	--print(self.entity.__class)
	self.sprite:draw(self.entity.position.x + self.origin.x, self.entity.position.y + self.origin.y, self.entity.angle, self.entity.scale.x, self.entity.scale.y, self.origin.x, self.origin.y)
end

function SpriteComponent:debug()
	self.origin.x, self.origin.y = imgui.DragInt2("origin", self.origin.x, self.origin.y)
	local change = false
	animation = imgui.InputText("animation", animation, 32)
	animation = self.sprite:setAnimation(animation) or animation
	self.sprite.initial_speed = imgui.DragInt("speed", self.sprite.initial_speed)
end

function SpriteComponent:debugDraw(active)
	love.graphics.setColor(1, 1, 1, 1)
	if active then love.graphics.setColor(lume.color("#9a4f50")) end
	lg.rectangle("line", self.entity.position.x, self.entity.position.y, self.width, self.height)
	lg.circle("fill", self.entity.position.x + self.origin.x, self.entity.position.y + self.origin.y, 2)
	lg.setColor(1, 1, 1, 1)
end

return SpriteComponent