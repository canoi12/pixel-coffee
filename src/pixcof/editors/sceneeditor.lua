local Editor = require("pixcof.editors.editor")
local Input = require("pixcof.input")
local Tilemap = require("pixcof.tilemap")
local Vector2 = require("pixcof.types.vector2")
local Resources = require("pixcof.resources")
local SceneEditor = Editor:extend("SceneEditor")
local SceneManager = require("pixcof.scenemanager")
local Scene = require("pixcof.scene")

local camera = Vector2()
local entity_pos = Vector2()
local moveCamera = false

function SceneEditor:constructor(debug)
	Editor.constructor(self, debug)
	self.open = true
	--self.canvas = love.graphics.newCanvas(512, 512)
	self.image = love.graphics.newImage("pixcof/assets/images/bgeditor.jpg")
	self.image:setFilter("nearest", "nearest")
	self.image:setWrap("repeat", "repeat")

	self.layersTypes = {"Tile", "Entity", "Background", "Sprite"}

	self.popups = {
		layer = false
	}


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
		oldName = "",
		tileset = ""
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
		activeEntity = {}
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

function SceneEditor:openMap(map)
	local scene = Scene:new(map.name)
	SceneManager:changeScene(scene)
	self.tilemap = scene
end

function SceneEditor:draw()
	local ww, wh = lg.getDimensions()
	local layer = self.tilemap.layers[self.currentLayer] or {name="", type=""}

	self.map.width, self.map.height = self.tilemap.width, self.tilemap.height
	self.map.tilewidth, self.map.tileheight = self.tilemap.tilew or 16, self.tilemap.tileh or 16

	local cw = ww/6
		
	self:resizeCanvas()

	--[[imgui.SetNextDock("ImGuiDockSlot_Left")
	imgui.SetNextDockSplitRatio(0.85, 0.2)]]

	--imgui.PushID(2121)

	if imgui.Begin("Scene Viewer##scene_viewer") then
		local wpos = {imgui.GetWindowPos()}
		--local wpos = {imgui.GetCursorPos()}
		self.viewer.width, self.viewer.height = imgui.GetContentRegionAvail()
		local umpos = {imgui.GetMousePos()}
		local cpos = {imgui.GetCursorPos()}
		--local mpos = {}
		
		umpos[1] = umpos[1] - wpos[1] - cpos[1]
		umpos[2] = umpos[2] - wpos[2] - cpos[2]
		local mpos = {
			math.floor((umpos[1]-self.tilemap.camera.x)/(self.map.tilewidth*self.viewer.zoom))*self.map.tilewidth,
			math.floor((umpos[2]-self.tilemap.camera.y)/(self.map.tileheight*self.viewer.zoom))*self.map.tileheight
		}

		umpos[1] = (umpos[1] - self.tilemap.camera.x)/self.viewer.zoom
		umpos[2] = (umpos[2] - self.tilemap.camera.y)/self.viewer.zoom

		local tpos = {
			mpos[1]/self.map.tilewidth,
			mpos[2]/self.map.tileheight
		}

		local dpos = {imgui.GetMouseDragDelta(0)}

		--[[if lk.isDown("lctrl") and imgui.IsMouseClicked(0) then
			--print(self.viewer.camera.x, self.viewer.camera.y)
			camera.x = self.tilemap.camera.x
			camera.y = self.tilemap.camera.y
		end]]
		local isfocus = imgui.IsWindowHovered()
		self.viewer.hovered = isfocus
		if Input:isKeyPressed("lalt") then
			camera.x = self.tilemap.camera.x
			camera.y = self.tilemap.camera.y
			Input:fixMousePos()
		end

		if Input:isKeyDown("lalt") and isfocus then
			local dpos = {Input:getMouseDelta()}
			self.tilemap.camera.x = camera.x + dpos[1]
			self.tilemap.camera.y = camera.y + dpos[2]
		end

		--[[if dpos[1] ~= 0 and dpos[1] ~= 0 then
			if lk.isDown("lctrl") and imgui.IsMouseDragging(0) then
				self.tilemap.camera.x = camera.x + dpos[1]
				self.tilemap.camera.y = camera.y + dpos[2]
			end
		end]]

		--imgui.Text("mouse " .. mpos[1] .. "x" .. mpos[2])

		if layer.type == "Tile" then
			if isfocus and not anykeydown and imgui.IsMouseDown(0) then
				--print(self.map.autotileType)
				self.tilemap:insertTile(mpos[1], mpos[2], self.map.currentTile, self.currentLayer, self.map.autotile, self.map.autotileType)
			elseif isfocus and not anykeydown and imgui.IsMouseDown(1) then
				self.tilemap:removeTile(mpos[1], mpos[2], self.currentLayer, self.map.autotile, self.map.autotileType)
			end
		elseif layer.type == "Entity" then
			layer:setActiveEntity(self.map.activeEntity)
			if self.map.activeEntity and lume.count(self.map.activeEntity) > 0 then
				local dpos = {imgui.GetMouseDragDelta(0)}
				local delpos = Vector2(dpos[1], dpos[2])
				--local enthover = self.map.activeEntity:isHovering(umpos[1], umpos[2])
				if isfocus and not anykeydown and (dpos[1] ~= 0 or dpos[2] ~= 0) then
					local pos = entity_pos + (delpos / self.viewer.zoom)
					self.map.activeEntity.position = pos
				end
			end

			local enthover, entselect = layer:isHoveringEntity(umpos[1], umpos[2])
			if self.map.currentEntity and not entselect and isfocus and not anykeydown and imgui.IsMouseClicked(0) then
				self.tilemap:addEntity(self.map.currentEntity.position.x, self.map.currentEntity.position.y, self.map.currentEntity:new(), layer.name)
			elseif self.map.currentEntity and not entselect and isfocus and not anykeysdown and imgui.IsMouseClicked(1) then
				self.map.currentEntity = nil
			else
				if not entselect and isfocus and imgui.IsMouseClicked(0) then
					self.map.activeEntity = nil
				elseif isfocus and entselect and imgui.IsMouseClicked(0) then
					self.map.activeEntity = enthover
					entity_pos = enthover.position
					self.map.currentEntity = nil
				elseif isfocus and entselect and imgui.IsMouseClicked(1) then
					SceneManager:destroy(enthover)
					self.map.currentEntity = nil
				end
			end
		end

		self.width, self.height = self.tilemap.width, self.tilemap.height

		lg.setCanvas(self.canvas)
		lg.clear(0, 0, 0)
		lg.push()
		lg.translate(self.tilemap.camera.x, self.tilemap.camera.y)
		lg.scale(self.viewer.zoom, self.viewer.zoom)
		local quad = lg.newQuad(0, 0, self.width, self.height, self.map.tilewidth, self.map.tileheight)
		lg.draw(self.image, quad)
		SceneManager:draw()
		--self.tilemap:draw()
		if layer.type == "Tile" then
			lg.rectangle("line", mpos[1], mpos[2], self.map.tilewidth, self.map.tileheight)
		elseif layer.type == "Entity" then
			if self.map.currentEntity then 
				self.map.currentEntity.position = Vector2(mpos[1], mpos[2])
				--self.map.currentEntity.position.y = mpos[2]
				self.map.currentEntity:draw()
				self.map.currentEntity:debugDraw()
			end
			layer:debugEntity()
		end
		lg.pop()
		lg.setCanvas()

		imgui.Image(self.canvas, self.viewer.width, self.viewer.height)
	end
	imgui.End()

	--[[imgui.SetNextDock("ImGuiDockSlot_Left")
	imgui.SetNextDockSplitRatio(0.2, 0.2)]]
	if imgui.Begin("Scene Info") then

		imgui.Text("name: " .. self.tilemap.name)
		self.tilemap.width, self.tilemap.height = imgui.DragInt2("size##scene_size", self.tilemap.width, self.tilemap.height)
		--[[if layer.debug then
			layer:debug(self)
		end]]
		self.viewer.zoom = imgui.DragFloat("zoom", self.viewer.zoom, 0.2, 0.2, 8)
		self.tilemap.camera.x, self.tilemap.camera.y = imgui.DragFloat2("camera", self.tilemap.camera.x, self.tilemap.camera.y)
		if imgui.SmallButton("reset camera") then 
			self.tilemap.camera.x = 0
			self.tilemap.camera.y = 0
		end

		if imgui.SmallButton("save scene") then
			self:saveTilemap()
		end
	end
	imgui.End()

	--[[imgui.SetNextDock("ImGuiDockSlot_Bottom")
	imgui.SetNextDockSplitRatio(0.2, 0.7)]]

	if imgui.Begin("Layers") then
		local ww, wh = imgui.GetWindowSize()
		local keys = lume.map(self.tilemap.layers, function(x) return x.name end)
		if imgui.BeginChildFrame(10, ww, 128) then
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
		end
		imgui.EndChildFrame()

		--[[if imgui.SmallButton("+ tile layer") then self.tilemap:addLayer(nil, "Tile") end
		imgui.SameLine()
		if imgui.SmallButton("+ entity layer") then self.tilemap:addLayer(nil, "Entity") end]]
		if imgui.SmallButton("new layer") then 
			--imgui.OpenPopup("New Layer")
			self.popups.layer = true
			self.layerEdit.name = ""
		end

		if self.tilemap then
			imgui.SameLine()
			if imgui.SmallButton("up") then self.currentLayer = self.tilemap:upLayer(layer) end
			imgui.SameLine()
			if imgui.SmallButton("down") then self.currentLayer = self.tilemap:downLayer(layer) end
		end


			--[[self:newTilemap()
			self:editTilemap()]]


			--imgui.Text("current layer: " .. layer.name)

			--[[if layer.type == 'Entity' then 
				if imgui.Button("x##remove_filter_object") then end
				imgui.SameLine()
				imgui.InputText("##filter_object", "", 32)
			elseif layer.type == 'Tile' then
				local keys = lume.keys(Resources.tilesets)
				local index = lume.find(keys, layer.tileset.name)
				index = imgui.Combo("tilesets##layer_select_tileset", index, keys, #keys)
				layer:changeTileset(keys[index])
			end]]

			--[[if imgui.BeginChildFrame(1, ww, 196, "ImGuiWindowFlags_AlwaysAutoResize") then
				if layer.type == "Tile" then

					self:drawTileSelector()
				elseif layer.type == "Entity" then
					--self:drawObjectSelector()
					imgui.Text("Instances")
					--if layer.type == "Entity" and imgui.BeginChildFrame(2, ww, 196, "ImGuiWindowFlags_AlwaysAutoResize") then
					for i,entity in ipairs(layer.entities) do
						imgui.SetNextTreeNodeOpen(false)
						if self.map.activeEntity == entity then imgui.SetNextTreeNodeOpen(true) end
						if imgui.TreeNode(entity.__class .. "##entity_" .. i .. "_" .. layer.name .. "_" .. entity.__class) then
							imgui.Unindent()
							entity.x, entity.y = imgui.DragInt2("position##entity_position_" .. i .. "_" .. entity.__class, entity.x, entity.y)
							local angle = math.deg(entity.angle)
							angle = imgui.DragInt("angle##entity_angle_" .. i .. "_" .. entity.__class, angle)
							entity.angle = math.rad(angle)
							entity.scale.x, entity.scale.y = imgui.DragFloat2("scale##entity_scale_" .. i .. "_" .. entity.__class, entity.scale.x, entity.scale.y)
							if self.map.activeEntity ~= entity then
								self.tilemap.camera.x = -entity.x*self.viewer.zoom + self.viewer.width/2
								self.tilemap.camera.y = -entity.y*self.viewer.zoom + self.viewer.height/2
							end
							self.map.activeEntity = entity
							imgui.Indent()
							imgui.TreePop()
						end
					end
						--imgui.EndChildFrame()
					--end
				end
				imgui.EndChildFrame()
			end]]
			--imgui.Separator()
		end
		imgui.End()

		--[[imgui.SetNextDock("ImGuiDockSlot_Bottom")
		imgui.SetNextDockSplitRatio(0.2, 0.5)]]
		if imgui.Begin("Layer Props") then
			if layer.debug then
				layer:debug(self)
			end
		end
		imgui.End()

		--local tst = imgui.Dock
		--print(tst)

		--imgui.DockDebugWindow()

		--imgui.PushID(2121)

		if self.popups.layer then
			imgui.OpenPopup("New Layer")
		end

		self:newLayer()

		--imgui.PopID()

		--imgui.End()
	--end
end

function SceneEditor:resizeCanvas()
	self.canvas = lg.newCanvas(self.viewer.width, self.viewer.height)
	self.canvas:setFilter("nearest", "nearest")
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
		local keys = self.layersTypes
		local index = lume.find(keys, self.layerEdit.type) or 1
		index = imgui.Combo("type", index, keys, #keys)
		self.layerEdit.type = keys[index]
		local tileset_keys = lume.keys(Resources.tilesets)
		index = lume.find(tileset_keys, self.layerEdit.tileset) or 1
		if self.layerEdit.type == "Tile" then
			index = imgui.Combo("tileset", index, tileset_keys, #tileset_keys)
			self.layerEdit.tileset = tileset_keys[index]
		end

		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then 
			self.tilemap:addLayer(self.layerEdit.name, self.layerEdit.type, {tileset=self.layerEdit.tileset})
			imgui.CloseCurrentPopup()
			self.popups.layer = false
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup()
			self.popups.layer = false
		end

		imgui.EndPopup()
	end
end

function SceneEditor:drawTileSelector()
	--local tileset = self.tilemap.tileset
	local layer = self.tilemap.layers[self.currentLayer]
	if not layer then return end
	if layer.type ~= "Tile" then return end
	local tileset = layer.tileset
	--local image = Resources:getImage(tileset.image)
	local image = layer.tileset.image
	local imagew, imageh = image:getDimensions()
	local maxtilew = image:getWidth()/tileset.tilew
	local maxtileh = image:getHeight()/tileset.tileh

	if imgui.TreeNodeEx("Tiles") then
		imgui.Unindent()
		for i,qquad in ipairs(tileset.quads) do
			--print(quad)
			local quad = {qquad:getViewport()}
			local xx = quad[1]/imagew
			local yy = quad[2]/imageh
			local ww = quad[3]/imagew
			local hh = quad[4]/imageh

			if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
				--print(i)
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

			--print(index)
			
			local quad = {tileset.quads[index]:getViewport()}
			local xx = quad[1]/imagew
			local yy = quad[2]/imageh
			local ww = quad[3]/imagew
			local hh = quad[4]/imageh
			
			if imgui.ImageButton(image, 32, 32, xx, yy, xx+ww, yy+hh, 2) then
				self.map.currentTile = index
				self.map.autotile = true
				--print(i)
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
		local entity = self.map.currentEntity or {__class=""}
		if imgui.Selectable(k, k == entity.__class) then
			self.map.currentEntity = object:new(0, 0)
		end
	end
end

function SceneEditor:saveTilemap(tilemapToSave)
	--[[local tilemap = {}
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
	self.debug:Log(tilemap.name, "saved")]]
	local tilemap = self.tilemap:toTable()

	Resources:saveTilemap(tilemap.name, tilemap)
end

function SceneEditor:wheelmoved(x, y)
	if y > 0 and self.viewer.hovered then
		self.viewer.zoom = self.viewer.zoom + 0.2
	elseif y < 0 and self.viewer.hovered then
		self.viewer.zoom = self.viewer.zoom - 0.2
	end
end

return SceneEditor