local Class = require("pixcof.class")
local Debug = Class:extends("Debug")
local Editors = require("pixcof.editors")

function Debug:constructor()
	self.log = ""
	self.bgimage = love.graphics.newImage("pixcof/assets/images/bg.jpg")
	self.bgimage:setFilter("nearest", "nearest")
	self.bgimage:setWrap("repeat", "repeat")

	self.editors = {
		scene = Editors.SceneEditor:new(self),
		animation = Editors.AnimationEditor:new(),
		tileset = Editors.TilesetEditor:new(self),
		resources = Editors.ResourcesViewer:new()
	}
end

function Debug:update(dt)
	imgui.NewFrame()
	imgui.StyleColorsDark()
end

function Debug:beginDraw()
	local w, h = lg.getDimensions()
	local quad = love.graphics.newQuad(0, 0, w, h, 32, 32)
	love.graphics.draw(self.bgimage, quad, 0, 0)

	if imgui.BeginMainMenuBar() then
		if imgui.BeginMenu("File") then
			if imgui.MenuItem("Open", "Ctrl+O") then

			end
			if imgui.MenuItem("Save", "Ctrl+S") then end
			if imgui.MenuItem("Exit", "Ctrl+Q") then 
				self:Log("Gudbai")
			end
			imgui.EndMenu()
		end
		if imgui.BeginMenu("View") then
			for k,editor in pairs(self.editors) do
				if imgui.MenuItem(editor.name, "", editor.open) then
					editor.open = not editor.open
				end
			end
			imgui.EndMenu()
		end
		imgui.EndMainMenuBar()
	end
end

function Debug:endDraw() 

	imgui.Render()
end

function Debug:draw() 
	self:beginDraw()
	local editors_open = lume.filter(self.editors, function(x) return x.open end)
	for k,editor in pairs(editors_open) do
		editor:draw()
	end
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