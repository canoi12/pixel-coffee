local Layer = require("pixcof.layers.layer")
local SpriteObject = require("pixcof.types.spriteobject")
local SpriteLayer = Layer:extend("SpriteLayer")

function SpriteLayer:constructor(scene, layer)
	self.super.constructor(self, scene)
	self.name = layer.name or layer
	self.type = "Sprite"
	self.sprites = {}
	if layer.sprites then
		for i,v in ipairs(layer.sprites) do
			self:addSprite(v.x, v.y, v.name)
		end
	end
end

function SpriteLayer:addSprite(x, y, sprite)
	if type(sprite) == "string" then
		local spr = SpriteObject(x, y, sprite) 
		lume.push(self.sprites, spr)
		return spr
	end
end

function SpriteLayer:removeSprite(sprite)
	lume.remove(self.sprites, sprite)
end

function SpriteLayer:update(dt)
	lume.each(self.sprites, "update", dt)
end

function SpriteLayer:draw()
	lume.each(self.sprites, "draw")
end

function SpriteLayer:toTable()
	local layer = {}
	layer.name = self.name
	layer.type = self.type
	layer.sprites = {}
	for i,v in ipairs(self.sprites) do
		lume.push(layer.sprites, {x=v.x, y=v.y, name=v.name})
	end

	return layer
end

return SpriteLayer