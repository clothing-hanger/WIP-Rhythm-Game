local Note = Class:extend()


Note.Directions = {
    "Left",
    "Down",
    "Up",
    "Right",
}

function Note:new(lane, StartTime)
    self.image = Skin.Notes[self.Directions[lane]]
    self.Lane = lane
    self.X = LanesPositions[lane]
    self.Y = Inits.GameHeight*2
    self.StartTime = StartTime
    self.visible = true
    self.wasHit = false
    self.tooLate = false
    if Mods.fadeIn then
        self.alpha = 0
    end
end

function Note:update(dt)

    if Mods.wave then
        self.StartTime = self.StartTime - waveTime
    end

    self.Y = -(MusicTime - self.StartTime)*Settings.scrollSpeed

    if Mods.fadeOut and Settings.scrollDirection == "Up" then
        if self.Y < Inits.GameHeight/2 then
            self.alpha = self.alpha-10*dt
        end
    end

    if Mods.fadeIn and Settings.scrollDirection == "Up" then
        if self.Y < Inits.GameHeight/2+200 then
            self.alpha = self.alpha+5*dt
        end
    end


    
end

function Note:hit(noteTime, wasMiss)
    self.visible = wasMiss
    self.wasHit = true
    self.tooLate = wasMiss 
end

function Note:draw()
    if not self.visible or not (self.Y < Inits.GameHeight) or (self.Y < 0 - Skin.Params["Note Size"]) then return end
    love.graphics.setColor(1,1,1,self.alpha)
    if self.tooLate then love.graphics.setColor(0.5,0.5,0.5,1) end
    love.graphics.draw(self.image, self.X, self.Y, 0, Skin.Params["Note Size"]/self.image:getWidth(), Skin.Params["Note Size"]/self.image:getHeight(), self.image:getWidth()/2, self.image:getHeight()/2)
    love.graphics.setColor(1,1,1)
end

function Note:release()

end

return Note