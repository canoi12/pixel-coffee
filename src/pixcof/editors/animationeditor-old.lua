local Editor = require("pixcof.editors.editor")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
--local bitser = require("pixcof.libs.bitser")
local AnimationEditor = Editor:extend("AnimationEditor")

function AnimationEditor:constructor(debug, name, animation)
    Editor.constructor(self, debug)
    self.open = true

    self.animation = animation

	self.animationSetViewerProps = {
		frameName = "",
		image = nil,
		image_scale = 1,
		image_width = 0,
		image_height = 0,
		quads = {}
	}
	
	self.animationSet = Resources.animations
	self.currentAnimationSet = animation

	self.editAnimationSet = {
		current = "",
		new = "",
		edit = false,
		imgindex = 1,
		image = ""
	}


	self.currentAnimation = {
		cspeed = 1,
		speed = 1,
		frame = 0,
		image = "",
		playing = false,
		name = "",
		stframe = 0,
		enframe = 0
	}

	self.frameName = ""
	self.imageScale = 1
	self.firstOpen = true

	self.newAnim = {
		name = "",
		imgindex = 1,
		image = ""
	}

	self.currentFrame = {}
end

--function AnimationEditor:

function AnimationEditor:createNewSet()
	local w = imgui.GetWindowWidth()
	if imgui.Button("Add") then
		if self.animationSet[self.newAnim.name] == nil then
			self.animationSet[self.newAnim.name] = {
				image = self.newAnim.image,
				tilew = 32,
				tileh = 32,
				animations = {},
				quads = {}
			}
			self.newAnim.name = ""
			self.newAnim.image = ""
		end
	end
	imgui.SameLine()
	if imgui.Button("Save") then
		self:save()
	end
	imgui.SameLine()
	imgui.PushItemWidth(-w/2)
	self.newAnim.name = imgui.InputText("##anim_name", self.newAnim.name, 32)
	imgui.SameLine()
	imgui.PushItemWidth(-w/4)
	local keys = lume.keys(Resources.images)
	self.newAnim.imgindex = imgui.Combo("##images", self.newAnim.imgindex, keys, lume.count(keys))
	self.newAnim.image = keys[self.newAnim.imgindex]
	imgui.PopItemWidth()
	imgui.Separator()
end

--- List all animations sets
function AnimationEditor:listAnimationSets()
	for k,anim in pairs(self.animationSet) do
		if imgui.SmallButton("x##remove_anim" .. k) then
			self.animationSet[k] = nil
			self.currentAnimationSet = nil
		end
		imgui.SameLine()
		if imgui.SmallButton("..##edit_" .. k) then
			self.editAnimationSet.current = k
			self.editAnimationSet.new = k
			self.editAnimationSet.edit = true
		end
		imgui.SameLine()
		if imgui.Selectable(k) then
			self.currentAnimationSet = k
			self:resetCurrent()
		end
	end

	if self.editAnimationSet.edit then
		imgui.OpenPopup("Edit " .. self.editAnimationSet.current .. "##edit_anim")
	end

	if imgui.BeginPopupModal("Edit " .. self.editAnimationSet.current .. "##edit_anim", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		--print("Testeeee")
		local animation = self.animationSet[self.editAnimationSet.current]
		self.editAnimationSet.new = imgui.InputText("Name", self.editAnimationSet.new, 32)
		local keys = lume.keys(Resources.images)
		self.editAnimationSet.imgindex = imgui.Combo("##images", self.editAnimationSet.imgindex, keys, lume.count(keys))
		self.editAnimationSet.image = keys[self.editAnimationSet.imgindex]
		imgui.Separator()
		if imgui.Button("Save") then
			local animation = self.animationSet[self.editAnimationSet.current]
			if self.editAnimationSet.current ~= self.editAnimationSet.new then
				lume.remove(self.animationSet, animation)
				self.animationSet[self.editAnimationSet.new] = animation
			end
			animation.image = self.editAnimationSet.image
			self.editAnimationSet.edit = false
			if self.currentAnimationSet == self.editAnimationSet.current then
				self.currentAnimationSet = self.editAnimationSet.new
			end
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button("Cancel") then
			self.editAnimationSet.edit = false
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function AnimationEditor:listAnimations()
	local animation = self.animationSet[self.currentAnimationSet]
	local image = self.animationSetViewerProps.image

	local tw, th = (self.animationSetViewerProps.image_width/animation.tilew), (self.animationSetViewerProps.image_height/animation.tileh)

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

--- Open the animation set viewer
function AnimationEditor:currentAnimationSetViewer()
	local animation = self.animationSet[self.currentAnimationSet]
	self.animationSetViewerProps.image = Resources:getImage(animation.image)
	local image = self.animationSetViewerProps.image
	self.animationSetViewerProps.image_width, self.animationSetViewerProps.image_height = image:getDimensions()
	local image_width, image_height = self.animationSetViewerProps.image_width, self.animationSetViewerProps.image_height
	local canvas = love.graphics.newCanvas(image_width, image_height)
	local image_scale = self.animationSetViewerProps.image_scale
	self.animationSetViewerProps.quads = {}
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
			lume.push(self.animationSetViewerProps.quads, quad)
			lume.push(animation.quads, {quad:getViewport()})
			love.graphics.draw(image, quad, xx, yy)
			love.graphics.rectangle("line", xx, yy, ww, hh)
			love.graphics.circle("line", xx + (ww/2), yy + (hh/2), 2)
		end
	end
	love.graphics.setCanvas()
	local quads = self.animationSetViewerProps.quads
	local cw = imgui.GetWindowWidth()
	imgui.BeginChildFrame(1123, cw, image_height * self.animationSetViewerProps.image_scale + 20, {"ImGuiWindowFlags_HorizontalScrollbar"})
	imgui.Image(canvas, image_width * image_scale, image_height * image_scale)
	imgui.EndChildFrame()


	self.animationSetViewerProps.image_scale = imgui.SliderInt("Zoom", self.animationSetViewerProps.image_scale, 1, 8)
	animation.tilew, animation.tileh = imgui.DragInt2("Cell Size", animation.tilew, animation.tileh)
	animation.tilew = lume.clamp(animation.tilew, 1, image_width)
	animation.tileh = lume.clamp(animation.tileh, 1, image_height)
	imgui.Separator()
	
	self.animationSetViewerProps.frameName = imgui.InputText("##frame_name", self.animationSetViewerProps.frameName, 32, ".1f")
	imgui.SameLine()
	if imgui.Button("Add") then
		local frame = {
			name = self.animationSetViewerProps.frameName,
			stframe = 0,
			enframe = 0
		}
		if self.animationSetViewerProps.frameName ~= "" then
			table.insert(animation.animations, frame)
			self.animationSetViewerProps.frameName = ""
		end
	end
end

--- Open the current animation viewer
function AnimationEditor:currentAnimationViewer()
	local animation = self.currentAnimation
	local image = self.animationSetViewerProps.image
	local w,h = image:getDimensions()
	local quads = self.animationSetViewerProps.quads
	local ww = imgui.GetColumnWidth()
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
		imgui.Image(image, ww, ww, qx, qy, qw, qh)
	else
		local qx,qy,qw,qh = quads[1]:getViewport()
		qx = qx/w
		qy = qy/h
		qw = qx + qw/w
		qh = qy + qh/h
		imgui.Image(image, ww, ww, qx, qy, qw, qh)
	end
	animation.speed = imgui.DragInt("Speed##anim_spd", animation.speed)
end

--- Reset the current playing animation state
function AnimationEditor:resetCurrent()
	self.currentAnimation.name = ""
	self.currentAnimation.playing = false
	self.currentAnimation.image = nil
end

function AnimationEditor:draw()
	if self.open then
		imgui.Begin("Animation Editor")

		--self:createNewSet()

		imgui.Columns(3)
		if self.firstOpen then
			local w = imgui.GetWindowSize()
			imgui.SetColumnWidth(0, w/4)
			imgui.SetColumnWidth(1,w/2)
			self.firstOpen = false
		end

		--self:listAnimationSets()

		imgui.NextColumn()

		if self.currentAnimationSet then 
			--for k,anim in pairs(self.animations[self.currentAnimation]) do
			imgui.BeginChild("Animation Editor##anim_editor")
			self:currentAnimationSetViewer()
			self:listAnimations()
			--[[
			]]

			imgui.EndChild()

			imgui.NextColumn()

			self:currentAnimationViewer()

			--imgui.BeginChild("Animation Viewer##anim_viewer")
			--imgui.Text("Preview")
			--[[
			--imgui.EndChild()
			--end
			--[[local image = Resources:getImage("knight-walk.png")
			local w,h = image:getDimensions()
			imgui.Image(image, w, h)
			if imgui.Button("Add") then

			end
			imgui.Text("Idle")
			imgui.SameLine()
			imgui.DragInt2("##frames", 2, 5)
			imgui.SameLine()
			if imgui.SmallButton("-") then
			end]]
		end
		--self:save()

		imgui.End()
	end
end

function AnimationEditor:save()
	--local test = bitser.dumps(self.animationSet)
	for k,animation in pairs(self.animationSet) do
		Resources:saveAnimation(k, animation)
	end
	--print(test)
end

return AnimationEditor