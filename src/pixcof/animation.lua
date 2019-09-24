local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Animation = Class:extends("Animation")

function Animation:constructor(name, speed)
	self.anim = Resources:getAnimation(name)
	self.image = Resources:getImage(self.anim.image)
	self.width = self.anim.tilew
	self.height = self.anim.tileh
	self.quads = {}

	self.frame = 1
	self.speed = 1
	self.initial_speed = speed or 1
	self.currentAnimation = ""

	self.animations = {}
	for i,anim in ipairs(self.anim.animations) do
		local k = anim.name
		if self.currentAnimation == "" then
			self.currentAnimation = k
		end
		self.animations[k] = {}
		self.animations[k].start_frame = anim.stframe
		self.animations[k].end_frame = anim.enframe
	end

	self:loadQuads()
end

function Animation:loadQuads()
	for i,quad in ipairs(self.anim.quads) do
		lume.push(self.quads, love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], self.image:getDimensions()))
	end
end

function Animation:setSpeed(speed)
	self.initial_speed = speed or 1
end

function Animation:setAnimation(name)
	local keys = lume.keys(self.animations)
	if lume.find(keys, name) then
		print(name)
		self.current_animation = name
	end
end

function Animation:update(dt)
	self.speed = self.speed - (self.initial_speed * dt)
	if self.speed <= 0 then
		self.speed = 1
		self.frame = self.frame + 1
	end
	
	if self.frame > self.animations[self.currentAnimation].end_frame then
		self.frame = self.animations[self.currentAnimation].start_frame
	end
end

function Animation:draw(x, y, angle, sx, sy, cx, cy)
	x = x or 0
	y = y or 0
	angle = angle or 0
	sx = sx or 1
	sy = sy or 1
	cx = cx or 0
	cy = cy or 0
	love.graphics.draw(self.image, self.quads[self.frame+1], x, y, angle, sx, sy, cx, cy)
end

return Animation