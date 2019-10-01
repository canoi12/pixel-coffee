local Class = require("pixcof.class")
local Component = Class:extend("Component")

function Component:constructor(entity)
	self.active = true
	self.entity = entity
end

function Component:update(dt)
end

function Component:draw()
end

function Component:debug()
end

function Component:debugDraw(active)
end

return Component