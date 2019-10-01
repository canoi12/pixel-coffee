local Editor = require("pixcof.editors.editor")
local Resources = require("pixcof.resources")
local SpriteEditor = Editor:extend("SpriteEditor")

function SpriteEditor:constructor(debug, name, sprite)
	Editor.constructor(debug)
	self.asset = {
		name = name,
		sprite = sprite
	}
	self.image = Resources:getImage(self.asset.sprite.image)
	self.open = true

	self.editAnimation = {
		framename = "",
		imagescale = 1,
		quads = {}
	}

	self.currentAnimation = {
		playing = false,
		image = Resources:getImage(self.asset.sprite.image),
		name = "",
		stframe = 0,
		enframe = 0,
		speed = 4,
		cspeed = 0
	}
end

function SpriteEditor:drawSpriteInfo()
	if imgui.SmallButton("save") then self:saveAnimation() end
	self.asset.sprite.name = imgui.InputText("name##animation_" .. self.asset.name .. "_name", self.asset.sprite.name or "", 50)
	self.asset.sprite.tilew, self.asset.sprite.tileh = imgui.DragInt2("size##animation_" .. self.asset.name .. "_size", self.asset.sprite.tilew, self.asset.sprite.tileh)
	local keys = lume.keys(Resources.images)
	local index = lume.find(keys, self.asset.sprite.image)
	index = imgui.Combo("image##animation_" .. self.asset.sprite.image, index, keys, #keys)
	self.asset.sprite.image = keys[index]
end

function SpriteEditor:drawAnimationsViewer()
	local sprite = self.asset.sprite
	local image = Resources:getImage(sprite.image)

	local image_width, image_height = image:getDimensions()
	local canvas = love.graphics.newCanvas(image_width, image_height)
	local image_scale = self.editAnimation.imagescale
	
	local quads = {}
	sprite.quads = {}
	-- local quads = {}
	canvas:setFilter("nearest", "nearest")
	love.graphics.setCanvas(canvas)
	local tw = image_width/sprite.tilew
	local th = image_height/sprite.tileh
	for j=0,th-1 do
		for i=0,tw-1 do
			local xx, yy, ww, hh = i * sprite.tilew, j * sprite.tileh, sprite.tilew, sprite.tileh
			local quad = love.graphics.newQuad(xx, yy, ww, hh, image_width, image_height)
			lume.push(quads, quad)
			lume.push(sprite.quads, {quad:getViewport()})
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
			table.insert(sprite.animations, frame)
			self.editAnimation.framename = ""
		end
	end
end

function SpriteEditor:listAnimations()
	local sprite = self.asset.sprite
	local image = Resources:getImage(sprite.image)
	local image_width, image_height = image:getDimensions()

	local tw, th = (image_width/sprite.tilew), (image_height/sprite.tileh)

	imgui.AlignTextToFramePadding()
	for i,v in ipairs(sprite.animations) do
		if imgui.SmallButton("x##" .. v.name .. "_remove") then
			-- print("Remove " .. v.name)
			table.remove(sprite.animations, i)
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

function SpriteEditor:currentAnimationViewer()
	local animation = self.currentAnimation
	local image = Resources:getImage(self.asset.sprite.image)
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
			local ww, hh = self.asset.sprite.tilew, self.asset.sprite.tileh
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

function SpriteEditor:draw()
	self.open = imgui.Begin(self.asset.name, true)
	if self.open then
		imgui.Columns(2)
		if imgui.BeginChild("Props##props_and_viewer") then
			self:drawSpriteInfo()
			imgui.Separator()
			self:currentAnimationViewer()
			imgui.EndChild()
		end
		imgui.NextColumn()
		self:drawAnimationsViewer()
		self:listAnimations()
		--imgui.NextColumn()
	else
		self:saveAnimation()
	end
	imgui.End()
end

function SpriteEditor:saveAnimation()
	if self.asset.name ~= self.asset.sprite.name then
		Resources:removeSprite(self.asset.name)
	end
	Resources:saveSprite(self.asset.sprite.name, self.asset.sprite)
end

return SpriteEditor