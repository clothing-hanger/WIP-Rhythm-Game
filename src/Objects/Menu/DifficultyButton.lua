---@class DifficultyButton
local DifficultyButton = Class:extend()

---@param diffName string The Song name
---@param charterName string The name of the charter
---@param difficulty string The difficulty nae
---@param id number the id of the song
function DifficultyButton:new(diffName, charterName, difficulty, id)
    self.x, self.y = 700, 250
    self.width, self.height = 400, 50
    self.diffName = diffName or "Song Name not found!"
    self.charterName = charterName or ""  -- no need for error text for these since they arent that important
    self.difficulty = difficulty or "Difficulty not found!"
    self.hovered = false
    self.id = id
    self.selected = false
end

function DifficultyButton:update(dt)
    self.hovered = ((cursorX > self.x and cursorX < self.x + self.width) and (cursorY > self.y and cursorY < self.y + self.height))

    if self.hovered and Input:pressed("menuClickLeft") then
        self:click()
    end
end

---If the button was clicked
function DifficultyButton:click()

    if self.id == SelectedDifficulty then
        States.Menu.SongSelect:switchToPlayState()
    else
        SelectedDifficulty = self.id
    end
end

function DifficultyButton:draw()
    if self.selected then love.graphics.setColor(0, 1, 1) end
    love.graphics.setColor(Skin.Colors["Song Button Fill"])
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  
    love.graphics.setColor(Skin.Colors["Song Button Line"])
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.print(self.diffName .. "  |  " .. self.difficulty, self.x, self.y)
    --print(self.diffName)
    love.graphics.setColor(1, 1, 1)
end

function DifficultyButton:release()

end

return DifficultyButton