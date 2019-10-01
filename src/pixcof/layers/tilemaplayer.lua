local Layer = require("pixcof.layers.layer")
local Resources = require("pixcof.resources")
local Tileset = require("pixcof.tileset")
local TilemapLayer = Layer:extend("TilemapLayer")

function TilemapLayer:constructor(scene, layer, tileset)
	Layer.constructor(self, scene)
	self.tiles = {}
	self.type = "Tile"
	self.name = layer.name or layer or ""
	--print(tileset, "opaopa")
	local tileset = layer.tileset or tileset
	self.tileset = Tileset(Resources:getTileset(tileset))
	--print(Tileset)



	self.image = self.tileset.image
	self.width = self.scene.width
	self.height = self.scene.height
	self.mapsize = {
		x = self.width,
		y = self.height
	}
	self.tiles = layer.tiles or {}
	self.quads = {}
	--print(self.tiles)
	--print(lume.count(self.tiles))
	--print(lume.count(self.tileset.autotiles[1]))

	--self.width = math.floor(self.width/self.tileset.tilew)
	--self.height = math.floor(self.height/self.tileset.tileh)
	self.quads = self.tileset.quads
	self.batch = love.graphics.newSpriteBatch(self.image)

	--self:loadQuads()
	self:resize()

	self:pushTiles()
end

function TilemapLayer:load(scene, layer)
	local o = setmetatable({}, { __index  = self })
	o:constructor(scene, layer)
	return o
end

function TilemapLayer:pushTiles()
	self.batch:clear()
	for yy=1,self.height do
		local tabl = self.tiles[yy]
		for xx=1,self.width do
			local value = -1
			if self.tiles[yy] then
				value = self.tiles[yy][xx] or -1
			else 
				break
			end
			if value ~= -1 and value < 256 and self.quads[value] then
				--print(value)
				self.batch:add(self.quads[value], (xx-1)*self.tileset.tilew, (yy-1)*self.tileset.tileh)
			end
		end
	end
end

function TilemapLayer:loadQuads()
	for i,quad in ipairs(self.tileset.quads or {}) do
		--print(i, quad[1], quad[2], quad[3], quad[4])
		local w, h = self.image:getDimensions()
		lume.push(self.quads, love.graphics.newQuad(quad[1], quad[2], quad[3], quad[4], w, h))
		--print(self.quads[i])
	end
end

function TilemapLayer:autoTile(x, y, autotile_type)

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
	if self.tiles[y+1] and self.tiles[y+1][x+1] == - 1 or self.tiles[y+1][x+1] == nil then
		return
	end

	local top, left, right, bottom = false, false, false, false
	
	-- top
	if not self.tiles[y] or (self.tiles[y] and self.tiles[y][x+1] ~= -1) then
		sum = sum + 2
		top = true
	end

	-- left
	if self.tiles[y+1] and self.tiles[y+1][x] ~= -1 then
		sum = sum + 8
		left = true
	end

	-- center
	if self.tiles[y+1] and self.tiles[y+1][x+1] ~= -1 then
		sum = sum + 0
	end

	-- right
	if self.tiles[y+1] and self.tiles[y+1][x+2] ~= -1 then
		sum = sum + 16
		right = true
	end

	-- bottom
	if not self.tiles[y+2] or (self.tiles[y+2] and self.tiles[y+2][x+1] ~= -1) then
		sum = sum + 64
		bottom = true
	end

	-- top-left
	if not self.tiles[y] or (self.tiles[y] and self.tiles[y][x] ~= -1) then
		if top and left then
			sum = sum + 1
		end
	end

	-- top-right
	if not self.tiles[y] or (self.tiles[y] and self.tiles[y][x+2] ~= -1) then
		if top and right then
			sum = sum + 4
		end
	end

	-- bottom-left
	if not self.tiles[y+2] or (self.tiles[y+2] and self.tiles[y+2][x] ~= -1) then
		if bottom and left then
			sum = sum + 32
		end
	end

	-- bottom-right
	if not self.tiles[y+2] or (self.tiles[y+2] and self.tiles[y+2][x+2] ~= -1) then
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
	--print(autotile_type)
	local ts = lume.filter(self.tileset.autotiles[autotile_type], function(xx) return xx == sum end, true)
	local index = 1
	local keys = lume.keys(ts)
	index = lume.randomchoice(keys)
	
	if index ~= nil then
		--print(index)
		if self.quads[index] then
			self.tiles[y+1][x+1] = index
		else
			self.tiles[y+1][x+1] = 1
		end
	end
end

function TilemapLayer:resize()

	local aux = {
		math.floor(self.scene.width/self.tileset.tilew),
		math.floor(self.scene.height/self.tileset.tileh)
	}


	--print("opora")

	--print(self.width, self.height, width, height)

	for yy=1,self.height do
		for xx=1,self.width do
			if yy > aux[2] then
				self.tiles[yy] = nil
			end
			if xx > aux[1] then
				if self.tiles[yy] then
					self.tiles[yy][xx] = nil
				end
			end
		end
	end

	self.width = math.floor(self.scene.width/self.tileset.tilew)
	self.height = math.floor(self.scene.height/self.tileset.tileh)

	for yy=1,self.height do
		for xx=1,self.width do
			if not self.tiles[yy] then
				self.tiles[yy] = {}
			end
			if self.tiles[yy][xx] == nil then
				self.tiles[yy][xx] = -1
			end
		end
	end

	self:pushTiles()
end

function TilemapLayer:insertTile(x, y, index, autotile, autotile_type)
	--print(autotile_type)
	local map = self
	local index = index or 1
	autotile_type = autotile_type or 1
	local x, y = x or 0, y or 0
	--if not map or map.type:lower() == "entity" then return end
	--x = lume.clamp(x, 0, (self.width-1)*self.tileset.tilew*2)
	--y = lume.clamp(y, 0, (self.height-1)*self.tileset.tileh*2)
	nx = math.floor(x/(self.tileset.tilew))
	ny = math.floor(y/(self.tileset.tileh))
	if nx < 0 or nx > self.width-1 then
		return
	elseif ny < 0 or ny > self.height-1 then
		return
	end

	map.tiles[ny+1][nx+1] = index
	if autotile then
		for i=1,9 do
			local xx = math.fmod(i-1, 3)
			local yy = math.floor((i-1)/3)
			self:autoTile(x+((xx-1)*self.tileset.tilew), y + ((yy-1)*self.tileset.tileh), autotile_type)
		end
	end
	self:pushTiles()
end

function TilemapLayer:removeTile(x, y, autotile, autotile_type)
	local index = index or 1
	local map = self
	--if map.type == "Entity" then return end
	autotile_type = autotile_type or 1
	local x, y = x or 0, y or 0

	--if map.type:lower() == "entity" then return end

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
			self:autoTile(x+((xx-1)*self.tileset.tilew), y + ((yy-1)*self.tileset.tileh), autotile_type)
		end
	end
	self:pushTiles()
end

function TilemapLayer:changeTileset(tileset)
	if tileset ~= self.tileset.name then
		local tset = Resources:getTileset(tileset)
		self.tileset = Tileset(tset)
		self.quads = self.tileset.quads
		self.batch = lg.newSpriteBatch(self.tileset.image)
		self:pushTiles()
	end
end

function TilemapLayer:update(dt)
	--[[self.width = self.scene.width/(self.tileset.tilew or 16)
	self.height = self.scene.height/(self.tileset.tileh or 16)]]
	self:resize()
end

function TilemapLayer:draw()
	--print("tile")
	if self.active then
		love.graphics.draw(self.batch)
	end
end

function TilemapLayer:toTable()
	local layer = {}
	layer.name = self.name
	layer.type = self.type
	layer.quads = {}
	for i,quad in ipairs(self.quads) do
		lume.push(layer.quads, {quad:getViewport()})
	end
	layer.tileset = self.tileset.name
	layer.tiles = self.tiles

	return layer
end

function TilemapLayer:debug(editor)
	self.super.debug(self)
	--local tileset = self.tilemap.tileset
	--local layer = self.tilemap.layers[self.currentLayer]
	--if not layer then return end
	--if layer.type ~= "Tile" then return end
	local keys = lume.keys(Resources.tilesets)
	local index = lume.find(keys, self.tileset.name)
	index = imgui.Combo("tilesets##layer_select_tileset", index, keys, #keys)
	self:changeTileset(keys[index])

	local layer = self
	local tileset = layer.tileset
	--local image = Resources:getImage(tileset.image)
	local image = layer.tileset.image
	local imagew, imageh = image:getDimensions()
	local maxtilew = image:getWidth()/tileset.tilew
	local maxtileh = image:getHeight()/tileset.tileh

	local ww = imgui.GetWindowWidth()
	local tab_open = imgui.BeginTabBar("tiles tab") 
	if tab_open then
		if imgui.BeginTabItem("Tiles") then
			for i,qquad in ipairs(tileset.quads) do
				--print(quad)
				local quad = {qquad:getViewport()}
				local xx = quad[1]/imagew
				local yy = quad[2]/imageh
				local ww = quad[3]/imagew
				local hh = quad[4]/imageh

				if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
					editor.map.currentTile = i
					editor.map.autotile = false
				end
				imgui.SameLine()
				if math.fmod(i, 4) == 0 then
					imgui.NewLine()
				end
			end
			imgui.EndTabItem()
		end

		if imgui.BeginTabItem("AutoTiles") then
			for i,v in ipairs(tileset.autotiles) do
				local _,index = lume.match(v, function(x) return x ~= -1 end)
				if lume.any(v, function(x) return x == 0 end) then
					local thumb
					thumb, index = lume.match(v, function(x) return x == 0 end)
				end

				--print(index)
				
				local quad = {tileset.quads[index]:getViewport()}
				local xx = quad[1]/imagew
				local yy = quad[2]/imageh
				local ww = quad[3]/imagew
				local hh = quad[4]/imageh
				
				if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
					editor.map.currentTile = index
					editor.map.autotile = true
					--print(i)
					editor.map.autotileType = i
					--print(self.currentAutotile)
				end

				imgui.SameLine()
				if math.fmod(i, 4) == 0 then
					imgui.NewLine()
				end
			end
			imgui.EndTabItem()
		end
	end
	imgui.EndTabBar()


	--[[if imgui.BeginChildFrame(123, ww, 196) then

		if imgui.TreeNodeEx("Tiles") then
			imgui.Unindent()
			
			imgui.Indent()
			imgui.TreePop()
		end

		if imgui.TreeNodeEx("AutoTiles") then
			imgui.Unindent()
			
			
			imgui.Indent()
			imgui.TreePop()
		end
		imgui.EndChildFrame()
	end]]
end

return TilemapLayer