local Component = require("pixcof.components.component")
local KinematicComponent = Component:extend("KinematicComponent")

function KinematicComponent:constructor(entity, speed)
	self.super.constructor(self, entity)
	self.speed = speed
	self.dx = 0
	self.dy = 0
end

function KinematicComponent:move(x, y)
	self.dx = x
	self.dy = y
end

function KinematicComponent:update(dt)
	self.entity.x = self.entity.x + (self.dx*self.speed*dt)
	self.entity.y = self.entity.y + (self.dy*self.speed*dt)
	self.dx = 0
	self.dy = 0
end

function KinematicComponent:debug(editor)
	self.speed = imgui.DragInt("speed", self.speed)
end

return KinematicComponent