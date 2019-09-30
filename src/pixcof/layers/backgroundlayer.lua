local Layer = require("pixcof.layers.layer")
local Resources = require("pixcof.resources")
local BackgroundLayer = Layer:extend("BackgroundLayer")

function BackgroundLayer:constructor(scene, layer, color, image)
	Layer.constructor(self, scene)
	self.type = "Background"
	self.name = layer.name or layer
	self.color = layer.color or color or {1, 1, 1, 1}
	self.imageName = layer.image or image
	self.image = Resources:getImage(self.imageName)
	self.x = 0
	self.y = 0
	self.parallax = layer.parallax or {x=0, y=0}

	self.speed = layer.speed or {x=0, y=0}
end

function BackgroundLayer:load(scene, layer)
	local o = setmetatable({}, { __index  = self })
	o:constructor(scene, layer)
	return o
end

function BackgroundLayer:setColor(color)
	self.color = color
end

function BackgroundLayer:draw()
	if self.active then
		lg.setColor(self.color)
		lg.rectangle("fill", 0, 0, self.scene.width, self.scene.height)
		lg.setColor(1, 1, 1, 1)
		if self.image then
			lg.draw(self.image, self.x, self.y)
		end
	end
end

function BackgroundLayer:debug()
	self.super.debug(self)
	self.color = {imgui.ColorEdit4("color", self.color[1], self.color[2], self.color[3], self.color[4])}
	local keys = lume.keys(Resources.images)
	local index = lume.find(keys, self.imageName) or 0
	--print(self.imageName)
	if imgui.SmallButton("x##remove_bglayer_image") then 
		index = 0 
		self.image = nil
	end
	imgui.SameLine()
	index,changed = imgui.Combo("image", index, keys, #keys)
	self.imageName = keys[index]
	if changed then
		self.image = Resources:getImage(self.imageName)
	end

	self.parallax.x, self.parallax.y = imgui.InputInt2("parallax", self.parallax.x, self.parallax.y)
	self.speed.x, self.speed.y = imgui.InputInt2("speed", self.speed.x, self.speed.y)
end

function BackgroundLayer:toTable()
	local layer = {}
	layer.name = self.name
	layer.type = self.type
	layer.color = self.color
	layer.color[5] = nil
	layer.image = self.imageName
	layer.parallax = self.parallax
	layer.speed = self.speed

	return layer
end

return BackgroundLayer