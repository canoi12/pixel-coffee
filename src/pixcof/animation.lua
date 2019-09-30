local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Animation = Class:extend("Animation")

function Animation:constructor(name, speed)
	self.anim = Resources:getAnimation(name)
	self.name = self.anim.name
	self.image = Resources:getImage(self.anim.image)
	self.width = self.anim.tilew
	self.height = self.anim.tileh
	self.quads = {}

	self.frame = 0
	self.speed = 1
	self.initial_speed = speed or 8
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
	if name == self.currentAnimation then return name end
	if lume.find(keys, name) then
		--print(name)
		self.currentAnimation = name
		self.frame = self.animations[self.currentAnimation].start_frame
		return name
	end
end

function Animation:update(dt)
	self.speed = self.speed - (self.initial_speed * dt)
	if self.speed <= 0 then
		self.speed = 1
		self.frame = self.frame + 1
	end
	
	--print(self.frame, self.animations[self.currentAnimation].end_frame)
	if self.frame > self.animations[self.currentAnimation].end_frame then
		--print(self.frame)
		self.frame = self.animations[self.currentAnimation].start_frame
	end
end

function Animation:drawEntity(entity)
	x = entity.x or 0
	y = entity.y or 0
	angle = entity.angle or 0
	sx = entity.scale.x or 1
	sy = entity.scale.y or 1
	cx = entity.origin.x or 0
	cy = entity.origin.y or 0
	love.graphics.draw(self.image, self.quads[self.frame+1], x, y, angle, sx, sy, cx, cy)
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

function Animation:toTable()
	local anim = {}
	anim.name = self.name
	anim.tilew = self.width
	anim.tileh = self.height
	anim.image = self.anim.image
	anim.quads = self.anim.quads
	anim.animations = self.anim.animations
	return anim
end

function Animation:generateTable(animation)
	local anim = {}
	anim.name = animation.name
	anim.tilew = animation.width
	anim.tileh = animation.height
	anim.image = animation.image
	anim.quads = animation.quads or {}
	anim.animations = animation.animations or {}
	return anim
end

return Animation