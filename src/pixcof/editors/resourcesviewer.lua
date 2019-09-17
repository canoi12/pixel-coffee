local Editor = require "pixcof.editors.editor"
local resources = require("pixcof.resources")
local ResourcesViewer = Editor:extends("ResourcesViewer")

function ResourcesViewer:constructor()
	Editor.constructor(self)
	self.open = false
	self.currentImage = nil
	self.currentFont = nil
	self.currentAudio = nil
	self.assetType = nil
	self.imageScale = 1
	self.initColumns = false
	self.txtCanvas = love.graphics.newCanvas()
	self.txtCanvas:setFilter("nearest", "nearest")

	self.viewers = {
		font = self.fontViewer,
		image = self.imageViewer
	}
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
	if self.open then
		imgui.Begin("ResourcesViewer")
		imgui.Columns(3)
		if not self.initColumns then
			local w,h = imgui.GetWindowSize()
			local cw = w/4
			imgui.SetColumnWidth(0, cw)
			imgui.SetColumnWidth(1, cw*2)
			self.initColumns = true
		end
		if self.open then
			imgui.BeginChild("ResourcesViewer", 0, 0, false, "ImGuiWindowFlags_HorizontalScrollbar")
			
			self:imageMenu()
			self:fontMenu()
			self:audioMenu()

			imgui.EndChild()
		end
		imgui.NextColumn()
		
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
		end
		imgui.End()
	else
		self.assetType = nil
	end
end

function ResourcesViewer:imageMenu()
	if imgui.TreeNodeEx("Images") then
		for k,image in pairs(resources.images) do
			if imgui.Selectable(k) then
				self.currentImage = image
				self.assetType = "image"
			end
		end
		imgui.TreePop()
	end
end


function ResourcesViewer:fontMenu()
	if imgui.TreeNodeEx("Fonts") then
		for k,font in pairs(resources.fonts) do
			if imgui.Selectable(k) then
				self.assetType = "font"
				self.currentFont = font
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

return ResourcesViewer