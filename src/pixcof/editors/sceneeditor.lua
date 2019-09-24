local Editor = require("pixcof.editors.editor")
local Tilemap = require("pixcof.tilemap")
local Resources = require("pixcof.resources")
local SceneEditor = Editor:extends("SceneEditor")
local SceneManager = require("pixcof.scenemanager")
local Scene = require("pixcof.scene")

local camera = {x = 0, y = 0}
local moveCamera = false

function SceneEditor:constructor(debug)
	Editor.constructor(self, debug)
	self.open = true
	--self.canvas = love.graphics.newCanvas(512, 512)
	self.image = love.graphics.newImage("pixcof/assets/images/bgeditor.jpg")
	self.image:setFilter("nearest", "nearest")
	self.image:setWrap("repeat", "repeat")


	self.tilemapEdit = {
		name = "",
		image = "",
		width = 16,
		height = 16,
		oldName = ""
	}

	self.layerEdit = {
		name = "",
		type = "",
		oldName = ""
	}

	self.firstOpen = true

	self.map = {
		width = 16,
		height = 16,
		tilewidth = 16,
		tileheight = 16,
		currentTile = 1,
		autotile = false,
		autotileType = 1,
		currentEntity = nil,
		activeEntity = nil
	}

	self.width = 16
	self.height = 16
	self.tilewidth = 16
	self.tileheight = 16

	self.canvas = lg.newCanvas(self.width*self.tilewidth, self.height*self.tileheight)
	self.canvas:setFilter("nearest", "nearest")

	self.zoom = 2

	self.tilemap = Tilemap:new("forest", "forest")
	self.currentLayer = nil

	self.viewer = {
		width = 10,
		height = 10,
		zoom = 2,
		camera = {
			x = 0, y = 0
		},
		hovered = false
	}
end

function SceneEditor:update(dt)
	SceneManager:update(dt)
end

function SceneEditor:draw()
	local ww, wh = lg.getDimensions()
	local layer = self.tilemap.layers[self.currentLayer] or {name="", type=""}
	--print(ww, wh)
	imgui.SetNextWindowSize(ww, wh)
	imgui.SetNextWindowPos(0, 16)
	self.map.width, self.map.height = self.tilemap.width, self.tilemap.height
	self.map.tilewidth, self.map.tileheight = self.tilemap.tileset.tilew, self.tilemap.tileset.tileh
	if imgui.Begin("Scene Editor", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoBringToFrontOnFocus"}) then
		imgui.Columns(3)
		local cw = ww/6
		if self.firstOpen then
			imgui.SetColumnWidth(0, cw)
			imgui.SetColumnWidth(1, cw*4)
			imgui.SetColumnWidth(2, cw)
			self.firstOpen = false
		end
		if imgui.BeginChild("Scene Props") then
			imgui.Text("Scenes")
			local colw = imgui.GetWindowWidth()
			if imgui.BeginChildFrame(11, colw, 128) then
				for k,tilemap in pairs(Resources.tilemaps) do
					if imgui.SmallButton("x##tilemap_remove_" .. k) then Resources:removeTilemap(k) end
					imgui.SameLine()
					if imgui.SmallButton("..##tilemap_edit_" .. k) then 
						imgui.OpenPopup("Edit Tilemap")
						self.tilemapEdit.ref = tilemap
						self.tilemapEdit.name = tilemap.name
						self.tilemapEdit.tileset = tilemap.tileset
						self.tilemapEdit.width = tilemap.width
						self.tilemapEdit.height = tilemap.height
						self.tilemapEdit.oldName = tilemap.name
					end
					imgui.SameLine()
					if imgui.Selectable(tilemap.name, tilemap.name == self.tilemap.name) then 
						local scene = Scene:new(tilemap.name)
						SceneManager:changeScene(scene)
						self.tilemap = scene.tilemap
					end
				end
				imgui.EndChildFrame()
			end

			if imgui.SmallButton("new") then 
				imgui.OpenPopup("New Tilemap")
				self.tilemapEdit.name = ""
				self.tilemapEdit.tileset = ""
				self.tilemapEdit.width = 16
				self.tilemapEdit.height = 16
				self.tilemapEdit.oldName = ""
			end
			imgui.SameLine()
			if imgui.SmallButton("save") then
				for k,tilemap in pairs(Resources.tilemaps) do self:saveTilemap(tilemap) end
				self:saveTilemap()
			end

			imgui.Separator()

			imgui.Text("Layers")
			local keys = lume.map(self.tilemap.layers, function(x) return x.name end)
			if imgui.BeginChildFrame(10, colw, 128) then
				--imgui.ListBox("##layers", 1, keys, #keys)
				for i,layer in ipairs(self.tilemap.layers) do 
					if imgui.SmallButton("x##remove_layer_" .. layer.name) then 
						self.tilemap:removeLayer(i)
					end
					imgui.SameLine()
					local btn_char = "o"
					if not layer.active then btn_char = "-" end
					if imgui.SmallButton(btn_char .. "##hide_layer_" .. layer.name) then 
						layer.active = not layer.active
					end
					imgui.SameLine()
					if imgui.Selectable(layer.name .. " # " .. layer.type, i == self.currentLayer) then 
						self.currentLayer = i
					end
				end
				imgui.EndChildFrame()
			end

			--[[if imgui.SmallButton("+ tile layer") then self.tilemap:addLayer(nil, "Tile") end
			imgui.SameLine()
			if imgui.SmallButton("+ entity layer") then self.tilemap:addLayer(nil, "Entity") end]]
			if imgui.SmallButton("new layer") then 
				imgui.OpenPopup("New Layer")
				self.layerEdit.name = ""
			end

			self:newTilemap()
			self:editTilemap()
			self:newLayer()

			imgui.EndChild()

		end

		--if change then self:resizeCanvas() end
		self:resizeCanvas()
		imgui.NextColumn()

		if imgui.BeginChild("Scene Viewer") then
		
			local wpos = {imgui.GetWindowPos()}
			self.viewer.width, self.viewer.height = imgui.GetWindowSize()
			local umpos = {imgui.GetMousePos()}
			--local mpos = {}
			umpos[1] = umpos[1] - wpos[1]
			umpos[2] = umpos[2] - wpos[2]
			local mpos = {
				math.floor((umpos[1]-self.viewer.camera.x)/(self.map.tilewidth*self.viewer.zoom))*self.map.tilewidth,
				math.floor((umpos[2]-self.viewer.camera.y)/(self.map.tileheight*self.viewer.zoom))*self.map.tileheight
			}

			umpos[1] = (umpos[1] - self.viewer.camera.x)/self.viewer.zoom
			umpos[2] = (umpos[2] - self.viewer.camera.y)/self.viewer.zoom

			local tpos = {
				mpos[1]/self.map.tilewidth,
				mpos[2]/self.map.tileheight
			}

			local dpos = {imgui.GetMouseDragDelta(0)}

			if lk.isDown("lctrl") and imgui.IsMouseClicked(0) then
				print(self.viewer.camera.x, self.viewer.camera.y)
				camera.x = self.viewer.camera.x
				camera.y = self.viewer.camera.y
			end

			if dpos[1] ~= 0 and dpos[1] ~= 0 then
				if lk.isDown("lctrl") and imgui.IsMouseDragging(0) then
					self.viewer.camera.x = camera.x + dpos[1]
					self.viewer.camera.y = camera.y + dpos[2]
				end
			end

			--imgui.Text("mouse " .. mpos[1] .. "x" .. mpos[2])

			local isfocus = imgui.IsWindowHovered()
			self.viewer.hovered = isfocus

			if layer.type == "Tile" then
				if isfocus and not anykeydown and imgui.IsMouseDown(0) then
					self.tilemap:insertTile(mpos[1], mpos[2], self.map.currentTile, self.currentLayer, self.map.autotile, self.map.autotileType)
				elseif isfocus and not anykeydown and imgui.IsMouseDown(1) then
					self.tilemap:removeTile(mpos[1], mpos[2], self.currentLayer, self.map.autotile, self.map.autotileType)
				end
			elseif layer.type == "Entity" then
				if self.map.currentEntity and isfocus and not anykeydown and imgui.IsMouseClicked(0) then
					self.tilemap:addEntity(self.map.currentEntity.x, self.map.currentEntity.y, self.map.currentEntity:new(), layer.name)
					--lume.push(layer.entities, {type=self.map.currentEntity.name, x = self.map.currentEntity.x, y = self.map.currentEntity.y})
					--SceneManager:spawn(mpos[1], mpos[2], self.map.currentEntity:new())
					--print(self.map.currentEntity.name)
				elseif isfocus and not anykeydown and imgui.IsMouseClicked(0) then
					local entities = SceneManager:getEntities()
					--print(lume.count(entities))
					for i,entity in ipairs(entities) do
						if entity:isHovering(umpos[1], umpos[2]) then
							self.map.activeEntity = entity
							break
						end
					end
				end
				if isfocus and not anykeydown and imgui.IsMouseClicked(1) then
					self.map.currentEntity = nil
					local entities = SceneManager:getEntities()
					--print(lume.count(entities))
					for i,entity in ipairs(entities) do
						if entity:isHovering(umpos[1], umpos[2]) then
							--print("Opa", entity.name)
							SceneManager:destroy(entity)
							break
						end
					end
				end
			end

			if isfocus and lk.isDown("left", "a") then
				self.viewer.camera.x = self.viewer.camera.x - (100*0.05)
			elseif isfocus and lk.isDown("right", "d") then
				self.viewer.camera.x = self.viewer.camera.x + (100*0.05)
			end

			if isfocus and lk.isDown("up", "w") then
				self.viewer.camera.y = self.viewer.camera.y - (100*0.05)
			elseif isfocus and lk.isDown("down", "s") then
				self.viewer.camera.y = self.viewer.camera.y + (100*0.05)
			end

			self.width, self.height = self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight

			lg.setCanvas(self.canvas)
			lg.clear(0, 0, 0)
			lg.push()
			lg.translate(self.viewer.camera.x, self.viewer.camera.y)
			lg.scale(self.viewer.zoom, self.viewer.zoom)
			local quad = lg.newQuad(0, 0, self.width, self.height, self.map.tilewidth, self.map.tileheight)
			lg.draw(self.image, quad)
			SceneManager:draw()
			--self.tilemap:draw()
			if layer.type == "Tile" then
				lg.rectangle("line", mpos[1], mpos[2], self.map.tilewidth, self.map.tileheight)
			elseif layer.type == "Entity" then
				if self.map.currentEntity then 
					self.map.currentEntity.x = mpos[1]
					self.map.currentEntity.y = mpos[2]
					self.map.currentEntity:draw()
				end
			end
			lg.pop()
			lg.setCanvas()

			imgui.Image(self.canvas, self.viewer.width, self.viewer.height)

			imgui.EndChild()

		end

		imgui.NextColumn()
		if imgui.BeginChild("Layer") then
			local ww, wh = imgui.GetWindowSize()
			imgui.Text("current layer: " .. layer.name)
			self.viewer.camera.x, self.viewer.camera.y = imgui.DragFloat2("camera", self.viewer.camera.x, self.viewer.camera.y)
			if imgui.SmallButton("reset camera") then 
				self.viewer.camera.x = 0
				self.viewer.camera.y = 0
			end

			self.viewer.zoom = imgui.DragFloat("zoom", self.viewer.zoom, 0.25, 0.25, 8)
			imgui.Separator()

			if layer.type == 'Entity' then 
				if imgui.Button("x##remove_filter_object") then end
				imgui.SameLine()
				imgui.InputText("##filter_object", "", 32)
			end

			if imgui.BeginChildFrame(1, ww, 196, "ImGuiWindowFlags_AlwaysAutoResize") then
				if layer.type == "Tile" then
					self:drawTileSelector()
				elseif layer.type == "Entity" then
					self:drawObjectSelector()
				end
				imgui.EndChildFrame()
			end
			imgui.Separator()
			imgui.Text("Instances")
			if layer.type == "Entity" and imgui.BeginChildFrame(2, ww, 196, "ImGuiWindowFlags_AlwaysAutoResize") then
				for i,entity in ipairs(layer.entities) do
					imgui.SetNextTreeNodeOpen(false)
					if self.map.activeEntity == entity then imgui.SetNextTreeNodeOpen(true) end
					if imgui.TreeNode(entity.name .. "##entity_" .. i .. "_" .. layer.name .. "_" .. entity.name) then
						imgui.Unindent()
						entity.x, entity.y = imgui.DragInt2("position##entity_position_" .. i .. "_" .. entity.name, entity.x, entity.y)
						entity.angle = imgui.DragInt("angle##entity_angle_" .. i .. "_" .. entity.name, entity.angle)
						entity.scale.x, entity.scale.y = imgui.DragFloat2("scale##entity_scale_" .. i .. "_" .. entity.name, entity.scale.x, entity.scale.y)
						if self.map.activeEntity ~= entity then
							self.viewer.camera.x = -entity.x*self.viewer.zoom + self.viewer.width/2
							self.viewer.camera.y = -entity.y*self.viewer.zoom + self.viewer.height/2
						end
						self.map.activeEntity = entity
						imgui.Indent()
						imgui.TreePop()
					end
				end
				imgui.EndChildFrame()
			end

			imgui.EndChild()
		end

		imgui.End()
	end
end

function SceneEditor:resizeCanvas()
	self.canvas = lg.newCanvas(self.viewer.width, self.viewer.height)
	self.canvas:setFilter("nearest", "nearest")
end

function SceneEditor:newTilemap()
	if imgui.BeginPopupModal("New Tilemap", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		self.tilemapEdit.name = imgui.InputText("name", self.tilemapEdit.name, 32)
		local keys = lume.keys(Resources.tilesets)
		local index = lume.find(keys, self.tilemapEdit.tileset) or 1
		index = imgui.Combo("tileset", index, keys, #keys)
		self.tilemapEdit.tileset = keys[index]

		self.tilemapEdit.width, self.tilemapEdit.height = imgui.InputInt2("size", self.tilemapEdit.width, self.tilemapEdit.height)
		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then
			local tilemap = Tilemap:new(self.tilemapEdit.name, self.tilemapEdit.tileset, self.tilemapEdit.width, self.tilemapEdit.height)
			self:saveTilemap(tilemap)
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then imgui.CloseCurrentPopup() end

		imgui.EndPopup()
	end
end

function SceneEditor:editTilemap()
	if imgui.BeginPopupModal("Edit Tilemap", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		self.tilemapEdit.name = imgui.InputText("name", self.tilemapEdit.name, 32)
		local keys = lume.keys(Resources.tilesets)
		local index = lume.find(keys, self.tilemapEdit.tileset) or 1
		index = imgui.Combo("tileset", index, keys, #keys)
		self.tilemapEdit.tileset = keys[index]

		self.tilemapEdit.width, self.tilemapEdit.height = imgui.InputInt2("size", self.tilemapEdit.width, self.tilemapEdit.height)
		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then

			self.tilemapEdit.ref.name = self.tilemapEdit.name
			self.tilemapEdit.ref.tileset = self.tilemapEdit.tileset
			self.tilemapEdit.ref.width = self.tilemapEdit.width
			self.tilemapEdit.ref.height = self.tilemapEdit.height

			local tilemap = Tilemap:load(self.tilemapEdit.oldName)
			tilemap:editMap(self.tilemapEdit.name, self.tilemapEdit.tileset, self.tilemapEdit.width, self.tilemapEdit.height)

			Resources:removeTilemap(self.tilemapEdit.oldName)


			--local tilemap = Tilemap:load(self.tilemapEdit.name)
			--tilemap.
			--self.tilemap = Tilemap:load(self.tilemapEdit.name)

			self:saveTilemap(tilemap)
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then imgui.CloseCurrentPopup() end

		imgui.EndPopup()
	end
end

function SceneEditor:editLayer()
	if imgui.BeginPopupModal("Edit Layer", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then

		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then end
		if imgui.SmallButton("cancel") or lk.isDown("escape") then end
		imgui.EndPopup()
	end
end

function SceneEditor:newLayer()
	if imgui.BeginPopupModal("New Layer", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		self.layerEdit.name = imgui.InputText("name", self.layerEdit.name, 32)
		local keys = {"Tile", "Entity"}
		local index = lume.find(keys, self.layerEdit.type) or 1
		index = imgui.Combo("type", index, keys, #keys)
		self.layerEdit.type = keys[index]

		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then 
			self.tilemap:addLayer(self.layerEdit.name, self.layerEdit.type)
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup()
		end

		imgui.EndPopup()
	end
end

function SceneEditor:drawTileSelector()
	local tileset = self.tilemap.tileset
	local image = Resources:getImage(tileset.image)
	local imagew, imageh = image:getDimensions()
	local maxtilew = image:getWidth()/tileset.tilew
	local maxtileh = image:getHeight()/tileset.tileh

	if imgui.TreeNodeEx("Tiles") then
		imgui.Unindent()
		for i,quad in ipairs(tileset.quads) do
			local xx = quad[1]/imagew
			local yy = quad[2]/imageh
			local ww = quad[3]/imagew
			local hh = quad[4]/imageh

			if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
				self.map.currentTile = i
				self.map.autotile = false
			end
			imgui.SameLine()
			if math.fmod(i, 4) == 0 then
				imgui.NewLine()
			end
		end
		imgui.Indent()
		imgui.TreePop()
	end

	if imgui.TreeNodeEx("AutoTiles") then
		imgui.Unindent()
		for i,v in ipairs(tileset.autotiles) do
			local _,index = lume.match(v, function(x) return x ~= -1 end)
			if lume.any(v, function(x) return x == 0 end) then
				local thumb
				thumb, index = lume.match(v, function(x) return x == 0 end)
			end
			
			local quad = tileset.quads[index]
			local xx = quad[1]/imagew
			local yy = quad[2]/imageh
			local ww = quad[3]/imagew
			local hh = quad[4]/imageh
			
			if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
				self.map.currentTile = index
				self.map.autotile = true
				self.map.autotileType = i
				--print(self.currentAutotile)
			end

			imgui.SameLine()
			if math.fmod(i, 4) == 0 then
				imgui.NewLine()
			end
		end
		
		imgui.Indent()
		imgui.TreePop()
	end
end

function SceneEditor:drawObjectSelector()
	-- body
	for k,object in pairs(Resources.objects) do
		local entity = self.map.currentEntity or {name=""}
		if imgui.Selectable(k, k == entity.name) then
			self.map.currentEntity = object:new(0, 0)
		end
	end
end

function SceneEditor:saveTilemap(tilemapToSave)
	local tilemap = {}
	local ctilemap = tilemapToSave or self.tilemap
	tilemap.name = ctilemap.name
	tilemap.width = ctilemap.width
	tilemap.height = ctilemap.height
	tilemap.layers = {}
	for i,layer in ipairs(ctilemap.layers) do
		lyr = {}
		for k,attr in pairs(layer) do
			if k ~= "batch" then
				lyr[k] = attr
			end
			if k == "entities" then 
				--lume.map(layer.entities, function(x) end)
				--print(attr[1].type)
				--print(attr[1].name)
				local entities = {}
				--if ctilemap == self.tilemap then
				lume.map(layer.entities, function(ent) lume.push(entities, {type = ent.name or ent.type, x = ent.x, y = ent.y}) end)
				--end
				lyr.entities = entities
			end 
			--print(k, attr)
		end
		lume.push(tilemap.layers, lyr)
	end
	tilemap.tileset = ctilemap.tileset.name or ctilemap.tileset
	self.debug:Log(tilemap.name, "saved")

	Resources:saveTilemap(tilemap.name, tilemap)
end

function SceneEditor:wheelmoved(x, y)
	if y > 0 and self.viewer.hovered then
		self.viewer.zoom = self.viewer.zoom + 0.25
	elseif y < 0 and self.viewer.hovered then
		self.viewer.zoom = self.viewer.zoom - 0.25
	end
end

return SceneEditor