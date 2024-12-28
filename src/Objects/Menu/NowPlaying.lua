local NowPlaying = Class:extend()

function NowPlaying:new(songName, artist, charter)
    self.topLine = (songName or "???")
    self.middleLine = (artist or "???")
    self.bottomLine = (charter or "???")
    self.x = -201
    self.y = 100
    self.width = 200
    self.height = 75
    if nowPlayingTimer then Timer.cancel(nowPlayingTimer) end
    
    nowPlayingTimer = Timer.tween(0.25, self, {x = 0}, "out-quad", function()
        Timer.after(7, function()
            Timer.tween(0.25, self, {x = -201}, "in-quad")
        end)
    end)
    
end

function NowPlaying:update(dt)
end

function NowPlaying:draw()
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    local text = self.topLine .. "\n" .. self.middleLine .. "\n" .. self.bottomLine
    love.graphics.printf(text, self.x + 10, self.y + 10, 200, "left")
end

return NowPlaying