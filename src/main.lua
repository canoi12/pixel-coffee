pixcof = require("pixcof")

function love.load(args)
	pixcof.init(args)
end

function love.update(dt)
	pixcof.update(dt)
end

function love.draw()
	pixcof.draw()
end