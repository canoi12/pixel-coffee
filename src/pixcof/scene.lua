local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Scene = Class:extends("Scene")

function Scene:constructor()
	self.entities = {}
	self.entities_to_add = {}
	self.entities_to_remove = {}
	self.tilemap = {}
	self.camera = {
		x = 0,
		y = 0
	}
end

function Scene:spawn(x, y, entity)
	entity.x = x or 0
	entity.y = y or 0
	lume.push(self.entities_to_add, entity)
end

function Scene:load_objects_from_map()
	if self.tilemap.entities then
		for i,entity in ipairs(self.tilemap.entities) do
			lume.push(self.entities, Resources.objects[entity.type]:new(entity.x, entity.y))
		end
	end
end

function Scene:update(dt)
	for i,entity in ipairs(self.entities) do
		entity:update(dt)
	end

	for i,entity in ipairs(self.entities_to_add) do
		lume.push(self.entities, entity)
	end

	for i,entity in ipairs(self.entities_to_remove) do
		lume.remove(self.entities, entity)
	end

	self.entities_to_add = {}
	self.entities_to_remove = {}
end

function Scene:pre_draw()
	love.graphics.push()
	love.graphics.translate(math.floor(self.camera.x), math.floor(self.camera.y))
end

function Scene:draw()
	love.graphics.print(self.name, 0, 0)

	for i,entity in ipairs(self.entities) do
		entity:draw()
	end
end

function Scene:post_draw()
	love.graphics.pop()
end

return Scene