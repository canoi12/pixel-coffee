local Layer = require("pixcof.layers.layer")
local Resources = require "pixcof.resources"
local EntityLayer = Layer:extend("EntityLayer")

function EntityLayer:constructor(layer)
	Layer.constructor(self)
	self.entities = {}
	self.entities_to_add = {}
	self.entities_to_remove = {}
	self.name = layer
	self.active_entity = {}
	self.type = "Entity"
	if type(layer) == "table" then
		self.name = layer.name
		for i,entity in ipairs(layer.entities) do
			--print(entity.type)
			self:addEntity(entity.position.x, entity.position.y, Resources.objects[entity.type]:new())
		end
	end
end

function EntityLayer:addEntity(x, y, entity)
	entity.position.x = x or 0
	entity.position.y = y or 0
	lume.push(self.entities_to_add, entity)
end

function EntityLayer:removeEntity(entity)
	lume.push(self.entities_to_remove, entity)
end

function EntityLayer:update(dt)
	lume.each(self.entities, "update", dt)
	lume.each(self.entities_to_add, function(entity) lume.push(self.entities, entity) end)
	lume.each(self.entities_to_remove, function(entity) lume.remove(self.entities, entity) end)

	self.entities_to_remove = {}
	self.entities_to_add = {}
end

function EntityLayer:setActiveEntity(entity)
	self.active_entity = entity or {}
end

function EntityLayer:isHoveringEntity(x, y)
	local x = x or 0
	local y = y or 0
	for i,entity in ipairs(self.entities) do
		if entity:isHovering(x, y) then
			return entity, true
		end
	end
	return {}, false
end

function EntityLayer:draw()
	if self.active then
		lume.each(self.entities, "draw")
	end
end

function EntityLayer:debugEntity()
	if self.active then
		lume.each(self.entities, function(entity) 
			local active = false
			if entity == self.active_entity then active = true end
			entity:debugDraw(active)
		 end)
	end
end

function EntityLayer:toTable()
	local layer = {}
	layer.name = self.name
	layer.type = self.type
	layer.entities = {}
	for i,entity in ipairs(self.entities) do
		local ent = {}
		ent.position = entity.position
		ent.scale = entity.scale
		ent.angle = entity.angle
		ent.type = entity.__class
		lume.push(layer.entities, ent)
	end

	return layer
end

function EntityLayer:debug(editor)
	self.super.debug(self)
	if imgui.Button("x##remove_filter_object") then end
	imgui.SameLine()
	imgui.InputText("##filter_object", "", 32)

	local ww = imgui.GetWindowWidth()
	imgui.Text("Instances")
	for i,entity in ipairs(self.entities) do
		imgui.SetNextTreeNodeOpen(false)
		if editor.map.activeEntity == entity then imgui.SetNextTreeNodeOpen(true) end
		if imgui.CollapsingHeader(entity.__class .. "##entity_" .. i .. "_" .. self.name .. "_" .. entity.__class, null, "ImGuiTreeNodeFlags_Framed") then
			entity:debug(editor)
		end
	end
end


return EntityLayer