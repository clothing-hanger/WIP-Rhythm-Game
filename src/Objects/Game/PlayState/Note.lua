---@class Note
local Note = Class:extend()

Note.Directions = {
    "Left",
    "Down",
    "Up",
    "Right",
}

---@param lane integer Which lane the note is for
---@param StartTime number The start time of the note
---@param EndTime number The end time of the note
function Note:new(lane, StartTime, EndTime)
    self.image = Skin.Notes[States.Game.PlayState.inputMode][Constants.Directions[States.Game.PlayState.inputMode][lane]]
    self.Lane = lane
    self.X = LanesPositions[States.Game.PlayState.inputMode][lane]
    self.Y = Inits.GameHeight*2
    self.StartTime = StartTime
    self.EndTime = EndTime or 0 -- if 0, not a hold
    self.visible = true
    self.wasHit = false
    self.tooLate = false
    if Mods.fadeIn then
        self.alpha = 0
    end

    self.InitialStartTime = 0
    self.InitialEndtime = 0
    self.moveWithScroll = true
    self.isHeld = false
    self.holdWasFinished = true -- just because its easier ig

    if self.EndTime > self.StartTime then
        self.isHeld = true
        self.holdWasFinished = false

        self.children = {}
        self.children[1] = {
            image = Skin.HoldNotes[States.Game.PlayState.inputMode][Constants.Directions[States.Game.PlayState.inputMode][lane]],
            height = 175,
            y = 0,
        }
        self.children[2] = {
            image = Skin.HoldEndNotes[States.Game.PlayState.inputMode][Constants.Directions[States.Game.PlayState.inputMode][lane]],
            height = 175,
            y = 0,
        }
    end
end

---@param time number The time for the note
---@return number the position of the Note
---Returns the converted pixel position of the note
function Note:getNotePosition(time)
    local strumYPosition
    local currentTime
    if State.current() ~= States.Game.PlayState then -- must not be in playstate, so this needs to use the variables from the chart previewer
        strumYPosition = Objects.Menu.SongPreview.strumYPosition
        currentTime = Objects.Menu.SongPreview.CurrentTime
        time = Objects.Menu.SongPreview:getPositionFromTime(self.StartTime) -- Horrible fix but I dont care
    else
        strumYPosition = States.Game.PlayState.strumYPosition
        currentTime = States.Game.PlayState.CurrentTime
    end
    
    if not self.moveWithScroll then
        return strumYPosition
    end
    if Settings.scrollDirection == "Down" then
        return strumYPosition + (currentTime - time) * convertScrollSpeed(Settings.scrollSpeed)
    else
        return strumYPosition - (currentTime - time) * convertScrollSpeed(Settings.scrollSpeed)
    end
end

function Note:update(dt)
    if not self.visible then return end
    if Mods.wave then
        self.StartTime = self.StartTime - waveTime
    end

    if Mods.ramp then self.StartTime = self.StartTime + rampTime end

    self.Y = self:getNotePosition(self.InitialStartTime)

    if self.isHeld then
        local endY = self:getNotePosition(self.InitialEndtime)

        self.children[1].y = self.Y
        self.children[2].y = endY

        local pixelDiff = endY - self.Y

        self.children[1].height = pixelDiff - 200
        self.children[2].y = self.children[2].y - 200

        
        --[[ if (self.Y < Inits.GameHeight) or (self.Y < 0 - Skin.Params["Note Size"]) then
            print(pixelDiff)
        end ]]
    end

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
 
---@param noteTime number The time the note was hit
---@param wasMiss boolean If the note was a miss
function Note:hit(noteTime, unconvertedNoteTime, wasMiss)
    self.visible = wasMiss
    self.wasHit = true
    self.tooLate = wasMiss
    table.insert(noteHits, {noteTime = unconvertedNoteTime, musicTime = musicTime, wasMiss = wasMiss})  -- prob will edit this later, idk
    for _, Splash in ipairs(Splashes) do
        if Splash.lane == Note.Lane then
            Splash:emit(ConvertedNoteTime)
        end
    end
    Objects.Game.HitErrorMeter:addHit(unconvertedNoteTime)
    Objects.Game.JudgementCounter:bumpJudgement()
    if doScript then
        if wasMiss then
            if scriptOnNoteMiss then
                scriptOnNoteMiss()
            end
        else
            if scriptOnNoteHit then
                scriptOnNoteHit()
            end
        end
    end

end

function Note:draw()
    love.graphics.setColor(1,1,1,self.alpha)
    if self.tooLate then love.graphics.setColor(0.5,0.5,0.5,1) end
    --[[
    if self.isHeld and not self.holdWasFinished then
        if (self.Y <= Inits.GameHeight+Skin.Params["Note Size"]) or (self.Y <= 0 - Skin.Params["Note Size"]) then
            for i, child in ipairs(self.children) do
                love.graphics.draw(child.image, self.X, child.y, 0, Skin.Params["Hold" .. (i == 2 and "End" or "") .. " Size"]/child.image:getWidth(), (i == 2 and Skin.Params["Hold Size"] or child.height)/child.image:getHeight(), child.image:getWidth()/2)
            end
        end
    end
    --]]
    if not self.visible or not (self.Y <= Inits.GameHeight+Skin.Params["Note Size"]) or (self.Y <= 0 - Skin.Params["Note Size"]) then love.graphics.setColor(1,1,1); return end
    love.graphics.draw(self.image, self.X, self.Y, 0, Skin.Params["Note Size"]/self.image:getWidth(), Skin.Params["Note Size"]/(self.image:getHeight()), self.image:getWidth()/2, self.image:getHeight()/2)
    love.graphics.setColor(1,1,1)
end

function Note:release()

end

return Note