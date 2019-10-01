local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local Vector2 = require("pixcof.types.vector2")
local Entity = Class:extend("Entity")

function Entity:constructor(x, y)
	self.position = Vector2(x, y)
	self.angle = 0
	self.scale = Vector2(1, 1)
	self.components = {}
	self.width = 16
	self.height = 16
	self.animation = nil
	self.image = nil
	self.active = true
	--[[self.centerx = 0
	self.centery = 0]]
end

function Entity:addComponent(component)
	lume.push(self.components, component)
end

function Entity:getComponent(componentType)
	for i,component in ipairs(self.components) do
		if component:is(componentType) then return component end
	end
	return nil
end

function Entity:removeComponent(component)
	if type(component) == "string" then
		local comp = self:getComponent(component)
		lume.remove(self.components, comp)
		return
	end
	lume.remove(self.components, component)
end

function Entity:update(dt)
	--if self.animation and self.animation:is("Animation") then self.animation:update(dt) end
	if self.active then
		lume.each(self.components, "update", dt)
	end
end

function Entity:draw()
	--[[if self.animation and self.animation:is("Animation") then self.animation:drawEntity(self) 
	elseif self.image then lg.draw(self.image, self.x, self.y, self.angle, self.scale.x, self.scale.y, self.origin.x, self.origin.y) end]]
	if self.active then
		lume.each(self.components, "draw")
	end
end

function Entity:debugDraw(active)
	--[[local image = {32, 32}
	if not self.width or not self.height then
		if self.animation then image = {self.animation.width, self.animation.height}
		elseif self.image then image = {self.image:getDimensions()} end
		print(image[1], image[2])
		self.width = image[1]
		self.height = image[2]
	end]]
	local origin = {
		x = 0,
		y = 0
	}
	local width = self.width or 32
	local height = self.height or 32
	local comp = self:getComponent("SpriteComponent")
	if comp then
		origin = comp.origin
		width, height = comp.width, comp.height
	else
		love.graphics.setColor(1, 1, 1, 1)
		if active then love.graphics.setColor(lume.color("#9a4f50")) end
		love.graphics.rectangle("line", self.position.x, self.position.y, width*self.scale.x, height*self.scale.y)
		--love.graphics.circle("fill", self.x + origin.x, self.y + origin.y, 2)
		lg.draw(Resources:getImage("pixcof-2"), self.position.x, self.position.y, self.angle, self.scale.x, self.scale.y)
		love.graphics.setColor(1, 1, 1, 1)
	end

	for i,component in ipairs(self.components) do
		component:debugDraw(active)
	end
end

function Entity:debug(editor)
	self.active = imgui.Checkbox("active##entity_active_" .. self.__class, self.active)
	self.position.x, self.position.y = imgui.DragInt2("position##entity_position_" .. self.__class, self.position.x, self.position.y)
	local angle = math.deg(self.angle)
	angle = imgui.DragInt("angle##entity_angle_" .. self.__class, angle)
	self.angle = math.rad(angle)
	self.scale.x, self.scale.y = imgui.DragFloat2("scale##entity_scale_" .. self.__class, self.scale.x, self.scale.y)
	--imgui.Indent()
	if imgui.TreeNode("Components") then
		for i,v in ipairs(self.components) do
			if imgui.TreeNode(v.__class) then
				v:debug()
				imgui.TreePop()
			end
		end
		imgui.TreePop()
	end
	if editor.map.activeEntity ~= self then
		editor.tilemap.camera.x = -self.position.x*editor.viewer.zoom + editor.viewer.width/2
		editor.tilemap.camera.y = -self.position.y*editor.viewer.zoom + editor.viewer.height/2
	end
	editor.map.activeEntity = self
end

function Entity:isHovering(x, y)
	local comp = self:getComponent("SpriteComponent")
	if comp then 
		self.width = comp.width
		self.height = comp.height
	end
	local xx = self.position.x
	local yy = self.position.y
	local ww = xx + self.width
	local hh = yy + self.height
	if x >= xx and x <= ww and y >= yy and y <= hh then
		return true
	end
	return false
end

return Entity