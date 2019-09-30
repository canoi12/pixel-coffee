local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local Scene = Class:extend("Scene")
local Tilemap = require("pixcof.tilemap")
local Layers = require("pixcof.layers")

function Scene:constructor(ctilemap)
	self.entities = {}
	self.entities_to_add = {}
	self.entities_to_remove = {}
	--self.tilemap = Tilemap:load(tilemap)
	local tilemap = ctilemap
	if type(ctilemap) == "string" then
		tilemap = Resources:getTilemap(ctilemap)
	end
	--print(tilemap.tileset, "baka")
	self.name = tilemap.name
	self.width = tilemap.width
	self.height = tilemap.height
	self.tilew = 16
	self.tileh = 16
	self.layers = {}
	self.camera = {
		x = 0,
		y = 0
	}

	--self.layers = self.tilemap.layers
	for i,layer in ipairs(tilemap.layers) do
		if layer.type == "Entity" then
			lume.push(self.layers, Layers.EntityLayer:new(layer))
		elseif layer.type == "Tile" then
			--print(layer.tileset)
			lume.push(self.layers, Layers.TilemapLayer:load(self, layer))
		elseif layer.type == "Background" then
			lume.push(self.layers, Layers.BackgroundLayer:load(self, layer))
		end
	end
	--self:load_objects_from_map()
	self.camera = {
		x = 0,
		y = 0
	}
end

function Scene:insertTile(x, y, index, layer, autotile, autotile_type)
	local clayer = {}
	if type(layer) == "string" then clayer = lume.match(self.layers, function(x) return x.name == layer end)
	elseif type(layer) == "number" then clayer = self.layers[layer]
	elseif type(layer) == "table" then clayer = layer end
	if clayer.type ~= "Tile" then return end

	clayer:insertTile(x, y, index, autotile, autotile_type)
end

function Scene:removeTile(x, y, layer, autotile, autotile_type)
	local clayer = {}
	if type(layer) == "string" then clayer = lume.match(self.layers, function(x) return x.name == layer end)
	elseif type(layer) == "number" then clayer = self.layers[layer]
	elseif type(layer) == "table" then clayer = layer end
	if clayer.type ~= "Tile" then return end

	clayer:removeTile(x, y, autotile, autotile_type)
end

function Scene:upLayer(layer)
	print(layer)
	if not layer then return end
	local index = self:getLayerIndex(layer)
	if index <= 1 then
		return index
	end
	local aux = self.layers[index-1]
	self.layers[index-1] = self.layers[index]
	self.layers[index] = aux

	return index-1
end

function Scene:downLayer(layer)
	print(layer)
	if not layer then return end
	local index = self:getLayerIndex(layer)
	if index >= #self.layers then
		return index
	end
	local aux = self.layers[index+1]
	self.layers[index+1] = self.layers[index]
	self.layers[index] = aux

	return index+1
end

function Scene:addEntity(x, y, entity, layer)
	local clayer = {}
	if type(layer) == "string" then clayer = lume.match(self.layers, function(x) return x.name == layer end)
	elseif type(layer) == "number" then clayer = self.layers[layer]
	elseif type(layer) == "table" then clayer = layer end
	if clayer.type ~= "Entity" then return end

	clayer:addEntity(x, y, entity)
end

function Scene:removeEntity(entity, layer)
	local clayer = {}
	if type(layer) == "string" then clayer = lume.match(self.layers, function(x) return x.name == layer end)
	elseif type(layer) == "number" then clayer = self.layers[layer]
	elseif type(layer) == "table" then clayer = layer end
	if clayer.type ~= "Entity" then return end

	clayer:removeEntity(entity)
end

function Scene:destroy(entity)
	for i,layer in ipairs(self.layers) do
		self:removeEntity(entity, layer)
	end
end

function Scene:addLayer(name, type, opt)
	local opt = opt or {}
	layer = {}
	layer.name = name or "Layer"
	--local names = lume.filter(self.layers, function(x) print(x.name) return x.name == name end)
	local cname = layer.name
	local index = 1
	while lume.any(self.layers, function(x) return x.name == cname end) do
		cname = layer.name .. " (" .. index .. ")"
		index = index + 1
	end
	layer.name = cname
	--[[if lume.count(names) > 0 then
		layer.name = name .. " (" .. #names .. ")"
	end]]
	local layer_obj = {}
	layer.type = type or "Tile"
	if layer.type == "Tile" then
		layer_obj = self:newTileLayer(layer.name, opt.tileset or "forest")
	elseif layer.type == "Entity" then
		layer_obj = self:newEntityLayer(layer.name)
	elseif layer.type == "Background" then
		layer_obj = self:newBackgroundLayer(layer.name, opt.color, opt.image)
	end

	--lume.push(self.layers, layer)
	--print(self.layers[1].name)
	--self:resize()
	return layer_obj
end

function Scene:newTileLayer(name, tileset)
	local layer = {}
	layer.name = name or "Layer"
	local cname = layer.name
	local index = 1
	while lume.any(self.layers, function(x) return x.name == cname end) do
		cname = layer.name .. " (" .. index .. ")"
		index = index + 1
	end
	layer.name = cname
	layer.type = "Tile"

	local layer_obj = Layers.TilemapLayer:new(self, layer.name, tileset)
	lume.push(self.layers, layer_obj)

	return layer_obj
end

function Scene:newEntityLayer(name)
	local layer = {}
	layer.name = name or "Layer"
	local cname = layer.name
	local index = 1
	while lume.any(self.layers, function(x) return x.name == cname end) do
		cname = layer.name .. " (" .. index .. ")"
		index = index + 1
	end
	layer.name = cname

	local layer_obj = Layers.EntityLayer:new(layer.name)
	lume.push(self.layers, layer_obj)

	return layer_obj
end

function Scene:newBackgroundLayer(name, color, image)
	local layer = {}
	layer.name = name or "Layer"
	local cname = layer.name
	local index = 1
	while lume.any(self.layers, function(x) return x.name == cname end) do
		cname = layer.name .. " (" .. index .. ")"
		index = index + 1
	end
	layer.name = cname

	local layer_obj = Layers.BackgroundLayer(self, layer.name, color, image)
	lume.push(self.layers, layer_obj)

	return layer_obj
end

function Scene:removeLayer(layer)
	local retlayer = self:getLayer(layer)
	lume.remove(self.layers, retlayer)
	return retlayer
end

function Scene:getLayer(layer)
	if type(layer) == "string" then
		local layer = lume.match(self.layers, function(lyr) return lyr.name == layer end)
		return layer or {}
	elseif type(layer) == "number" then
		return self.layers[layer] or {}
	end
	return layer
end

function Scene:getLayerIndex(layer)
	if type(layer) == "string" then
		local layer, index = lume.match(self.layers, function(lyr) return lyr.name == layer end)
		return index or 1
	elseif type(layer) == "number" then
		return layer or 1
	end
	print(layer)
	local layer, index = lume.match(self.layers, function(lyr) return lyr.name == layer.name end)
	return index or 1
end

function Scene:loadLayers()
	for i,layer in ipairs(self.layers) do
		self.layer[i] = layer
	end
end

function Scene:getEntities()
	local entities = {}
	for i,layer in ipairs(self.layers) do
		if layer.type == "Entity" then
			lume.each(layer.entities, function(entity) lume.push(entities, entity) end)
		end
	end

	return entities
end

function Scene:update(dt)
	--[[self.entities = {}
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
	self.entities_to_remove = {}]]
	for i,layer in ipairs(self.layers) do
		layer:update(dt)
		--if layer.type == "Tile" then layer:resize(self.width, self.height) end
	end
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
	--[[for i,layer in ipairs(self.layers) do 
		self.tilemap:drawLayer(layer)
	end]]
	for i,layer in ipairs(self.layers) do
		layer:draw()
	end
end

function Scene:post_draw()
	love.graphics.pop()
end

function Scene:toTable()
	local scene = {}
	scene.name = self.name
	scene.width = self.width
	scene.height = self.height
	scene.tilew = self.tilew
	scene.tileh = self.tileh
	scene.layers = {}
	for i,layer in ipairs(self.layers) do
		lume.push(scene.layers, layer:toTable())
	end

	return scene
end

function Scene:generateTable(map)
	local scene = {}
	scene.name = map.name
	scene.width = map.width
	scene.height = map.height
	scene.tilew = 16
	scene.tileh = 16
	scene.layers = {}
	return scene
end

return Scene