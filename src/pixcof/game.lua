local Class = require("pixcof.class")
local Scene = require("pixcof.scene")
local SceneManager = require("pixcof.scenemanager")
local Game = Class:extend("Game")

function Game:constructor()
	SceneManager:changeScene(Scene("teste"))
end

function Game:update(dt)
	SceneManager:update(dt)
end

function Game:beginDraw() end
function Game:endDraw() end
function Game:draw()
	SceneManager:draw()
end

function Game:Log(...) 
	print(...)
end

return Game