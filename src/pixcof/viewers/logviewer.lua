local Viewer = require("pixcof.viewers.viewer")
local LogViewer = Viewer:extend("LogViewer")

function LogViewer:constructor(debug)
	self.super.constructor(self, debug)
	self.log = {}
	self.filter = ""
	self.filter_case_sensitive = false
	-- body
end

function LogViewer:pushLog(...)
	local logs = {...}

	print(...)
	--print(logs[2])
	local line = debug.getinfo(2).currentline
	local file = debug.getinfo(2).source
	local result = "[" .. file .. ":" .. line .. "]" .. " "
	for i,log in ipairs(logs) do
		result = result .. log .. " "
	end
	--print(result)
	--[[for i,v in ipairs(...) do
		print(result)
		result = result .. " "
	end]]
	lume.push(self.log, result)
end

function LogViewer:draw()
	self.open = imgui.Begin("Log", true)
	if self.open then
		if imgui.Button("Clear") then
			lume.clear(self.log)
		end

		imgui.SameLine()
		self.filter = imgui.InputText("Filter", self.filter, 32)
		imgui.SameLine()
		if imgui.SmallButton("x") then
			self.filter = ""
		end
		imgui.SameLine()
		self.filter_case_sensitive = imgui.Checkbox("Aa", self.filter_case_sensitive)
		imgui.Separator()

		local filter = self.filter
		if not self.filter_case_sensitive then
			filter = lume.filter(self.log, function(x) return string.match(x:lower(), self.filter:lower()) end)
		else
			filter = lume.filter(self.log, function(x) return string.match(x, self.filter) end)
		end
		filter = lume.last(filter, 50)
		--self:Log("Opa")
		for i,log in lume.ripairs(filter) do
			imgui.Text(log)
		end
		--imgui.Text(self.log)	
	end
	imgui.End()
end

return LogViewer