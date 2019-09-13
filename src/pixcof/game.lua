local Class = require("pixcof.class")
local Game = Class:extends("Game")

function Game:constructor()

end

function Game:update(dt)
end

function Game:beginDraw() end
function Game:endDraw() end
function Game:draw() end

function Game:Log(...) 
	print(...)
end

return Game