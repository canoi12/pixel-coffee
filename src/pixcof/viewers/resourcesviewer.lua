local Viewer = require "pixcof.viewers.viewer"
local Scene = require("pixcof.scene")
local Sprite = require("pixcof.types.sprite")
local resources = require("pixcof.resources")
local ImageViewer = require("pixcof.viewers.imageviewer")
local FontViewer = require("pixcof.viewers.fontviewer")
local SpriteEditor = require("pixcof.editors.spriteeditor")
local TilesetEditor = require("pixcof.editors.tileseteditor")
local ResourcesViewer = Viewer:extend("ResourcesViewer")

function ResourcesViewer:constructor(debug)
	Viewer.constructor(self, debug)
	self.open = true
	self.assetType = nil
	self.imageScale = 1
	self.txtCanvas = love.graphics.newCanvas()
	self.txtCanvas:setFilter("nearest", "nearest")

	self.mapEdit = {
		name = "",
		width = 16,
		height = 16
	}

	self.popup = {
		map = {
			open = false,
			fn = self.openMapPopup,
			new = self.newMap
		},
		sprite = {
			open = false,
			fn = self.openSpritePopup,
			new = self.newSprite
		},
		tileset = {
			open = false,
			fn = self.openTilesetPopup,
			new = self.newTileset
		},
		object = {
			open = false,
			fn = self.openObjectPopup,
			new = self.newObject
		}
	}

	--[[self.viewers = {
		font = self.fontViewer,
		image = self.imageViewer
	}]]
	self.viewers = {}
	self.scripts = {}
	self.text = love.graphics.newText(resources.fonts.minimal4, "abcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ")
end

function ResourcesViewer:imageViewer()
	if self.currentImage then
		local w,h = self.currentImage:getDimensions()
		imgui.Image(self.currentImage, w*self.imageScale, h*self.imageScale)
	end
end

function ResourcesViewer:fontViewer()
	if self.currentFont then
		local w,h = self.text:getDimensions()
		self.txtCanvas = love.graphics.newCanvas(w, h)
		self.txtCanvas:setFilter("nearest", "nearest")
		self.text:setFont(self.currentFont)
		love.graphics.setCanvas(self.txtCanvas)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.setBlendMode('alpha', 'alphamultiply') 
		love.graphics.draw(self.text, 0, 0)
		love.graphics.setCanvas()
		imgui.Image(self.txtCanvas, w*self.imageScale, h*self.imageScale)
	end
end

function ResourcesViewer:objectViewer()
	if self.currentObject then

	end
end

function ResourcesViewer:draw()
	--if self.open then
		--[[imgui.Columns(3)
		if not self.initColumns then
			local w,h = imgui.GetWindowSize()
			local cw = w/4
			imgui.SetColumnWidth(0, cw)
			imgui.SetColumnWidth(1, cw*2)
			self.initColumns = true
		end]]
		--imgui.SetNextDockSplitRatio(0.1, 0.5)
		if imgui.Begin("ResourcesViewer##resources_viewer_dock") then
			--imgui.BeginChild("ResourcesViewer", 0, 0, false, "ImGuiWindowFlags_HorizontalScrollbar")
			if imgui.SmallButton("reload") then
				lume.hotswap("pixcof.resources")
				resources:init()
			end
			self:imageMenu()
			self:spriteMenu()
			self:tilesetMenu()
			self:fontMenu()
			self:audioMenu()
			self:objectMenu()
			self:mapMenu()

			if imgui.BeginPopupContextWindow("ResourcesMenu") then
				if imgui.BeginMenu("new") then 
					--[[if imgui.MenuItem("animation") then end
					if imgui.MenuItem("tileset") then end
					if imgui.MenuItem("map") then
						--self.popup.tilemap.name = ""
						self:openMapPopup()
					end]]
					for k,item in pairs(self.popup) do
						if imgui.MenuItem(k) then 
							item.fn(self)
						end
					end
					imgui.EndMenu()
				end
				imgui.EndPopup()
			end

			--imgui.EndChild()
		end
		imgui.End()

		--[[if self.popup.tilemap.open then
			imgui.OpenPopup("New Map")
		end

		if self.popup.sprite.open then
			imgui.OpenPopup("New Sprite")
		end

		if self.popup.tileset.open then
			imgui.OpenPopup("New Tileset")
		end

		if self.popup.object.open then
			imgui.OpenPopup("New Object")
		end]]

		--[[self:newMap()
		self:newSprite()
		self:newTileset()]]
		for k,popup in pairs(self.popup) do
			--print(k, popup.new)
			if popup.open then
				local aux = k:sub(1,1)
				local pop = k:sub(2,#k)
				pop = aux:upper() .. pop
				--print(pop)
				imgui.OpenPopup("New " .. pop)
			end
			popup.new(self)
		end

		for k,viewer in pairs(self.viewers) do
			if not viewer.open then
				lume.remove(self.viewers, viewer)
			end
			viewer:draw()
		end

		--[[for i,script in ipairs(self.scripts) do
			local open = imgui.Begin(script.name, true, "ImGuiWindowFlags_MenuBar")
			if open then
				imgui.BeginTextEditor(script.name)
				if imgui.BeginMenuBar() then
					if imgui.BeginMenu("File") then
						if imgui.MenuItem("Save", "Ctrl-S") then
							local scr = imgui.TextEditorGetText()
							--print(scr)
							local f = io.open(script.path, "w")
							f:write(scr)
							io.close(f)

							self.debug:Log(script.name .. " saved")
						end
						imgui.EndMenu()
					end
					imgui.EndMenuBar()
				end
				imgui.TextEditorMenu()
				imgui.RenderTextEditor()
			else
				lume.remove(self.scripts, script)
			end
			imgui.End()
		end]]
		--[[imgui.NextColumn()
		
		if self.open then
			imgui.BeginChild("Asset Viewer", 0, 0, false, "ImGuiWindowFlags_HorizontalScrollbar")
			if self.assetType then
				local fn = self.viewers[self.assetType]
				fn(self)
			end
			imgui.EndChild()
		end
		imgui.NextColumn()
		if self.currentImage and self.assetType == "image" then
			self.imageScale = imgui.SliderInt("Scale##image_scale", self.imageScale, 1, 8)
			local w,h = self.currentImage:getDimensions()
			imgui.Text("Dimensions: " .. w .. "x" .. h)
		elseif self.currentFont and self.assetType == "font" then
			self.imageScale = imgui.SliderInt("Scale##image_scale", self.imageScale, 1, 8)
		end]]
	--[[else
		self.assetType = nil
	end]]
end

function ResourcesViewer:imageMenu()
	if imgui.TreeNodeEx("Images") then
		for k,image in pairs(resources.images) do
			local scale = 16/image:getHeight()
			local size = {image:getDimensions()}
			if imgui.Selectable(k) then
				self.viewers[k] = ImageViewer:new(self.debug, k, image)
				--[[self.currentImage = image
				self.assetType = "image"]]
			end
			imgui.SameLine()
			imgui.Image(image, size[1]*scale, size[2]*scale)
		end
		imgui.TreePop()
	end
end


function ResourcesViewer:fontMenu()
	if imgui.TreeNodeEx("Fonts") then
		for k,font in pairs(resources.fonts) do
			if imgui.Selectable(k) then
				--[[self.assetType = "font"
				self.currentFont = font]]
				self.viewers[k] = FontViewer:new(self.debug, k, font)
			end
		end
		imgui.TreePop()
	end
end

function ResourcesViewer:objectMenu()
	if imgui.TreeNodeEx("Objects") then
		for k,object in pairs(resources.objects) do
			if imgui.SmallButton("x##remove_object_" .. k) then
				resources:removeObject(k)
			end
			imgui.SameLine()
			if imgui.SmallButton("..##open_object_" .. k .. "_src") then
				self:openScript(k)
			end
			imgui.SameLine()
			if imgui.Selectable(k) then
				local sceneeditor = self.debug.editors.scene
				if sceneeditor then
					sceneeditor.map.currentEntity = object:new()
				end
			end
		end
		imgui.TreePop()
	end
end

function ResourcesViewer:tilesetMenu()
	if imgui.TreeNodeEx("Tilesets") then
		for k,tileset in pairs(resources.tilesets) do
			local img = resources:getImage(tileset.image)
			if imgui.SmallButton("x##remove_tileset_" .. k) then
				self.viewers[k] = nil
				resources:removeTileset(k)
			end
			imgui.SameLine()
			if imgui.Selectable(k) then 
				self.viewers[k] = TilesetEditor:new(self.debug, k, tileset)
			end
			imgui.SameLine()
			imgui.Image(img, 16, 16)
		end
		imgui.TreePop()
	end
end

function ResourcesViewer:mapMenu()
	if imgui.TreeNodeEx("Maps") then
		for k,map in pairs(resources.tilemaps) do
			if imgui.SmallButton("x##remove_map_" .. k) then
				self.viewers[k] = nil
				resources:removeTilemap(k)
			end
			imgui.SameLine()
			if imgui.Selectable(k) then
				self.debug:openMap(map)
				self.debug:Log("Open", map.name, "Scene")
			end
		end
		imgui.TreePop()
	end
end

function ResourcesViewer:audioMenu()
	if imgui.TreeNodeEx("Audios") then
		imgui.TreePop()
	end
end

function ResourcesViewer:spriteMenu()
	if imgui.TreeNode("Sprites") then
		for k,sprite in pairs(resources.sprites) do
			if imgui.SmallButton("x##remove_animation_" .. k) then
				self.viewers[k] = nil
				resources:removeSprite(k)
			end
			imgui.SameLine()
			if imgui.Selectable(k) then
				self.viewers[k] = SpriteEditor:new(self.debug, k, sprite)
			end
			local image = resources:getImage(sprite.image)
			imgui.SameLine()
			imgui.Image(image, 16, 16)
		end
		imgui.TreePop()
	end
end

function ResourcesViewer:openMapPopup()
	self.popup.map.name = ""
	self.popup.map.width = 16
	self.popup.map.height = 16
	self.popup.map.tileset = ""
	self.popup.map.open = true
end

function ResourcesViewer:openSpritePopup()
	self.popup.sprite.name = ""
	self.popup.sprite.width = 16
	self.popup.sprite.height = 16
	self.popup.sprite.image = ""
	self.popup.sprite.open = true
end

function ResourcesViewer:openTilesetPopup()
	self.popup.tileset.name = ""
	self.popup.tileset.width = 16
	self.popup.tileset.height = 16
	self.popup.tileset.image = ""
	self.popup.tileset.open = true
end

function ResourcesViewer:openObjectPopup()
	self.popup.object.name = ""
	self.popup.object.superclass = ""
	self.popup.object.open = true
end

function ResourcesViewer:newMap()
	local map = self.popup.map
	if imgui.BeginPopupModal("New Map", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		map.name = imgui.InputText("name", map.name, 32)

		map.width, map.height = imgui.InputInt2("size", map.width, map.height)
		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then
			local scene = Scene:generateTable(map)
			resources:saveTilemap(scene.name, scene)

			imgui.CloseCurrentPopup()
			map.open = false
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup() 
			map.open = false
		end
		imgui.EndPopup()	
	end
end

function ResourcesViewer:newSprite()
	if imgui.BeginPopupModal("New Sprite", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		self.popup.sprite.name = imgui.InputText("name", self.popup.sprite.name, 32)

		local keys = lume.keys(resources.images)
		local index = lume.find(keys, self.popup.sprite.image) or 1
		index = imgui.Combo("image##animation_image", index, keys, #keys)
		self.popup.sprite.image = keys[index]

		self.popup.sprite.width, self.popup.sprite.height = imgui.InputInt2("size", self.popup.sprite.width, self.popup.sprite.height)
		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then
			--[[local scene = Scene:generateTable(self.popup.tilemap)
			resources:saveTilemap(scene.name, scene)]]
			local sprite = Sprite:generateTable(self.popup.sprite)
			resources:saveSprite(sprite.name, sprite)

			imgui.CloseCurrentPopup()
			self.popup.sprite.open = false
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup() 
			self.popup.sprite.open = false
		end
		imgui.EndPopup()	
	end
end

function ResourcesViewer:newTileset()
	if imgui.BeginPopupModal("New Tileset", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		self.popup.tileset.name = imgui.InputText("name", self.popup.tileset.name, 32)

		local keys = lume.keys(resources.images)
		local index = lume.find(keys, self.popup.tileset.image) or 1
		index = imgui.Combo("image##animation_image", index, keys, #keys)
		self.popup.tileset.image = keys[index]

		self.popup.tileset.width, self.popup.tileset.height = imgui.InputInt2("size", self.popup.tileset.width, self.popup.tileset.height)
		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then
			--[[local scene = Scene:generateTable(self.popup.tilemap)
			resources:saveTilemap(scene.name, scene)]]
			--local tileset = Animation:generateTable(self.popup.tileset)
			local tileset = {}
			tileset.name = self.popup.tileset.name
			tileset.tilew = self.popup.tileset.width
			tileset.tileh = self.popup.tileset.height
			tileset.image = self.popup.tileset.image
			tileset.quads = {}
			tileset.autotiles = {}
			resources:saveTileset(tileset.name, tileset)

			imgui.CloseCurrentPopup()
			self.popup.tileset.open = false
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup() 
			self.popup.tileset.open = false
		end
		imgui.EndPopup()	
	end
end

function ResourcesViewer:newObject()
	local object = self.popup.object
	if imgui.BeginPopupModal("New Object", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		object.name = imgui.InputText("name", object.name, 32)

		local keys = lume.keys(resources.objects)
		local index = lume.find(keys, object.superclass) or 1
		index = imgui.Combo("super class##object_superclass", index, keys, #keys)
		object.superclass = keys[index]

		imgui.Separator()
		if imgui.SmallButton("ok") or lk.isDown("return") then
			--[[local scene = Scene:generateTable(self.popup.tilemap)
			resources:saveTilemap(scene.name, scene)]]
			--[[local sprite = Sprite:generateTable(self.popup.sprite)
			resources:saveSprite(sprite.name, sprite)]]
			resources:newObject(object.name, object.superclass)
			imgui.CloseCurrentPopup()
			object.open = false
		end
		imgui.SameLine()
		if imgui.SmallButton("cancel") or lk.isDown("escape") then 
			imgui.CloseCurrentPopup()
			object.open = false
		end
		imgui.EndPopup()	
	end
end

function ResourcesViewer:openScript(name)
	--[[local l_name = name:lower()
	local path = "src/objects/" .. l_name .. ".lua"
	--local f = io.open()
	local cont = ""
	for line in io.lines(path) do
		cont = cont .. line .. "\n"
	end
	--io.close(f)

	if not lume.any(self.scripts, function(x) return x == "Script_" .. name end) then
		local script = {
			name = "Script_" .. name,
			path = path
		}
		imgui.BeginTextEditor("Script_" .. name)
		imgui.TextEditorSetText(cont)
		lume.push(self.scripts, script)
	end]]
	local l_name = name:lower()
	local path = "objects/" .. l_name .. ".lua"
	self.debug:openFile(l_name, path)
 end

return ResourcesViewer