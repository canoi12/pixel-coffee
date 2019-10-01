local lume = require("pixcof.libs.lume")
require("lfs")
--local bitser = require("pixcof.libs.bitser")
local serialize = require "pixcof.libs.ser"

local getItems = love.filesystem.getDirectoryItems

local Resources = {
	images = {},
	tilesets = {},
	tilemaps = {},
	sprites = {},
	animations = {},
	fonts = {},
	audio = {},
	map = {},
	objects = {},
	scenes = {},
	imagesPath = "assets/images/",
	scenesPath = "scenes/",
  	objectsPath = "objects/"
}

function Resources:init()

	for k,v in ipairs(getItems(self.imagesPath)) do
		self:loadImage(v, v)
	end

	for k,v in ipairs(getItems(self.scenesPath)) do
		self:loadScene(v)
	end
  
	for k,v in ipairs(getItems(self.objectsPath)) do
		self:loadObject(v)
	end

	self:loadTilesets()
	self:loadSprites()
	self:loadAnimations()
	self:loadSystemImages()
	self:loadSystemFonts()
	self:loadTilemaps()

	self:initImages()

	--print("Resources loaded")
end

function Resources:getImage(name)
	return self.images[name]
end

function Resources:loadImage(name, path)
	self.images[name] = love.graphics.newImage(self.imagesPath .. path)
end

function Resources:initImages()
	for k,v in pairs(self.images) do
		v:setFilter("nearest", "nearest")
	end
end

function Resources:loadSystemImages()
	local images_path = "pixcof/assets/images/"
	for i,v in ipairs(getItems(images_path)) do
		if string.sub(v, -3) == "png" then
			local name = string.sub(v, 1, -5)
			--self:loadFont(name, fonts_path .. v)
			self.images[name] = lg.newImage(images_path .. v)
		end
	end

end

function Resources:loadScene(path)
	local path = lume.split(path, ".")[1]
	local rscene = require(self.scenesPath .. path)
	self.scenes[rscene.name] = rscene
end

function Resources:loadObject(path)
  local path = lume.split(path, ".")[1]
  local robject = require(self.objectsPath .. path)
  self.objects[robject.__class] = robject
end

function Resources:loadFont(name, path, size)
	local size = size or 16
	self.fonts[name] = love.graphics.newFont(path, size)
	self.fonts[name]:setFilter("nearest", "nearest")
end

function Resources:getFont(name)
	return self.fonts[name] or self.fonts.minimal4
end

function Resources:loadSystemFonts()
	local fonts_path = "pixcof/assets/fonts/"
	for i,v in ipairs(getItems(fonts_path)) do
		if string.sub(v, -3) == "ttf" then
			local name = string.sub(v, 1, -5)
			self:loadFont(name, fonts_path .. v)
		end
	end
end

function Resources:initFonts()
	for k,font in pairs(self.fonts) do
		font:setFilter("nearest", "nearest")
	end
end

function Resources:getScene(name)
	return self.scenes[name] or {}
end

function Resources:getObject(name)
  return self.objects[name] or {}
end

function Resources:getAnimation(name)
	return self.animations[name] or {}
end

function Resources:getSprite(name)
	return self.sprites[name] or {}
end

function Resources:getTileset(name)
	return self.tilesets[name] or {}
end

function Resources:getTilemap(name)
	return self.tilemaps[name] or {}
end

function Resources:loadAnimations()
	local animations = getItems("assets/animations/")
	for i,animation in ipairs(animations) do
		local name = lume.split(animation, ".")[1]
		self.animations[name] = require("assets/animations/" .. name)
	end
end

function Resources:loadSprites()
	local sprites = getItems("assets/sprites/")
	for i,sprite in ipairs(sprites) do
		local name = lume.split(sprite, ".")[1]
		self.sprites[name] = require("assets/sprites/" .. name)
	end
end

function Resources:loadTilesets()
	local tilesets = getItems("assets/tilesets/")
	for i,tileset in ipairs(tilesets) do
		local name = lume.split(tileset, ".")[1]
		local tst = require("assets/tilesets/" .. name)
		self.tilesets[name] = require("assets/tilesets/" .. name)
		--print(name, tst.image)
	end
end

function Resources:loadTilemaps()
	local tilemaps = getItems("assets/tilemaps/")
	for i,tilemap in ipairs(tilemaps) do
		local name = lume.split(tilemap, ".")[1]
		self.tilemaps[name] = require("assets/tilemaps/" .. name)
	end
end

function Resources:saveSprite(name, sprite)
	local sprites_path = "assets/sprites/"
	if not lf.getInfo(sprites_path) then
		lfs.mkdir("src/" .. sprites_path)
	end

	local data = serialize(sprite)
	local f = io.open("src/" .. sprites_path .. name .. ".lua", "w")
	f:write(data)
	f:close()
	self.sprites[name] = sprite
end

function Resources:saveAnimation(name, animation)
	local animation_path = "assets/animations/"
	if not love.filesystem.getInfo(animation_path) then
		lfs.mkdir("src/" .. animation_path)
	end
	--local data = bitser.dumps(animation)
	local data = serialize(animation)
	local f = io.open("src/" .. animation_path .. name .. ".lua", "w")
	f:write(data)
	f:close()
	self.animations[name] = animation
end

function Resources:saveTileset(name, tileset)
	local tileset_path = "assets/tilesets/"
	if not love.filesystem.getInfo(tileset_path) then
		lfs.mkdir("src/" .. tileset_path)
	end
	local data = serialize(tileset)
	local f = io.open("src/" .. tileset_path .. name .. ".lua", "w")
	f:write(data)
	f:close()
	self.tilesets[name] = tileset
end

function Resources:saveTilemap(name, tilemap)
	local tilemap_path = "assets/tilemaps/"
	if not love.filesystem.getInfo(tilemap_path) then
		lfs.mkdir("src/" .. tilemap_path)
	end
	local data = serialize(tilemap)
	--print(data)
	local f = io.open("src/" .. tilemap_path .. name .. ".lua", "w")
	f:write(data)
	f:close()
	self.tilemaps[name] = tilemap
end

function Resources:removeAnimation(name)
	local animation_path = "assets/animations/"
	--print(animation_path .. name .. ".lua")
	if not love.filesystem.getInfo(animation_path .. name .. ".lua") then
		return
	end
	os.remove("src/" .. animation_path .. name .. ".lua")
	self.animations[name] = nil
	--self:loadAnimations()
end

function Resources:removeSprite(name)
	local sprites_path = "assets/sprites/"
	--print(animation_path .. name .. ".lua")
	if not love.filesystem.getInfo(sprites_path .. name .. ".lua") then
		return
	end
	os.remove("src/" .. sprites_path .. name .. ".lua")
	self.sprites[name] = nil
end

function Resources:removeTileset(name)
	local tileset_path = "assets/tilesets/"
	--print(tileset_path .. name .. ".lua")
	if not love.filesystem.getInfo(tileset_path .. name .. ".lua") then
		return
	end
	os.remove("src/" .. tileset_path .. name .. ".lua")
	self:loadTilesets()
end

function Resources:removeTilemap(name)
	local tilemap_path = "assets/tilemaps/"
	--print(tileset_path .. name .. ".lua")
	if not love.filesystem.getInfo(tilemap_path .. name .. ".lua") then
		return
	end
	os.remove("src/" .. tilemap_path .. name .. ".lua")
	self.tilemaps[name] = nil
	--self:loadTilemaps()
end

return Resources