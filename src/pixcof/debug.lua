local Class = require("pixcof.class")
local Debug = Class:extend("Debug")
local Editors = require("pixcof.editors")
local Viewers = require("pixcof.viewers")
local SceneManager = require("pixcof.scenemanager")

local Vector2 = require("pixcof.types.vector2")

local Input = require("pixcof.input")

function Debug:constructor()
	self.log = ""
	self.bgimage = love.graphics.newImage("pixcof/assets/images/bg.jpg")
	self.bgimage:setFilter("nearest", "nearest")
	self.bgimage:setWrap("repeat", "repeat")

	--SceneManager:init()

	self.editors = {
		scene = Editors.SceneEditor:new(self),
		--[[animation = Editors.AnimationEditor:new(),
		tileset = Editors.TilesetEditor:new(self),]]
		resources = Viewers.ResourcesViewer:new(self)
	}
end

function Debug:openMap(map)
	if self.editors.scene then 
		self.editors.scene:openMap(map)
	end
end

function Debug:update(dt)
	imgui.NewFrame()
	imgui.StyleColorsDark()
	--SceneManager:update(dt)
	local editors_open = lume.filter(self.editors, function(x) return x.open end)
	for k,editor in pairs(editors_open) do
		editor:update(dt)
	end

	--print(lk:Scancode)
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
	imgui.SetNextWindowPos(0, 0)
    imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight())
	if imgui.Begin("DockArea", nil, {"ImGuiWindowFlags_MenuBar", "ImGuiWindowFlags_NoDocking", "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoBringToFrontOnFocus"}) then
    	imgui.DockSpace(42)
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
				if imgui.MenuItem(editor.__class, "", editor.open) then
					editor.open = not editor.open
				end
			end
			imgui.EndMenu()
		end
		imgui.EndMainMenuBar()
	end
		local editors_open = lume.filter(self.editors, function(x) return x.open end)
		for k,editor in pairs(editors_open) do
			editor:draw()
		end
		imgui.End()
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
	    anykeydown = true
	end

	love.keyreleased = function(key)
	    imgui.KeyReleased(key)
	    anykeydown = false
	end

	love.mousemoved = function(x, y)
	    imgui.MouseMoved(x, y)
	end

	love.mousepressed = function(x, y, button)
	    imgui.MousePressed(button)
	    --Input:mousepressed(x, y, button)
	end

	love.mousereleased = function(x, y, button)
	    imgui.MouseReleased(button)
	    --Input:mousereleased(x, y, button)
	end

	love.wheelmoved = function(x, y)
	    imgui.WheelMoved(y)
	    if self.editors.scene then
		    self.editors.scene:wheelmoved(x, y)
		end
	end
	self:Log("ImGui started <3")
end

return Debug