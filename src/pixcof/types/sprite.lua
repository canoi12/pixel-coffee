local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Sprite = Class:extend("Sprite")

function Sprite:constructor(name, speed)
	self.anim = Resources:getSprite(name)
	self.name = self.anim.name or ""
	self.image = Resources:getImage(self.anim.image)
	self.width = self.anim.tilew
	self.height = self.anim.tileh
	self.quads = {}

	self.frame = 0
	self.speed = 1
	self.initial_speed = speed or 8
	self.currentAnimation = ""

	self.animations = {}
	for i,anim in ipairs(self.anim.animations or {}) do
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

function Sprite:loadQuads()
	if not self.anim.quads then
		lume.push(self.quads, lg.newQuad(0, 0, 16, 16, 16, 16))
		return
	end
	for i,quad in ipairs(self.anim.quads or {}) do
		lume.push(self.quads, love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], self.image:getDimensions()))
	end
end

function Sprite:setSpeed(speed)
	self.initial_speed = speed or 8
end

function Sprite:setAnimation(name)
	local keys = lume.keys(self.animations)
	if name == self.currentAnimation then return name end
	if lume.find(keys, name) then
		--print(name)
		self.currentAnimation = name
		self.frame = self.animations[self.currentAnimation].start_frame
		return name
	end
end

function Sprite:update(dt)
	self.speed = self.speed - (self.initial_speed * dt)
	if self.speed <= 0 then
		self.speed = 1
		self.frame = self.frame + 1
	end
	
	--print(self.frame, self.animations[self.currentAnimation].end_frame)
	if self.animations[self.currentAnimation] and self.frame > self.animations[self.currentAnimation].end_frame then
		--print(self.frame)
		self.frame = self.animations[self.currentAnimation].start_frame
	end
end

function Sprite:drawEntity(entity)
	x = entity.x or 0
	y = entity.y or 0
	angle = entity.angle or 0
	sx = entity.scale.x or 1
	sy = entity.scale.y or 1
	cx = entity.origin.x or 0
	cy = entity.origin.y or 0
	local quad = self.quads[self.frame+1] or self.quads[1]
	love.graphics.draw(self.image, quad, x, y, angle, sx, sy, cx, cy)
end

function Sprite:draw(x, y, angle, sx, sy, cx, cy)
	x = x or 0
	y = y or 0
	angle = angle or 0
	sx = sx or 1
	sy = sy or 1
	cx = cx or 0
	cy = cy or 0
	local quad = self.quads[self.frame+1] or self.quads[1]
	--print(self.__class, quad)
	love.graphics.draw(self.image, quad, x, y, angle, sx, sy, cx, cy)
end

function Sprite:toTable()
	local anim = {}
	anim.name = self.name
	anim.tilew = self.width
	anim.tileh = self.height
	anim.image = self.anim.image
	anim.quads = self.anim.quads
	anim.animations = self.anim.animations
	return anim
end

function Sprite:generateTable(animation)
	local anim = {}
	anim.name = animation.name
	anim.tilew = animation.width
	anim.tileh = animation.height
	anim.image = animation.image
	anim.quads = animation.quads or {}
	anim.animations = animation.animations or {}
	return anim
end

return Sprite