--local Scene = require("scenes.menuscene")
local SceneManager = {}

SceneManager.currentScene = nil

function SceneManager:init()
end

function SceneManager:createEntity(x, y, entity)
	if self.currentScene then
		self.currentScene:createEntity(x, y, entity)
	end
end

function SceneManager:changeScene(scene)
	--print(scene)
	self.currentScene = scene
end

function SceneManager:getCurrent()
	return self.currentScene
end

function SceneManager:getEntities()
	if  not self.currentScene then
		return nil
	end
	return self.currentScene.entities
end

function SceneManager:update(dt)
	if self.currentScene then
		self.currentScene:update(dt)
	end
end

function SceneManager:preDraw()
	if self.currentScene then
		self.currentScene:preDraw()
	end
end

function SceneManager:draw()
	if self.currentScene then
		self.currentScene:draw()
	end
end

function SceneManager:postDraw()
	if self.currentScene then
		self.currentScene:postDraw()
	end
end

return SceneManager