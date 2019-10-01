local Component = require("pixcof.components.component")
local BoxComponent = Component:extend("BoxComponent")

function BoxComponent:constructor(entity)
	self.super.constructor(self, entity)
	local sprcomp = entity:getComponent("SpriteComponent")
	self.left = 0
	self.top = 0
	self.right = 32
	self.bottom = 32
	if sprcomp then
		self.right = sprcomp.width
		self.bpttom = sprcomp.height
	end
end

function BoxComponent:getLeft()
	return self.entity.position.x + self.left
end

function BoxComponent:getRight()
	return self.entity.position.x + self.right
end

function BoxComponent:getTop()
	return self.entity.position.y + self.top
end

function BoxComponent:getBottom()
	return self.entity.position.y + self.bottom
end

function BoxComponent:getCenter()
	local cx = self.right - self.left
	local cy = self.bottom - self.top
	return self.entity.position.x + cx, self.entity.position.y + cy
end

function BoxComponent:setBounds(left, top, right, bottom)
	self.left = left
	self.top = top
	self.right = right
	self.bottom = bottom
end

function BoxComponent:getBox()
	return self:getLeft(), self:getTop(), self:getRight(), self:getBottom()
end

function BoxComponent:intersects(box)
	local boxs = {self:getBox()}
	local box2 = {box:getBox()}
	if box1[1] <= box2[3] and box1[3] >= box2[1] and box1[2] <= box2[4] and box1[4] >= box2[2] then
		return true
	end
	return false
end

function BoxComponent:debug()
	self.left = imgui.DragInt("left", self.left)
	self.top = imgui.DragInt("top", self.top)
	self.right = imgui.DragInt("right", self.right)
	self.bottom = imgui.DragInt("bottom", self.bottom)
end

function BoxComponent:debugDraw(active)
	local bounds = {self:getBox()}
	love.graphics.setColor(1, 1, 1, 0.4)
	if active then love.graphics.setColor(lume.color("rgba(102, 96, 146, .6)")) end
	lg.rectangle("fill", bounds[1], bounds[2], self.right - self.left, self.bottom - self.top)
	--lg.print(bounds[], self.entity.x, self.entity.y)
	lg.setColor(1, 1, 1, 1)
	--print("Opa")
end

return BoxComponent