local Class = require("pixcof.class")
local Viewer = Class:extend("Viewer")

function Viewer:constructor(debug)
	self.debug = debug
	self.open = true
end

function Viewer:update(dt)
end

function Viewer:draw()
end

return Viewer