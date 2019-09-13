local Class = {}
Class.__index = Class
Class.__super = nil

function Class:constructor()
	self.name = "Class"
end

function Class:extends(name)
	local o = setmetatable({}, { __index = self })
	o.name = name or o.name
	return o
end

function Class:new(...) 
	local o = setmetatable({}, { __index  = self })
	o:constructor(...)
	return o
end

return Class