local Component = require("pixcof.components.component")
local Vector2 = require("pixcof.types.vector2")
local KinematicComponent = Component:extend("KinematicComponent")

function KinematicComponent:constructor(entity, speed)
	self.super.constructor(self, entity)
	self.speed = speed
	self.deltapos = Vector2()
end

function KinematicComponent:move(x, y)
	self.deltapos = Vector2(x, y)
end

function KinematicComponent:update(dt)
	self.entity.position = self.entity.position + (self.deltapos*self.speed*dt)
	self.deltapos = Vector2()
end

function KinematicComponent:debug(editor)
	self.speed = imgui.DragInt("speed", self.speed)
end

return KinematicComponent