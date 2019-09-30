local Editor = require("pixcof.editors.editor")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local TilesetEditor = Editor:extend("TilesetEditor")
local Animation = {}

local autotileref = {
    1, 2, 4, 8, 0, 16, 32, 64, 128
}

function TilesetEditor:constructor()
    Editor.constructor(self)
    self.open = false

    self.tilesets = Resources.tilesets
    self.newTileset = {
		name = "",
		imgindex = 1,
		image = ""
    }
    self.currentTileset = nil
    self.editTileset = {
        current = "",
        new = "",
        edit = false,
        imgindex = 1,
        image = ""
    }

	self.tilesetViewerProps = {
		frameName = "",
		image = nil,
		image_scale = 1,
		image_width = 0,
		image_height = 0,
		quads = {}
	}
    
    self.editAutotile = {
        edit = false,
        tiles = {}
    }
	self.firstOpen = true
end

--function Animation:

function TilesetEditor:createNewSet()
    local w = imgui.GetWindowWidth()
	if imgui.Button("Add") then
		if self.tilesets[self.newTileset.name] == nil then
			self.tilesets[self.newTileset.name] = {
				image = self.newTileset.image,
				tilew = 32,
				tileh = 32,
				quads = {},
				autotiles = {}
			}
			self.newTileset.name = ""
			self.newTileset.image = ""
		end
	end
	imgui.SameLine()
	if imgui.Button("Save") then
		self:save()
	end
    imgui.SameLine()
    imgui.PushItemWidth(-w/2)
    self.newTileset.name = imgui.InputText("##tileset_name", self.newTileset.name, 32)
    --imgui.PopItemWidth()
    imgui.PushItemWidth(-w/4)
    imgui.SameLine()
	local keys = lume.keys(Resources.images)
	self.newTileset.imgindex = imgui.Combo("##images", self.newTileset.imgindex, keys, lume.count(keys))
    self.newTileset.image = keys[self.newTileset.imgindex]
    imgui.PopItemWidth()
	imgui.Separator()
end

--- List all animations sets
function TilesetEditor:listTilesets()
	for k,tileset in pairs(self.tilesets) do
		if imgui.SmallButton("x##remove_tileset" .. k) then
			--self.tilesets[k] = nil
			lume.remove(self.tilesets, tileset)
			self.currentTileset = nil
			Resources:removeTileset(k)
		end
		imgui.SameLine()
		if imgui.SmallButton("..##edit_" .. k) then
			self.editTileset.current = k
			self.editTileset.new = k
			self.editTileset.edit = true
		end
		imgui.SameLine()
		if imgui.Selectable(k) then
			self.currentTileset = k
			self.editAutotile.edit = false
			--self:resetCurrent()
		end
	end

	if self.editTileset.edit then
		imgui.OpenPopup("Edit " .. self.editTileset.current .. "##edit_anim")
	end

	if imgui.BeginPopupModal("Edit " .. self.editTileset.current .. "##edit_anim", nil, {"ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_AlwaysAutoResize"}) then
		--print("Testeeee")
		local tileset = self.tilesets[self.editTileset.current]
		self.editTileset.new = imgui.InputText("Name", self.editTileset.new, 32)
		local keys = lume.keys(Resources.images)
		self.editTileset.imgindex = imgui.Combo("##images", self.editTileset.imgindex, keys, lume.count(keys))
		self.editTileset.image = keys[self.editTileset.imgindex]
		imgui.Separator()
		if imgui.Button("Save") then
			--local tileset = self.tilesets[self.editTileset.current]
			if self.editTileset.current ~= self.editTileset.new then
				lume.remove(self.tilesets, tileset)

				self.tilesets[self.editTileset.new] = tileset
			end
			tileset.image = self.editTileset.image
			self.editTileset.edit = false
			if self.currentTileset == self.editTileset.current then
				self.currentTileset = self.editTileset.new
			end
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button("Cancel") then
			self.editTileset.edit = false
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

--- Open the animation set viewer
function TilesetEditor:currentTilesetViewer()
	local tileset = self.tilesets[self.currentTileset]
	--print(tileset.image)
	self.tilesetViewerProps.image = Resources:getImage(tileset.image)
	local image = self.tilesetViewerProps.image
	self.tilesetViewerProps.image_width, self.tilesetViewerProps.image_height = image:getDimensions()
	local image_width, image_height = self.tilesetViewerProps.image_width, self.tilesetViewerProps.image_height
	local canvas = love.graphics.newCanvas(image_width, image_height)
	local image_scale = self.tilesetViewerProps.image_scale
	self.tilesetViewerProps.quads = {}
	-- local quads = {}
	tileset.quads = {}
	canvas:setFilter("nearest", "nearest")
	love.graphics.setCanvas(canvas)
	local tw = image_width/tileset.tilew
	local th = image_height/tileset.tileh
	for j=0,th-1 do
		for i=0,tw-1 do
			local xx, yy, ww, hh = i * tileset.tilew, j * tileset.tileh, tileset.tilew, tileset.tileh
			local quad = love.graphics.newQuad(xx, yy, ww, hh, image_width, image_height)
			lume.push(self.tilesetViewerProps.quads, quad)
			lume.push(tileset.quads, {quad:getViewport()})
			love.graphics.draw(image, quad, xx, yy)
			love.graphics.rectangle("line", xx, yy, ww, hh)
			--love.graphics.circle("line", xx + (ww/2), yy + (hh/2), 2)
		end
	end
	love.graphics.setCanvas()
	local quads = self.tilesetViewerProps.quads
	local cw = imgui.GetWindowWidth()
	imgui.BeginChildFrame(1123, cw - 24, image_height * self.tilesetViewerProps.image_scale + 20, {"ImGuiWindowFlags_HorizontalScrollbar"})
	imgui.Image(canvas, image_width * image_scale, image_height * image_scale)
	imgui.EndChildFrame()


	self.tilesetViewerProps.image_scale = imgui.SliderInt("Zoom", self.tilesetViewerProps.image_scale, 1, 8)
	tileset.tilew, tileset.tileh = imgui.DragInt2("Tile Size", tileset.tilew, tileset.tileh)
	tileset.tilew = lume.clamp(tileset.tilew, 1, image_width)
	tileset.tileh = lume.clamp(tileset.tileh, 1, image_height)
    imgui.Separator()

    if imgui.SmallButton("+ Autotile") then
        self:newAutoTile()
    end
    imgui.SameLine()
    if imgui.SmallButton("+ Animtile") then end
    imgui.Separator()
    local count = 0
    for k,tile in pairs(tileset.autotiles) do
        count = count + 1
        if imgui.SmallButton("x##autotile_" .. count) then 
        	table.remove(tileset.autotiles, count)
        end
        imgui.SameLine()
        if imgui.Selectable("Autotile #" .. count) then
            self.editAutotile.edit = true
            self.editAutotile.tiles = tileset.autotiles[count]
        end
    end
    --self:calcMask(1)
end

function TilesetEditor:newAutoTile()
    local tileset = self.tilesets[self.currentTileset]
    lume.push(tileset.autotiles, {})
end

function TilesetEditor:calcMask(value)
	local mask = {}
	for i=1,9 do
		mask[i] = 0
	end
	if value == nil or value == -1 then
		return mask
	end
	if value >= 0 then
		mask[5] = 1
	end
	local i = 1
	while(value > 0) do
		local rest = math.fmod(value, 2)
		if i == 5 then
			i = i + 1
		end
		mask[i] = rest
		value = (value-rest)/2
		i = i + 1
	end
	--[[for i,v in ipairs(mask) do
		print(i, v)
	end]]

	return mask
end

function TilesetEditor:calcValueFromMask(mask)
	local value = 0
	local aux = 1
	if not lume.any(mask, function(x) return x == 1 end) then
		return -1
	end
	for i,v in ipairs(mask) do
		if i ~= 5 then
			if v == 1 then
				value = value + (aux)
			end
			aux = aux * 2
		end
	end
	--print(value)

	return value
end
function TilesetEditor:autoTileEditor()
    if imgui.BeginChild("autoTileEditor", 0, 0, false, {"ImGuiWindowFlags_HorizontalScrollbar", "ImGuiWindowFlags_NoMove"}) then
        local tileset = self.editAutotile
        local image = self.tilesetViewerProps.image
        local imgw, imgh = self.tilesetViewerProps.image_width, self.tilesetViewerProps.image_height
        local tilew, tileh = self.tilesets[self.currentTileset].tilew, self.tilesets[self.currentTileset].tileh
        local maxtilew, maxtileh = imgw/tilew, imgh/tileh
        local ww = imgui.GetWindowWidth()
        local mouse_x, mouse_y = imgui.GetMousePos()
        local window_x, window_y = imgui.GetWindowPos()
        local scale = 2

        imgui.Text("mouse: " .. mouse_x .. "x" .. mouse_y)
        local local_x, local_y = mouse_x-window_x, mouse_y-window_y
        imgui.SameLine()
        local pos = math.floor(local_x/(tilew*scale)) + (maxtilew*math.floor(local_y/(tileh*scale)))
        imgui.Text("pos: " .. math.max(pos, 0))

        for imgi, teste in ipairs(self.tilesetViewerProps.quads) do
            local xxx = math.fmod(imgi-1, maxtilew)
            local yyy = math.floor((imgi-1)/maxtilew)
            local imgbtnx = xxx/maxtilew


            local imgbtny = 1/maxtilew*yyy
            local imgbtnw = (1/maxtilew)/3
            local imgbtnh = (1/maxtileh)/3


            if imgi-1 > 0 and xxx == 0 then
                imgui.NewLine()
                imgui.Separator()
            end

            imgui.BeginGroup()
            imgui.PushStyleVar("ImGuiStyleVar_ItemSpacing", 1, 2)
            
            local mask = self:calcMask(tileset.tiles[imgi])
            for i=0,8 do
            	local mask_index = i + 1

                local ii = math.fmod(i, 3)
                local ji = math.floor(i/3)
                local tx = imgbtnx + (ii/maxtilew)/3
                local tw = tx + imgbtnw
                local ty = imgbtny + (ji/maxtileh)/3
                local th = ty + imgbtnh

                if i > 0 and ii == 0 then
                    imgui.NewLine()
                end
                local color = {1, 1, 1, 1}

                if mask[mask_index] == 1 then
                    color[2] = 0
                    color[3] = 0
                end

                imgui.ImageButton(image, tilew/3 * scale, tileh/3 * scale, tx, ty, tw, th, 1, 0.46*color[1], 0.23*color[2], 0.54*color[3], 1, color[1], color[2], color[3], color[4])

                if imgui.IsMouseDown(0) then
                    if (imgui.IsItemHovered("ImGuiHoveredFlags_AllowWhenBlockedByActiveItem")  ) then
                        mask[mask_index] = 1
                    end
                elseif imgui.IsMouseDown(1) then
                    if (imgui.IsItemHovered("ImGuiHoveredFlags_AllowWhenBlockedByActiveItem")  ) then
                        mask[mask_index] = 0
                    end
                end
                
                imgui.SameLine()
            end
            imgui.PopStyleVar()
            imgui.EndGroup()
            
            imgui.SameLine()
            tileset.tiles[imgi] = self:calcValueFromMask(mask)
        end
        imgui.EndChild()
    end
end

--- Open the current animation viewer
function Animation:currentAnimationViewer()
	local animation = self.currentAnimation
	local image = self.animationSetViewerProps.image
	local w,h = image:getDimensions()
	local quads = self.animationSetViewerProps.quads
	local ww = imgui.GetColumnWidth()
	if animation.playing then
		animation.cspeed = animation.cspeed - (animation.speed * 0.05)

		if animation.cspeed <= 0 then

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

function TilesetEditor:draw()
	if imgui.Begin("Tileset Editor") then
		

		self:createNewSet()

		imgui.Columns(3)
		if self.firstOpen then
			local w = imgui.GetWindowSize()
			imgui.SetColumnWidth(0, w/6)
			imgui.SetColumnWidth(1, w/4)
			self.firstOpen = false
		end

	    self:listTilesets()

		imgui.NextColumn()

		if self.currentTileset then
			imgui.BeginChild("Tileset Editor##tile_editor")
			self:currentTilesetViewer()

			imgui.EndChild()

            imgui.NextColumn()
            
            if self.editAutotile.edit then
                self:autoTileEditor()
            end
		end

		imgui.End()
	end
end

function TilesetEditor:save()
	for k,tileset in pairs(self.tilesets) do
		tileset.name = k
		Resources:saveTileset(k, tileset)
	end
	Resources:loadTilesets()
end

return TilesetEditor