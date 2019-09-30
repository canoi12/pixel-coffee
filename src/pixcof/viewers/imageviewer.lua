local Viewer = require("pixcof.viewers.viewer")
local ImageViewer = Viewer:extend("ImageViewer")

function ImageViewer:constructor(debug, name, image)
	Viewer.constructor(self, debug)
	self.asset = {
		name = name,
		image = image
	}
	self.open = true
end

function ImageViewer:draw()
	self.open = imgui.Begin(self.asset.name, true, {"ImGuiWindowFlags_HorizontalScrollbar", "ImGuiWindowFlags_AutoResize"})
	if self.open then
		local w,h = self.asset.image:getDimensions()
		imgui.Image(self.asset.image, w, h)
	end
	imgui.End()
end

return ImageViewer