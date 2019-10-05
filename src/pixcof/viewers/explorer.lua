local Viewer = require("pixcof.viewers.viewer")
local Explorer = Viewer:extend("Explorer")

function Explorer:constructor(debug)
	self.super.constructor(self, debug)
	--print()
end

function Explorer:draw()
	self.open = imgui.Begin("Explorer", true)
	if self.open then
		if imgui.SmallButton("reload") then end
	end

	self:drawRoot()
	imgui.End()
end

function Explorer:drawRoot()
	local items = lf.getDirectoryItems("/")
	if imgui.TreeNode("Project") then
		for i,item in ipairs(items) do
			if lf.getInfo(item).type == "directory" then
				self:drawDirectory("", item)
			end
		end
		for i,item in ipairs(items) do
			if lf.getInfo(item).type == "file" then
				self:drawFile("", item)
			end
		end
		imgui.TreePop()
	end
end

function Explorer:drawDirectory(parent, directory)
	local items = lf.getDirectoryItems(parent .. directory)
	local dir = parent .. "/" .. directory .. "/"
	--print(lume.count(items))
	if imgui.TreeNode(directory) then
		for i,item in ipairs(items) do
			print(parent .. directory .. item)
			if lf.getInfo(dir .. item).type == "directory" then
				self:drawDirectory(dir, item)
			end
		end
		for i,item in ipairs(items) do
			if lf.getInfo(dir .. item).type == "file" then
				self:drawFile(dir, item)
			end
		end
		imgui.TreePop()
	end
end

function Explorer:drawFile(parent, file)
	if imgui.Selectable(file) then
		self.debug:openFile(file, parent .. file)
	end
end

return Explorer