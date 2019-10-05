local Editor = require("pixcof.editors.editor")
local Resources = require("pixcof.resources")
local lume = require("pixcof.libs.lume")
local TilesetEditor = Editor:extend("TilesetEditor")
local Animation = {}

local autotileref = {
    1, 2, 4, 8, 0, 16, 32, 64, 128
}

function TilesetEditor:constructor(debug, name, tileset)
    Editor.constructor(self, debug)
    self.open = true

    self.asset = {
    	name = name,
    	tileset = tileset
    }

    --self.tilesets = Resources.tilesets
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

--- Open the animation set viewer
function TilesetEditor:currentTilesetViewer()
	if imgui.SmallButton("save tileset") then
		self:saveTileset()
	end
	local tileset = self.asset.tileset
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
    local tileset = self.asset.tileset
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
    --if imgui.BeginChild("autoTileEditor", 0, 0, false, {"ImGuiWindowFlags_HorizontalScrollbar", "ImGuiWindowFlags_NoMove"}) then
    if imgui.BeginTabBar("AutoTileEditor") then
        if imgui.BeginTabItem("BitMask") then
            local tileset = self.editAutotile
            local image = self.tilesetViewerProps.image
            local imgw, imgh = self.tilesetViewerProps.image_width, self.tilesetViewerProps.image_height
            local tilew, tileh = self.asset.tileset.tilew, self.asset.tileset.tileh
            local maxtilew, maxtileh = imgw/tilew, imgh/tileh
            local ww = imgui.GetWindowWidth()
            local mouse_x, mouse_y = imgui.GetMousePos()
            local contw, conth = imgui.GetContentRegionAvail()

            local window_x, window_y = imgui.GetCursorScreenPos()
            local scale = 2

            mouse_x, mouse_y = (mouse_x - window_x - imgui.GetScrollX())/scale, (mouse_y - window_y + imgui.GetScrollY())/scale

            --[[imgui.Text("mouse: " .. mouse_x .. "x" .. mouse_y)
            local local_x, local_y = mouse_x-window_x, mouse_y-window_y
            imgui.SameLine()
            local pos = math.floor(local_x/(tilew*scale)) + (maxtilew*math.floor(local_y/(tileh*scale)))
    		imgui.Text("pos: " .. math.max(pos, 0))
            imgui.SameLine()
            imgui.PushItemWidth(96)
            imgui.DragInt("scale", 2)
            imgui.PopItemWidth()
            ]]
            local canvas = lg.newCanvas(image:getDimensions())
            canvas:setFilter("nearest", "nearest")

            for imgi, quad in ipairs(self.tilesetViewerProps.quads) do
                local xxx = math.fmod(imgi-1, maxtilew)
                local yyy = math.floor((imgi-1)/maxtilew)
                local imgbtnx = xxx/maxtilew


                local imgbtny = 1/maxtilew*yyy
                local imgbtnw = (1/maxtilew)/3
                local imgbtnh = (1/maxtileh)/3


                if imgi-1 > 0 and xxx == 0 then
                    --imgui.NewLine()
                    --imgui.Separator()
                end

                --imgui.BeginGroup()
                --imgui.PushStyleVar("ImGuiStyleVar_ItemSpacing", 1, 2)
                
                local mask = self:calcMask(tileset.tiles[imgi])
    		    lg.setCanvas(canvas)
    		    local view = {quad:getViewport()}
                lg.draw(image, quad, view[1], view[2])
                love.graphics.setBlendMode('alpha', 'alphamultiply') 
                for i=0,8 do
                	local mask_index = i + 1

                	local tx = math.fmod(i, 3)*(tilew/3)
                	local ty = math.floor(i/3)*(tileh/3)
                	local tw = tilew/3
                	local th = tileh/3

                    --[[local ii = math.fmod(i, 3)
                    local ji = math.floor(i/3)
                    local tx = imgbtnx + (ii/maxtilew)/3
                    local tw = tx + imgbtnw
                    local ty = imgbtny + (ji/maxtileh)/3
                    local th = ty + imgbtnh]]

                    --[[if i > 0 and ii == 0 then
                        imgui.NewLine()
                    end]]

                    if imgui.IsMouseDown(0) then
                    	--print(mouse_x, mouse_y, view[1] + tx, view[2] + ty, view[1] + (tx + tw), view[2] + ty + th)
                    	if mouse_x >= view[1] + tx and mouse_x < view[1] + tx + tw and mouse_y >= view[2] + ty and mouse_y < view[2] + ty + th then 
                    		print("teste", i)
                    		mask[mask_index] = 1
                    	end
                    elseif imgui.IsMouseDown(1) then
                    	--print(mouse_x, mouse_y, view[1] + tx, view[2] + ty, view[1] + (tx + tw), view[2] + ty + th)
                    	if mouse_x >= view[1] + tx and mouse_x < view[1] + tx + tw and mouse_y >= view[2] + ty and mouse_y < view[2] + ty + th then 
                    		--print("teste", i)
                    		mask[mask_index] = 0
                    	end
                    end

                    local color = {1, 0, 0, 0}

                    if mask[mask_index] == 1 then
                        color[4] = 0.5
                    end

                    lg.setColor(color)
                    lg.rectangle("fill", view[1] + tx, view[2] + ty, tilew/3, tileh/3)
                    lg.setColor(1, 1, 1, 1)


    		       	--imgui.Image(canvas, image:getDimensions())

                    --imgui.ImageButton(image, tilew/3 * scale, tileh/3 * scale, tx, ty, tw, th, 1, 0.46*color[1], 0.23*color[2], 0.54*color[3], 1, color[1], color[2], color[3], color[4])

                    --[[if imgui.IsMouseDown(0) then
                        if (imgui.IsItemHovered("ImGuiHoveredFlags_AllowWhenBlockedByActiveItem")  ) then
                            mask[mask_index] = 1
                        end
                    elseif imgui.IsMouseDown(1) then
                        if (imgui.IsItemHovered("ImGuiHoveredFlags_AllowWhenBlockedByActiveItem")  ) then
                            mask[mask_index] = 0
                        end
                    end]]
                    
                    --imgui.SameLine()

                end
                
                lg.rectangle("line", view[1], view[2], tilew, tileh)
    	       	lg.setCanvas()
                --imgui.PopStyleVar()
                --imgui.EndGroup()
                
                --imgui.SameLine()
                tileset.tiles[imgi] = self:calcValueFromMask(mask)
            end
            local imgw, imgh = image:getDimensions()
            --print(window_x, window_y)
            local w = math.min(contw, conth)
            if imgui.BeginChildFrame(123321, contw, conth) then
                imgui.Image(canvas, imgw*scale, imgh*scale)
                imgui.EndChildFrame()
            end
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem("Priority") then
            imgui.EndTabItem()
        end
        --imgui.EndChild()
    end
    imgui.EndTabBar()
end

function TilesetEditor:draw()
	self.open = imgui.Begin(self.asset.name, true)
	if self.open then
		

		--self:createNewSet()

		imgui.Columns(2)
		--[[if self.firstOpen then
			local w = imgui.GetWindowSize()
			imgui.SetColumnWidth(0, w/6)
			imgui.SetColumnWidth(1, w/4)
			self.firstOpen = false
		end

	    self:listTilesets()

		imgui.NextColumn()]]

		--if self.currentTileset then
		imgui.BeginChild("Tileset Editor##tile_editor")
			self:currentTilesetViewer()
		imgui.EndChild()

        imgui.NextColumn()
        
        if self.editAutotile.edit then
            self:autoTileEditor()
        end
		--end

	end
	imgui.End()
end

function TilesetEditor:saveTileset()
	--[[for k,tileset in pairs(self.tilesets) do
		tileset.name = k
		Resources:saveTileset(k, tileset)
	end
	Resources:loadTilesets()]]
	if self.asset.name ~= self.asset.tileset.name then
		Resources:removeTileset(self.asset.name)
	end
	Resources:saveTileset(self.asset.tileset.name, self.asset.tileset)
end

return TilesetEditor