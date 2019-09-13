io.stdout:setvbuf("no")
require "imgui"
local __pixcof = {}

__pixcof.Class = require("pixcof.class")
__pixcof.Debug = require("pixcof.debug")
__pixcof.Game = require("pixcof.game")

__pixcof.Mode = {}

__pixcof.init = function(args)
	love.window.setTitle("Pixel Coffee")
	love.window.setMode(1280, 720, {fullscreen = false, fullscreentype="desktop", resizable = true})
	__pixcof.loveShortcuts()
	if args[1] == "-debug" then
		__pixcof.Mode = __pixcof.Debug:new()
		__pixcof.Mode:initImGui()
	else
		__pixcof.Mode = __pixcof.Game:new()
	end
end

__pixcof.loveShortcuts = function()
	lg = love.graphics
	lm = love.math
	lf = love.filesystem
	lk = love.keyboard
end

__pixcof.update = function(dt) 
	__pixcof.Mode:update(dt)
end
__pixcof.draw = function() 
	__pixcof.Mode:draw()
end

__pixcof.Log = function(...) 
	__pixcof.Mode:Log(...)
end

return __pixcof