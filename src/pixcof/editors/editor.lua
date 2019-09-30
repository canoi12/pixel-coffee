local Class = require("pixcof.class")
local Editor = Class:extend("Editor")

function Editor:constructor(debug) 
	self.open = true
	self.debug = debug or {}
end

function Editor:update(dt)
end

function Editor:draw()
	if imgui.Begin(self.name) then 
		imgui.End()
	end
end

return Editor