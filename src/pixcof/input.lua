local Input = {}

local mouse_buttons = {1, 2, 3}

function Input:init()

	self.states = {
		mouse = {
			down = {},
			pressed = {}
		},
		key = {}
	}

	self.old_state = {
		mouse = {
			down = {}
		},
		key = {

		}
	}

	self.anykeydown = false

	self.mouse = {
		x = 0,
		y = 0,
		fix_x = 0,
		fix_y = 0
	}
end

function Input:update(dt)
	self.anykeydown = false
	self.mouse.x, self.mouse.y = love.mouse.getPosition()
	for i,button in ipairs(mouse_buttons) do
		self.old_state.mouse.down[button] = self.states.mouse.down[button]
		self.states.mouse.down[button] = self:isMouseDown(button)
		self.states.mouse.pressed[button] = self.states.mouse.down[button] and not self.old_state.mouse.down[button]
	end

	for k,key in pairs(self.states.key) do
		--print(k)
		--print(self.states.key[k].down)
		self.old_state.key[k].down = self.states.key[k].down
		self.states.key[k].down = lk.isDown(k)
		self.states.key[k].pressed = self.states.key[k].down and not self.old_state.key[k].down
		if self.states.key[k].down then self.anykeydown = true end 
	end
end

function Input:isMouseDown(button)
	return love.mouse.isDown(button)
end

function Input:isMouseUp(button)
	return not self:isMouseDown(button)
end

function Input:isMouseClicked(button)
	return self.states.mouse.pressed[button]
end

function Input:isKeyDown(key)
	self:initKey(key)
	return self.states.key[key].down
end

function Input:isKeyPressed(key)
	self:initKey(key)
	return self.states.key[key].pressed
end

function Input:isKeyUp(key)
	self:initKey(key)
	return not self.states.key[key].down
end

function Input:initKey(key)
	if self.states.key[key] == nil then
		self.states.key[key] = {
			down = false,
			pressed = false
		}
		self.old_state.key[key] = {
			down = false
		}
	end
end

function Input:mousePos()
	return self.mouse.x, self.mouse.y
end

function Input:fixMousePos()
	self.mouse.fix_x = self.mouse.x
	self.mouse.fix_y = self.mouse.y
end

function Input:getMouseDelta()
	local dx = self.mouse.x - self.mouse.fix_x
	local dy = self.mouse.y - self.mouse.fix_y
	return dx, dy
end


return Input