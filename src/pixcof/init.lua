io.stdout:setvbuf("no")
local __pixcof = {}

__pixcof.Class = require("pixcof.class")
__pixcof.Debug = require("pixcof.debug")
__pixcof.Game = require("pixcof.game")

__pixcof.init = function(args)
	love.window.setTitle("Pixel Coffee")
	love.window.setMode(1280, 720, {fullscreen = false, fullscreentype="desktop", resizable = true})
end

__pixcof.update = function(dt) end
__pixcof.draw = function() end

__pixcof.Log = function(...) end

return __pixcof