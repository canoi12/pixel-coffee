local Editor = require("pixcof.editors.editor")
local Resources = require("pixcof.resources")
local AnimationEditor = Editor:extend("AnimationEditor")

function AnimationEditor:constructor(debug, name, animation)
	Editor.constructor(debug)
	self.asset = {
		name = name,
		animation = animation
	}
	self.image = Resources:getImage(self.asset.animation.image)
	self.open = true

	self.editAnimation = {
		framename = "",
		imagescale = 1,
		quads = {}
	}

	self.currentAnimation = {
		playing = false,
		image = Resources:getImage(self.asset.animation.image),
		name = "",
		stframe = 0,
		enframe = 0,
		speed = 4,
		cspeed = 0
	}
end

function AnimationEditor:drawAnimationInfo()
	if imgui.SmallButton("save") then self:saveAnimation() end
	self.asset.animation.name = imgui.InputText("name##animation_" .. self.asset.name .. "_name", self.asset.animation.name or "", 50)
	self.asset.animation.tilew, self.asset.animation.tileh = imgui.DragInt2("size##animation_" .. self.asset.name .. "_size", self.asset.animation.tilew, self.asset.animation.tileh)
	local keys = lume.keys(Resources.images)
	local index = lume.find(keys, self.asset.animation.image)
	index = imgui.Combo("image##animation_" .. self.asset.animation.image, index, keys, #keys)
	self.asset.animation.image = keys[index]
end

function AnimationEditor:drawAnimationsViewer()
	local animation = self.asset.animation
	--self.animationSetViewerProps.image = Resources:getImage(animation.image)
	local image = Resources:getImage(self.asset.animation.image)
	--self.animationSetViewerProps.image_width, self.animationSetViewerProps.image_height = image:getDimensions()
	local image_width, image_height = image:getDimensions()
	local canvas = love.graphics.newCanvas(image_width, image_height)
	local image_scale = self.editAnimation.imagescale
	--self.animationSetViewerProps.quads = {}
	local quads = {}
	animation.quads = {}
	-- local quads = {}
	canvas:setFilter("nearest", "nearest")
	love.graphics.setCanvas(canvas)
	local tw = image_width/animation.tilew
	local th = image_height/animation.tileh
	for j=0,th-1 do
		for i=0,tw-1 do
			local xx, yy, ww, hh = i * animation.tilew, j * animation.tileh, animation.tilew, animation.tileh
			local quad = love.graphics.newQuad(xx, yy, ww, hh, image_width, image_height)
			lume.push(quads, quad)
			lume.push(animation.quads, {quad:getViewport()})
			love.graphics.draw(image, quad, xx, yy)
			love.graphics.rectangle("line", xx, yy, ww, hh)
			love.graphics.circle("line", xx + (ww/2), yy + (hh/2), 2)
		end
	end
	love.graphics.setCanvas()
	--local quads = self.animationSetViewerProps.quads
	self.editAnimation.quads = quads
	local cw = imgui.GetWindowWidth()
	self.editAnimation.imagescale = imgui.SliderInt("Zoom", image_scale, 1, 8)
	imgui.BeginChildFrame(1123, cw, image_height * image_scale + 20, {"ImGuiWindowFlags_HorizontalScrollbar"})
	imgui.Image(canvas, image_width * image_scale, image_height * image_scale)
	imgui.EndChildFrame()

	--[[animation.tilew, animation.tileh = imgui.DragInt2("Cell Size", animation.tilew, animation.tileh)
	animation.tilew = lume.clamp(animation.tilew, 1, image_width)
	animation.tileh = lume.clamp(animation.tileh, 1, image_height)]]
	--imgui.Separator()
	
	self.editAnimation.framename = imgui.InputText("##frame_name", self.editAnimation.framename, 32, ".1f")
	imgui.SameLine()
	if imgui.Button("Add") then
		local frame = {
			name = self.editAnimation.framename,
			stframe = 0,
			enframe = 0
		}
		if self.editAnimation.framename ~= "" then
			table.insert(animation.animations, frame)
			self.editAnimation.framename = ""
		end
	end
end

function AnimationEditor:listAnimations()
	local animation = self.asset.animation
	local image = Resources:getImage(animation.image)
	local image_width, image_height = image:getDimensions()

	local tw, th = (image_width/animation.tilew), (image_height/animation.tileh)

	imgui.AlignTextToFramePadding()
	for i,v in ipairs(animation.animations) do
		if imgui.SmallButton("x##" .. v.name .. "_remove") then
			-- print("Remove " .. v.name)
			table.remove(animation.animations, i)
			self.currentAnimation.name = ""
			self.currentAnimation.playing = false
			self.currentAnimation.image = image
		end
		imgui.SameLine()
		imgui.Text(v.name)
		imgui.SameLine()
		v.stframe, v.enframe = imgui.DragInt2("##".. v.name .."_frames", v.stframe, v.enframe, 1)
		v.stframe = lume.clamp(v.stframe, 0, (tw*th)-1)
		v.enframe = lume.clamp(v.enframe, 0, (tw*th)-1)
		imgui.SameLine()
		if self.currentAnimation.playing and self.currentAnimation.name == v.name then
			if imgui.SmallButton("stop##" .. v.name .. "_stop") then
				self.currentAnimation.name = ""
				self.currentAnimation.playing = false
				self.currentAnimation.image = image
			end
			self.currentAnimation.stframe = v.stframe
			self.currentAnimation.enframe = v.enframe
		else
			if imgui.SmallButton("play##" .. v.name .. "_play") then
				self.currentAnimation.name = v.name
				self.currentAnimation.playing = true
				self.currentAnimation.frame = 0
			end
		end
	end
end

function AnimationEditor:currentAnimationViewer()
	local animation = self.currentAnimation
	local image = Resources:getImage(self.asset.animation.image)
	local w,h = image:getDimensions()
	local quads = self.editAnimation.quads
	local ww = imgui.GetWindowWidth()
	local hh = imgui.GetWindowHeight()
	--print(imgui.GetWindowHeight())
	animation.speed = imgui.DragInt("Speed##anim_spd", animation.speed)
	local cpos = {imgui.GetCursorPos()}
	local imgsize = math.min(ww, hh-cpos[2])
	if animation.playing then
		animation.cspeed = animation.cspeed - (animation.speed * 0.05)

		if animation.cspeed <= 0 then
			--print("ChangeAnim")
			animation.frame = animation.frame + 1
			if animation.frame > animation.enframe then
				animation.frame = animation.stframe
			end
			animation.cspeed = 1
		end
		
		animation.frame = lume.clamp(animation.frame, animation.stframe, animation.enframe)

		local qx,qy,qw,qh = quads[animation.frame+1]:getViewport()
		qx = qx/w
		qy = qy/h
		qw = qx + qw/w
		qh = qy + qh/h
		imgui.Image(image, imgsize, imgsize, qx, qy, qw, qh)
	else
		if lume.count(quads) <= 0 then
			local ww, hh = self.asset.animation.tilew, self.asset.animation.tileh
			quads[1] = love.graphics.newQuad(0, 0, ww, hh, w, h)
		end
		local qx,qy,qw,qh = quads[1]:getViewport()
		qx = qx/w
		qy = qy/h
		qw = qx + qw/w
		qh = qy + qh/h
		imgui.Image(image, imgsize, imgsize, qx, qy, qw, qh)
	end
	--print(imgui.GetCursorPos())
end

function AnimationEditor:draw()
	self.open = imgui.Begin(self.asset.name, true)
	if self.open then
		imgui.Columns(2)
		if imgui.BeginChild("Props##props_and_viewer") then
			self:drawAnimationInfo()
			imgui.Separator()
			self:currentAnimationViewer()
			imgui.EndChild()
		end
		imgui.NextColumn()
		self:drawAnimationsViewer()
		self:listAnimations()
		--imgui.NextColumn()
	else
		Resources:saveAnimation(self.asset.animation.name, self.asset.animation)
		if self.asset.animation.name ~= self.asset.name then
			Resources:removeAnimation(self.asset.name)
		end
	end
	imgui.End()
end

function AnimationEditor:saveAnimation()
	if self.asset.name ~= self.asset.animation.name then
		Resources:removeAnimation(self.asset.name)
	end
	Resources:saveAnimation(self.asset.animation.name, self.asset.animation)
end

return AnimationEditor