local Class = require("pixcof.class")
local Editor = Class:extends("Editor")

function Editor:constructor(debug) 
	self.open = false
	self.debug = debug or {}
end
function Editor:draw()
	if imgui.Begin(self.name) then 
		imgui.End()
	end
end

return Editor