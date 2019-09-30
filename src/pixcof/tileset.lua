local Class = require("pixcof.class")
local Resources = require("pixcof.resources")
local Tileset = Class:extend("Tileset")

function Tileset:constructor(tileset)
	self.name = tileset.name
	self.tilew = tileset.tilew
	self.tileh = tileset.tileh
	self.imageName = tileset.image
	--print(image)
	self.image = Resources:getImage(tileset.image)

	self.quads = self:loadQuads(tileset.quads)
	self.autotiles = self:loadAutotiles(tileset.autotiles)
end

function Tileset:loadQuads(quads)
	if not quads then return {[1] = {0, 0, self.tilew, self.tileh}} end
	local rquads = {}
	for i,quad in ipairs(quads) do
		lume.push(rquads, lg.newQuad(quad[1], quad[2], quad[3], quad[4], self.image:getDimensions()))
	end
	return rquads
end

function Tileset:loadAutotiles(autotiles)
	if not autotiles then return {} end
	local rautotiles = {}
	for i,autotile in ipairs(autotiles) do
		lume.push(rautotiles, autotile)
	end
	return rautotiles
end

function Tileset:toTable()
	local tileset = {}
	tileset.name = self.name
	tileset.tilew = self.tilew
	tileset.h = self.tileh
	tileset.image = self.imageName
	tileset.quads = {}
	tileset.autotiles = {}

	for i,quad in ipairs(self.quads) do
		lume.push(tileset.quads, {quad:viewPort()})
	end

	for i,autotile in ipairs(self.autotiles) do
		lume.push(tileset.autotiles, autotile)
	end

	return tileset
end

function Tileset:generateTable(tileset)
	local rtileset = {}
	rtileset.name = tileset.name
	rtileset.tilew = tileset.tilew
	rtileset.h = tileset.tileh
	rtileset.image = tileset.imageName
	rtileset.quads = {}
	rtileset.autotiles = tileset.autotiles or {}
	for i,quad in ipairs(tileset.quads or {}) do
		lume.push(tileset.quads, {quad:viewPort()})
	end

	for i,autotile in ipairs(tileset.autotiles or {}) do
		lume.push(tileset.autotiles, autotile)
	end

	return tileset
end

return Tileset