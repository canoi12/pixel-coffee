local Class = require("pixcof.class")
local Debug = Class:extends("Debug")

local editor = require("pixcof.editors.editor"):new()

function Debug:constructor()
	self.log = ""
	self.bgimage = love.graphics.newImage("pixcof/assets/images/bg.jpg")
	self.bgimage:setFilter("nearest", "nearest")
	self.bgimage:setWrap("repeat", "repeat")
end

function Debug:update(dt)
	imgui.NewFrame()
	imgui.StyleColorsDark()
end

function Debug:beginDraw()
	local w, h = lg.getDimensions()
	local quad = love.graphics.newQuad(0, 0, w, h, 32, 32)
	love.graphics.draw(self.bgimage, quad, 0, 0)
end

function Debug:endDraw() 

	imgui.Render()
end

function Debug:draw() 
	self:beginDraw()
	editor:draw()
	self:endDraw()
end

function Debug:Log(...) end

function Debug:initImGui() 
	love.textinput = function(t)
	    imgui.TextInput(t)
	end

 	love.keypressed = function(key)
	    imgui.KeyPressed(key)
	end

	love.keyreleased = function(key)
	    imgui.KeyReleased(key)
	end

	love.mousemoved = function(x, y)
	    imgui.MouseMoved(x, y)
	end

	love.mousepressed = function(x, y, button)
	    imgui.MousePressed(button)
	end

	love.mousereleased = function(x, y, button)
	    imgui.MouseReleased(button)
	end

	love.wheelmoved = function(x, y)
	    imgui.WheelMoved(y)
	end
	self:Log("ImGui started <3")
end

return Debug