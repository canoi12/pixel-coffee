local Viewer = require("pixcof.viewers.viewer")
local FontViewer = Viewer:extend("FontViewer")
local Resources = require("pixcof.resources")

function FontViewer:constructor(debug, name, font)
	Viewer.constructor(self, debug)
	self.asset = {
		name = name,
		font = font
	}

	self.canvas = love.graphics.newCanvas(1, 1)
	self.text = love.graphics.newText(Resources.fonts.minimal4, "abcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ")
end

function FontViewer:draw()
	self.open = imgui.Begin(self.asset.name, true, "ImGuiWindowFlags_HorizontalScrollbar")
	if self.open then
		local w,h = self.text:getDimensions()
		self.canvas = love.graphics.newCanvas(w, h)
		self.canvas:setFilter("nearest", "nearest")
		self.text:setFont(self.asset.font)
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.setBlendMode('alpha', 'alphamultiply') 
		love.graphics.draw(self.text, 0, 0)
		love.graphics.setCanvas()
		imgui.Image(self.canvas, w, h)
	end
	imgui.End()
end

return FontViewer