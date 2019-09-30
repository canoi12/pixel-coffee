local Class = require("pixcof.class")
local Layer = Class:extend("Layer")

function Layer:constructor(scene)
	self.type = ""
	self.active = true
	self.scene = scene or {}
end

function Layer:load(layer)
end

function Layer:update(dt)
end

function Layer:draw()

end

function Layer:toTable()
	return {}
end

function Layer:debug(editor)
	imgui.Text("Layer Props")
end

function Layer:resize(width, height)
	self.width = width
	self.height = height
end

return Layer