local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Scene = Class:extends("Scene")
local Tilemap = require("pixcof.tilemap")

function Scene:constructor(tilemap)
	self.entities = {}
	self.entities_to_add = {}
	self.entities_to_remove = {}
	self.tilemap = Tilemap:load(tilemap)

	self.layers = self.tilemap.layers
	--self:load_objects_from_map()
	self.camera = {
		x = 0,
		y = 0
	}
end

function Scene:spawn(x, y, entity, layer)
	if not entity then return end
	entity.x = x or 0
	entity.y = y or 0
	--lume.push(self.entities_to_add, entity)
	lume.push(self.entities_to_add[layer], entity)
end

function Scene:destroy(entity)
	--self.entities_to_remove = {}
	--[[for i,ent in ipairs(self.entities) do
		if self.entity == entity then
			self.entities_to_remove = entity
		end
	end]]
	lume.push(self.entities_to_remove, entity)
end

function Scene:loadLayers()
	for i,layer in ipairs(self.layers) do
		self.layer[i] = layer
	end
end

--[[function Scene:load_objects_from_map()
	self.entities = {}
	for i,layer in ipairs(self.tilemap.layers) do
		if layer.entities then
			for j,entity in ipairs(layer.entities) do
				lume.push(self.entities, Resources.objects[entity.type]:new(entity.x, entity.y))
			end
		end
	end
end]]

function Scene:update(dt)
	self.entities = {}
	for i,layer in ipairs(self.layers) do
		if layer.type == "Entity" then
			lume.map(layer.entities, function(x) lume.push(self.entities, x) end)
			--self.entities[layer.name] = layer.entities
		end
	end

	for i,entity in ipairs(self.entities) do
		entity:update(dt)
	end

	for k,entities in pairs(self.entities_to_add) do
		--lume.push(self.entities, entity)
		lume.map(entities, function(ent) self.tilemap:addEntity(ent.x, ent.y, ent, k) end)
	end

	for i,entity in ipairs(self.entities_to_remove) do
		--lume.remove(self.entities, entity)
		self.tilemap:removeEntity(entity)
	end

	self.entities_to_add = {}
	self.entities_to_remove = {}
	--self.entities = {}
	--self.tilemap:update(dt)
end

function Scene:pre_draw()
	love.graphics.push()
	love.graphics.translate(math.floor(self.camera.x), math.floor(self.camera.y))
end

function Scene:draw()
	love.graphics.print(self.name, 0, 0)

	--[[if self.tilemap then
		self.tilemap:draw()
	end]]

	--[[for i,entity in ipairs(self.entities) do
		entity:draw()
	end]]
	for i,layer in ipairs(self.layers) do 
		self.tilemap:drawLayer(layer)
	end
end

function Scene:post_draw()
	love.graphics.pop()
end

return Scene