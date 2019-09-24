local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")

--local Debug = require("pixcof.debug")
local Tilemap = Class:extends("Tilemap")
Tilemap.__constructors = {"load"}

local autotileref = {1,2,4,8,0,16,32,64,128}

function Tilemap:constructor(name, tileset, width, height)
	print(tileset)
	self.base = Resources:getTilemap(name) or {}

	self.name = name or "test"
	local ctileset = self.base.tileset or tileset

	self.tileset = Resources:getTileset(ctileset)  -- require("assets.tilesets." .. (self.base.tileset or tileset or "forest"))
	self.image = Resources:getImage(self.tileset.image)
	self.width = self.base.width or width or 16
	self.height = self.base.height or height or 16
	self.layers = {}
	--self.layers = self.base.layers or {}

	--self.entities = self.base.entities or {}

	--[[for i,layer in ipairs(self.layers) do
		
	end]]
	self.quads = {}

	self.camera = {
		x = 0,
		y = 0
	}


	self:loadLayers()
	self:resize()
	self:loadQuads()
	self:pushTiles()
end

function Tilemap:load(name)
	local o = setmetatable({}, { __index  = self })
	o:constructor(name)
	return o
end

function Tilemap:loadLayers()
	local layers = self.base.layers or {}
	for i,layer in ipairs(layers) do
		local llayer = self:addLayer(layer.name, layer.type)
		--print(llayer.name)
		self:loadLayer(llayer, layer)
	end
end

function Tilemap:loadLayer(layer, baselayer)
	if baselayer.type == "Entity" then
		for j,entity in ipairs(baselayer.entities) do
			self:addEntity(entity.x, entity.y, Resources.objects[entity.type]:new(), layer.name)
			--print("uau", Resources.objects[entity.type].name)
		end
	elseif baselayer.type == "Tile" then
		layer.tiles = baselayer.tiles
		layer.batch = love.graphics.newSpriteBatch(self.image, self.width * self.height)
	end
end

function Tilemap:pushTiles()
	--self.batch:clear()
	--[[for yy=1,self.height do
		local tabl = self.map[yy]
		for xx=1,self.width do
			local value = -1
			if self.map[yy] then
				value = self.map[yy][xx]
			else 
				break
			end
			if value ~= -1 and value < 256 then
				self.batch:add(self.quads[value], (xx-1)*self.tileset.tilew, (yy-1)*self.tileset.tileh)
			end
		end
	end]]
	for i,layer in ipairs(self.layers) do
		if layer.type:lower() == "tile" and self.image then
			layer.batch:clear()
			for yy=1,self.height do
				local tabl = layer.tiles[yy]
				for xx=1,self.width do
					local value = -1
					if layer.tiles[yy] then
						value = layer.tiles[yy][xx] or -1
					else 
						break
					end
					if value ~= -1 and value < 256 and self.quads[value] then
						--print(value)
						layer.batch:add(self.quads[value], (xx-1)*self.tileset.tilew, (yy-1)*self.tileset.tileh)
					end
				end
			end
		end
	end
end

function Tilemap:getEntities(layer)
	if type(layer) == "string" then 
		return lume.match(self.layers, function(x) return x.name == layer end).entities or {}
	end
	--return self.entities
end

function Tilemap:loadQuads()
	for i,quad in ipairs(self.tileset.quads or {}) do
		--print(i, quad[1], quad[2], quad[3], quad[4])
		local w, h = self.image:getDimensions()
		lume.push(self.quads, love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], w, h))
		--print(self.quads[i])
	end
end

function Tilemap:autoTile(x, y, layer, autotile_type)
	--print("ha", x, y)
	local layer = layer or 1
	local map = self.layers[layer]
	autotile_type = autotile_type or 1
	local x, y = x or 0, y or 0
	x = math.floor(x/(self.tileset.tilew))
	y = math.floor(y/(self.tileset.tileh))
	local sum = 0
	if x < 0 or x > self.width-1 then
		return
	elseif y < 0 or y > self.height-1 then
		return
	end
	if map.tiles[y+1] and map.tiles[y+1][x+1] == - 1 or map.tiles[y+1][x+1] == nil then
		return
	end

	local top, left, right, bottom = false, false, false, false
	
	-- top
	if not map.tiles[y] or (map.tiles[y] and map.tiles[y][x+1] ~= -1) then
		sum = sum + 2
		top = true
	end

	-- left
	if map.tiles[y+1] and map.tiles[y+1][x] ~= -1 then
		sum = sum + 8
		left = true
	end

	-- center
	if map.tiles[y+1] and map.tiles[y+1][x+1] ~= -1 then
		sum = sum + 0
	end

	-- right
	if map.tiles[y+1] and map.tiles[y+1][x+2] ~= -1 then
		sum = sum + 16
		right = true
	end

	-- bottom
	if not map.tiles[y+2] or (map.tiles[y+2] and map.tiles[y+2][x+1] ~= -1) then
		sum = sum + 64
		bottom = true
	end

	-- top-left
	if not map.tiles[y] or (map.tiles[y] and map.tiles[y][x] ~= -1) then
		if top and left then
			sum = sum + 1
		end
	end

	-- top-right
	if not map.tiles[y] or (map.tiles[y] and map.tiles[y][x+2] ~= -1) then
		if top and right then
			sum = sum + 4
		end
	end

	-- bottom-left
	if not map.tiles[y+2] or (map.tiles[y+2] and map.tiles[y+2][x] ~= -1) then
		if bottom and left then
			sum = sum + 32
		end
	end

	-- bottom-right
	if not map.tiles[y+2] or (map.tiles[y+2] and map.tiles[y+2][x+2] ~= -1) then
		if bottom and right then
			sum = sum + 128
		end
	end

	--[[for i=1,9 do
		local xx = math.fmod(i-1, 3)
		local yy = math.floor((i-1)/3)

		if self.map[y+1+(yy-1)] and self.map[y+1+(yy-1)][xx-1+(x+1)] ~= -1 and self.map[y+1+(yy-1)][xx-1+(x+1)] ~= nil then
			sum = sum + autotileref[i]
		end
	end]]
	--sum = math.max(sum, 1)
	--print(self.tileset.autotiles[1])
	--print(autotile_type)
	local ts,index = lume.match(self.tileset.autotiles[autotile_type], function(xx) return xx == sum end)
	--print("teste:", sum, ts, index)
	if type(index) == "table" then
		index = lume.randomchoice(index)
	end
	if index ~= nil then
		--print(index)
		if self.quads[index] then
			map.tiles[y+1][x+1] = index
		else
			map.tiles[y+1][x+1] = 1
		end
	end
end

function Tilemap:resize(width, height)
	local width = width or self.width
	local height = height or self.height
	--print(self.layers)
	for i,layer in ipairs(self.layers) do
		--print(layer)
		if layer.type:lower() == "tile" then 
			for yy=1,self.height do
				for xx=1,self.width do
					if yy > height then
						layer.tiles[yy] = nil
					end
					if xx > width then
						layer.tiles[yy][xx] = nil
					end
				end
			end
			self.width = width or 0
			self.height = height or 0
			self.width = math.max(self.width, 0)
			self.height = math.max(self.height, 0)
			for yy=1,self.height do
				for xx=1,self.width do
					if not layer.tiles[yy] then
						layer.tiles[yy] = {}
					end
					if layer.tiles[yy][xx] == nil then
						layer.tiles[yy][xx] = -1
					end
				end
			end
		end
	end
	self:pushTiles()
end

function Tilemap:insertTile(x, y, index, layer, autotile, autotile_type)
	--print(autotile_type)
	local layer = layer or 1
	local map = self.layers[layer]
	local index = index or 1
	autotile_type = autotile_type or 1
	local x, y = x or 0, y or 0
	if not map or map.type:lower() == "entity" then return end
	--x = lume.clamp(x, 0, (self.width-1)*self.tileset.tilew*2)
	--y = lume.clamp(y, 0, (self.height-1)*self.tileset.tileh*2)
	nx = math.floor(x/(self.tileset.tilew))
	ny = math.floor(y/(self.tileset.tileh))
	if nx < 0 or nx > self.width-1 then
		return
	elseif ny < 0 or ny > self.height-1 then
		return
	end
	--print(nx, ny)
	--print(map.tiles[1])
	--print(map.tiles[ny+1])
	map.tiles[ny+1][nx+1] = index
	if autotile then
		for i=1,9 do
			local xx = math.fmod(i-1, 3)
			local yy = math.floor((i-1)/3)
			--print(i, "opa", xx-1, yy-1)
			self:autoTile(x+((xx-1)*self.tileset.tilew), y + ((yy-1)*self.tileset.tileh), layer, autotile_type)
		end
	end
	self:pushTiles()
end

function Tilemap:removeTile(x, y, layer, autotile, autotile_type)
	local index = index or 1
	local layer = layer or 1
	local map = self.layers[layer]
	if map.type == "Entity" then return end
	autotile_type = autotile_type or 1
	local x, y = x or 0, y or 0

	if map.type:lower() == "entity" then return end

	nx = math.floor(x/(self.tileset.tilew))
	ny = math.floor(y/(self.tileset.tileh))
	if nx < 0 or nx > self.width-1 then
		return
	elseif ny < 0 or ny > self.height-1 then
		return
	end
	--print(x, y)
	map.tiles[ny+1][nx+1] = -1
	if autotile then
		for i=1,9 do
			local xx = math.fmod(i-1, 3)
			local yy = math.floor((i-1)/3)
			--print(i, "opa", xx-1, yy-1)
			self:autoTile(x+((xx-1)*self.tileset.tilew), y + ((yy-1)*self.tileset.tileh), layer, autotile_type)
		end
	end
	self:pushTiles()
end

function Tilemap:getObjectsInTile(x, y, entities)
	--local index = index or 1
	local x, y = x or 0, y or 0

	--print(x, y)

	nx = math.floor(x/(self.tileset.tilew))
	ny = math.floor(y/(self.tileset.tileh))
	if nx < 0 or nx > self.width-1 then
		return
	elseif ny < 0 or ny > self.height-1 then
		return
	end

	nx = nx * self.tileset.tilew
	ny = ny * self.tileset.tileh

	for i,obj in ipairs(entities) do
		--print(nx*self.tileset.tilew, ny*self.tileset.tileh, obj.x, obj.y, obj.x+obj.width, obj.y+obj.height)
		if nx >= obj.x and nx <= obj.x + obj.width and ny >= obj.y and ny <= obj.y + obj.height then
	      return obj
	    end
	end
	return nil
end

function Tilemap:addLayer(name, type, parallax, speed, wrap)
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
	layer.type = type or "Tile"
	layer.active = true
	layer.parallax_x = 0
	layer.parallax_y = 0
	layer.speed_x = 0
	layer.speed_y = 0
	layer.wrap_x = 0
	layer.wrap_y = 0
	layer.batch = love.graphics.newSpriteBatch(self.image, self.width * self.height)
	if layer.type == "Tile" then
		layer.tiles = {}
	elseif layer.type == "Entity" then
		layer.entities = {}
	end

	lume.push(self.layers, layer)
	--print(self.layers[1].name)
	self:resize()
	return layer
end

function Tilemap:removeLayer(layer)
	local retlayer = self:getLayer(layer)
	lume.remove(self.layers, retlayer)
	return retlayer
	--[[if type(layer) == "string" then
		local rlayer = lume.filter(self.layers, function(x) return x.name == layer end)
		lume.remove(self.layers, rlayer)
		return rlayer
	elseif type(layer) == "number" then
		local rlayer = self.layers[layer]
		table.remove(self.layers, layer)
		return rlayer
	end]]
end

function Tilemap:addEntity(x, y, entity, layer)
	local lyr = lume.match(self.layers, function(la) return la.type == "Entity" end) or {}
	if layer then
		local lyr = self:getLayer(layer)
		if lyr.type ~= "Entity" then return end
	end

	entity.x = x
	entity.y = y

	lume.push(lyr.entities, entity)

	return entity
end

function Tilemap:removeEntity(entity)
	for i,layer in ipairs(self.layers) do
		if layer.type == "Entity" then lume.remove(layer.entities, entity) end
	end

	return entity
end

function Tilemap:update(dt)
	for i,layer in ipairs(self.layers) do
		if layer.type == "Entity" then
			lume.each(layer.entities, "update", dt)
		end
	end
end

function Tilemap:setCameraPos(x, y)
	self.camera.x = x or 0
	self.camera.y = y or 0
end

function Tilemap:editMap(name, tileset, width, height)
	self.name = name
	self.tileset = Resources:getTileset(tileset)
	self:resize(width, height)
end

function Tilemap:getLayer(layer)
	if type(layer) == "string" then
		local layer = lume.match(self.layers, function(lyr) return lyr.name == layer end)
		return layer or {}
	elseif type(layer) == "number" then
		return self.layers[layer] or {}
	end
end

function Tilemap:drawLayer(layer)
	if not layer.active then return end
	if layer.type:lower() == "tile" then
		love.graphics.draw(layer.batch, 0, 0)
	elseif layer.type:lower() == "entity" then
		lume.each(layer.entities, "draw")
		lume.each(layer.entities, "debug")
	end
end

function Tilemap:draw()
	for i,layer in ipairs(self.layers) do
		--print(layer.type)
		if layer.type:lower() == "tile" then
			love.graphics.draw(layer.batch, 0, 0)
		elseif layer.type:lower() == "entity" then
			lume.each(layer.entities, "draw")
		end
	end
end

function Tilemap:toTable()
	local tilemap = {}
	tilemap.name = self.name
	tilemap.width = self.width
	tilemap.height = self.height
	tilemap.layers = {}
	for i,layer in ipairs(self.layers) do
		tilemap.layers[i] = self:layerToTable(layer)
	end
end

function Tilemap:layerToTable(layer)
	local rlayer = {}
	--for k,attr in ipairs()
	if layer.type == "Entity" then

	end
end

return Tilemap