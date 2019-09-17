local Editor = require("pixcof.editors.editor")
local Tilemap = require("pixcof.tilemap")
local Resources = require("pixcof.resources")
local SceneEditor = Editor:extends("SceneEditor")

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
		height = 16
	}

	self.layerEdit = {
		name = "",
		type = ""
	}

	self.firstOpen = true

	self.map = {
		width = 16,
		height = 16,
		tilewidth = 16,
		tileheight = 16
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
		}
	}
end

function SceneEditor:draw()
	local ww, wh = lg.getDimensions()
	--print(ww, wh)
	imgui.SetNextWindowSize(ww, wh)
	imgui.SetNextWindowPos(0, 16)
	self.map.width, self.map.height = self.tilemap.width, self.tilemap.height
	self.map.tilewidth, self.map.tileheight = self.tilemap.tileset.tilew, self.tilemap.tileset.tileh
	if imgui.Begin("Scene Editor", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoBringToFrontOnFocus"}) then
		imgui.Columns(3)
		if self.firstOpen then
			local cw = ww/6
			imgui.SetColumnWidth(0, cw)
			imgui.SetColumnWidth(1, cw*4)
			imgui.SetColumnWidth(2, cw)
			self.firstOpen = false
		end
		if imgui.BeginChild("Scene Props") then
			imgui.Text("Scenes")
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
				end
				imgui.SameLine()
				if imgui.Selectable(tilemap.name) then self.tilemap = Tilemap:load(k) end
			end

			if imgui.SmallButton("new") then 
				imgui.OpenPopup("New Tilemap")
				self.tilemapEdit.name = ""
				self.tilemapEdit.tileset = ""
				self.tilemapEdit.width = 16
				self.tilemapEdit.height = 16
			end
			imgui.SameLine()
			if imgui.SmallButton("save") then
				for k,tilemap in pairs(Resources.tilemaps) do self:saveTilemap(tilemap) end
			end

			imgui.Separator()

			imgui.Text("Layers")
			for i,layer in ipairs(self.tilemap.layers) do 
				if imgui.SmallButton("x##remove_layer_" .. layer.name) then 
					self.tilemap:removeLayer(i)
				end
				imgui.SameLine()
				if imgui.Selectable(layer.name .. " # " .. layer.type, i == self.currentLayer) then 
					self.currentLayer = i
				end
			end

			--[[if imgui.SmallButton("+ tile layer") then self.tilemap:addLayer(nil, "Tile") end
			imgui.SameLine()
			if imgui.SmallButton("+ entity layer") then self.tilemap:addLayer(nil, "Entity") end]]
			if imgui.SmallButton("new layer") then 
				imgui.OpenPopup("New Layer")
				self.layerEdit.name = ""
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
			local mpos = {imgui.GetMousePos()}
			mpos[1] = mpos[1] - wpos[1]
			mpos[2] = mpos[2] - wpos[2]
			mpos = {
				math.floor((mpos[1]-self.viewer.camera.x)/(self.map.tilewidth*self.zoom))*self.map.tilewidth,
				math.floor((mpos[2]-self.viewer.camera.y)/(self.map.tileheight*self.zoom))*self.map.tileheight
			}

			local tpos = {
				mpos[1]/self.map.tilewidth,
				mpos[2]/self.map.tileheight
			}

			--imgui.Text("mouse " .. mpos[1] .. "x" .. mpos[2])

			local isfocus = imgui.IsWindowFocused()

			if isfocus and imgui.IsMouseDown(0) then
				self.tilemap:insertTile(mpos[1], mpos[2], 1, self.currentLayer, true)
			elseif imgui.IsWindowFocused() and imgui.IsMouseDown(1) then
				self.tilemap:removeTile(mpos[1], mpos[2], self.currentLayer, true)
			end

			if isfocus and lk.isDown("left") then
				self.viewer.camera.x = self.viewer.camera.x - (100*0.05)
			elseif isfocus and lk.isDown("right") then
				self.viewer.camera.x = self.viewer.camera.x + (100*0.05)
			end

			self.width, self.height = self.map.width*self.map.tilewidth, self.map.height*self.map.tileheight

			lg.setCanvas(self.canvas)
			lg.clear(0, 0, 0)
			lg.push()
			lg.translate(self.viewer.camera.x, self.viewer.camera.y)
			lg.scale(self.zoom, self.zoom)
			local quad = lg.newQuad(0, 0, self.width, self.height, self.map.tilewidth, self.map.tileheight)
			lg.draw(self.image, quad)
			self.tilemap:draw()
			lg.rectangle("line", mpos[1], mpos[2], self.map.tilewidth, self.map.tileheight)
			lg.pop()
			lg.setCanvas()

			imgui.Image(self.canvas, self.viewer.width, self.viewer.height)

			imgui.EndChild()

		end

		imgui.NextColumn()
		imgui.Text("Layers")

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
		if imgui.SmallButton("ok") then
			self.tilemap = Tilemap:new(self.tilemapEdit.name, self.tilemapEdit.tileset, self.tilemapEdit.width, self.tilemapEdit.height)
			self:saveTilemap()
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") then imgui.CloseCurrentPopup() end

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
		if imgui.SmallButton("ok") then

			self.tilemapEdit.ref.name = self.tilemapEdit.name
			self.tilemapEdit.ref.tileset = self.tilemapEdit.tileset
			self.tilemapEdit.ref.width = self.tilemapEdit.width
			self.tilemapEdit.ref.height = self.tilemapEdit.height
			self.tilemap = Tilemap:load(self.tilemapEdit.name)

			self:saveTilemap()
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") then imgui.CloseCurrentPopup() end

		imgui.EndPopup()
	end
end

function SceneEditor:editLayer()
	if imgui.BeginPopupModal("Edit Layer", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then

		imgui.Separator()
		if imgui.SmallButton("ok") then end
		if imgui.SmallButton("cancel") then end
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
		if imgui.SmallButton("ok") then 
			self.tilemap:addLayer(self.layerEdit.name, self.layerEdit.type)
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") then 
			imgui.CloseCurrentPopup()
		end

		imgui.EndPopup()
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
		end
		lume.push(tilemap.layers, lyr)
	end
	tilemap.tileset = ctilemap.tileset.name or ctilemap.tileset
	self.debug:Log(tilemap.name, "saved")

	Resources:saveTilemap(tilemap.name, tilemap)
end

return SceneEditor