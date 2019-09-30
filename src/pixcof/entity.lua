local Class = require("pixcof.class")
local Entity = Class:extend("Entity")

function Entity:constructor(x, y)
	self.x = x or 0
	self.y = y or 0
	self.angle = 0
	self.scale = {
		x = 1,
		y = 1
	}
	self.origin = {
		x = 0,
		y = 0
	}
	self.components = {}
	self.width = 16
	self.height = 16
	self.animation = nil
	self.image = nil
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
	lume.each(self.components, "update", dt)
end

function Entity:draw()
	--[[if self.animation and self.animation:is("Animation") then self.animation:drawEntity(self) 
	elseif self.image then lg.draw(self.image, self.x, self.y, self.angle, self.scale.x, self.scale.y, self.origin.x, self.origin.y) end]]
	lume.each(self.components, "draw")
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
	end
	love.graphics.setColor(1, 1, 1, 1)
	if active then love.graphics.setColor(lume.color("rgb(172, 50, 50)")) end
	love.graphics.rectangle("line", self.x, self.y, width*self.scale.x, height*self.scale.y)
	love.graphics.circle("fill", self.x + origin.x, self.y + origin.y, 2)
	love.graphics.setColor(1, 1, 1, 1)
end

function Entity:debug(editor)
	self.x, self.y = imgui.DragInt2("position##entity_position_" .. self.__class, self.x, self.y)
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
		editor.tilemap.camera.x = -self.x*editor.viewer.zoom + editor.viewer.width/2
		editor.tilemap.camera.y = -self.y*editor.viewer.zoom + editor.viewer.height/2
	end
				editor.map.activeEntity = self
end

function Entity:isHovering(x, y)
	local comp = self:getComponent("SpriteComponent")
	if comp then 
		self.width = comp.width
		self.height = comp.height
	end
	local xx = self.x - self.origin.x
	local yy = self.y - self.origin.y
	local ww = xx + self.width * self.scale.x
	local hh = yy + self.height * self.scale.y
	if x >= xx and x <= ww and y >= yy and y <= hh then
		return true
	end
	return false
end

return Entity