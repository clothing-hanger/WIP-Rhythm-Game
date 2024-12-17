---@class SongButton
local SongButton = Class:extend()

---@param songName string The song name
---@param charterName string The name of the charter
---@param artistName string  The name of the song artist
---@param id number The id of the song
function SongButton:new(songName, charterName, artistName, banner, background, pathToSong, id, x, y, width, height)
    self.x, self.y = x, y
    self.width, self.height = width, height
    self.songName = songName or "Song Name not found!"
    self.path = pathToSong
    self.charterName = charterName or ""  -- no need for error text for these since they arent that important
    self.artistName = artistName or ""
    self.corrupt = false
    self.hovered = false
    self.id = id
    self.banner = banner
    self.background = background
    self.imageLoaded = false

end

function SongButton:update(dt)
    self.hovered =  ((cursorX > self.x and cursorX < self.x + self.width) and (cursorY > self.y and cursorY < self.y + self.height)) 

    if self.hovered and Input:pressed("menuClickLeft") then
        self:click()
    end
end

function SongButton:click()
    print(self.songName .. " Clicked")

    if self.id == PlayingSong then 
        States.Menu.SongSelect:SwitchMenuState("Difficulty")
    else
        SelectedSong = self.id
        PlayingSong = self.id
    end
end

function SongButton:loadImage()
    --[[
    if love.filesystem.getInfo(self.path .. self.banner, "file") then
        self.banner = love.graphics.newImage(self.path .. self.banner)
    elseif love.filesystem.getInfo(self.path .. self.background, "file") then
        self.banner = love.graphics.newImage(self.path .. self.background)
    else
        notification("Failed to find valid image for button", "error")
    end
    self.imageLoaded = true
    --]]
end

function SongButton:draw()
    --if self.id == SelectedSong then love.graphics.setColor(0,1,1) end
    --if self.corrupt then love.graphics.setColor(1,0,0) end

    if SelectedSong == self.id and self.imageLoaded then love.graphics.draw(self.banner, self.x, self.y, nil, 0.1, 0.1) end
    love.graphics.setColor(Skin.Colors["Song Button Fill"])
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  
    love.graphics.setColor(Skin.Colors["Song Button Line"])
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    --beveledRectangle(self.width, self.height, self.x, self.y, 20, 20, 1, {0,1,1}, {0,1,1}, {0,0,0}, {0,0,0}, false, false, true, nil, 8)
    love.graphics.setColor(Skin.Colors["Song Button Text"])
    love.graphics.print(self.songName, self.x, self.y)
    love.graphics.setColor(1,1,1)

end

function SongButton:release()

end

return SongButton