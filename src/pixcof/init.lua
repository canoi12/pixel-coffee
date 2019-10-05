io.stdout:setvbuf("no")
imgui = require "imgui"
lume = require("pixcof.libs.lume")
lurker = require("pixcof.libs.lurker")
local __pixcof = {}
anykeydown = falses

__pixcof.Class = require("pixcof.class")
__pixcof.Debug = require("pixcof.debug")
__pixcof.Game = require("pixcof.game")
__pixcof.Resources = require("pixcof.resources")
__pixcof.Animation = require("pixcof.animation")
__pixcof.Tilemap = require("pixcof.tilemap")
__pixcof.Scene = require("pixcof.scene")
__pixcof.SceneManager = require("pixcof.scenemanager")
__pixcof.Input = require("pixcof.input")

__pixcof.Components = require("pixcof.components")
__pixcof.Viewers = require("pixcof.viewers")
__pixcof.Editors = require("pixcof.editors")
__pixcof.Types = require("pixcof.types")

__pixcof.Mode = {
	Log = function(...) end
}

__pixcof.init = function(args)
	love.window.setTitle("Pixel Coffee")
	love.window.setMode(1280, 720, {fullscreen = false, fullscreentype="desktop", resizable = true})
	__pixcof.loveShortcuts()
	__pixcof.Resources:init()
	__pixcof.Input:init()
	if args[1] == "-debug" then
		__pixcof.Mode = __pixcof.Debug:new()
		__pixcof.Mode:initImGui()
	else
		__pixcof.Mode = __pixcof.Game:new()
	end
end

__pixcof.loveShortcuts = function()
	lg = love.graphics
	lm = love.mouse
	lf = love.filesystem
	lk = love.keyboard
end

__pixcof.update = function(dt)
	--print(3 | 5)
	--print(__pixcof.Debug)
	__pixcof.Input:update(dt)
	__pixcof.Mode:update(dt)
	lurker.update(dt)
end
__pixcof.draw = function() 
	__pixcof.Mode:draw()
end

__pixcof.Log = function(...) 
	__pixcof.Mode:Log(...)
end

return __pixcof