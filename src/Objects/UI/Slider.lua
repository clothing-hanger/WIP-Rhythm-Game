---@class Slider
local Slider = Class:extend()

---@param x number The x position
---@param y number The y position
---@param width number The width
---@param min number The minimum value
---@param max number The maximum value
---@param value number The starting value 
---@param name string The name of the slider
---@param description string The description of the slider
function Slider:new(x, y, width, min, max, value, name, description)
    self.description = description or "NO DESCRIPTION SET YOU IDIOT"
    self.x = x
    self.y = y
    self.width = width
    self.height = 20
    self.min = min
    self.max = max
    self.value = value or min
    self.knobRadius = 15
    self.dragging = false
    self.knobX = self:calculateKnobPosition()
    self.name = name
end

function Slider:calculateKnobPosition()
    local ratio = (self.value - self.min) / (self.max - self.min)
    return self.x + ratio * self.width
end

---@param mouseX number
function Slider:updateValueFromMouse(mouseX)
    local ratio = (mouseX - self.x) / self.width
    self.value = math.max(self.min, math.min(self.max, self.min + ratio * (self.max - self.min)))
    self.knobX = self:calculateKnobPosition()
end

function Slider:update(dt)

    if Input:down("menuClickLeft") then
        if self.dragging then
            self:updateValueFromMouse(cursorX)
        else
            if cursorX >= self.knobX - self.knobRadius and cursorX <= self.knobX + self.knobRadius and cursorY >= self.y - self.knobRadius and cursorY <= self.y + self.knobRadius then
                self.dragging = true
                self:updateValueFromMouse(cursorX)
            end
        end
    else
        self.dragging = false
    end
    
    self.hovered = cursorX > self.x and cursorX < self.x + self.width and cursorY > self.y and cursorY < self.y + self.height

    if self.hovered then 
        cursorText = self.description
    end

end

function Slider:giveValue()
    return self.value
end

function Slider:draw()
    -- slider rectangle thingy
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.line(self.x, self.y + self.height / 2, self.x + self.width, self.y + self.height / 2)
    -- slider circle thingy
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.circle("fill", self.knobX, self.y + self.height / 2, self.knobRadius)
    -- print the value
    love.graphics.setColor(1,1,1)
    love.graphics.print(string.format("%.2f", self.value), self.knobX + 15, self.y - 5)
end


return Slider
