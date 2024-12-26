local PlayState = State()
Mods = {}

local Directions = {
    "Left",
    "Down",
    "Up",
    "Right",
}

local Receptors = {}
local allHits

function PlayState:enter()
    musicTime = -99999999 -- just a super low number, musicTime will get actually initialized slightly later
    --Init self variables
    self.myBalls = math.huge
    self.ScrollVelocityMarks = {}
    self.SvIndex = 1
    self.CurrentTime = 0
    self.startedmusicTime = false
    self.strumYPosition = Settings.scrollDirection == "Down" and Inits.GameHeight or 0
    self.inputMode = self.inputMode or "4K"

    --Init global variables
    score = 0
    combo = 0
    accuracy = 0
    gameOver = false
    grade = "-"
    noteHits = {}
    performance = metaData.difficulty*(accuracy/100)
    NPSData = {NPS = {}, HPS = {}}
    health = 1
    allHits = 0

    -- Modifier stuff
    waveTime = 1
    rampTime = 0.8
    
    
    Receptors = {}
    Splashes = {}
    for i = 1, #lanes do
        table.insert(Receptors, Objects.Game.Receptor(i))
        table.insert(Splashes, Objects.Game.Splash(i))
    end
    PlayState:initObjects()

    PlayState:initSVMarks()
    PlayState:initNotePositions()

    if doScript then
        if initScript then
            initScript()
        end
    end

    Timer.after(0.1, function()
        if not self.startedmusicTime then -- is self.startedmusicTime needed anymore?
            self.startedmusicTime = true
            updatemusicTime = true
            musicTime = -3000
            doScreenWipe("rightOut")  -- so that it always does the transition no matter song loading time
        end
    end)
end

function PlayState:initModifiers()

end

function PlayState:initObjects()
    Objects.Game.Judgement:new()
    Objects.Game.HUD:new()
    Objects.Game.Background:new(background)
    Objects.Game.ComboAlert:new()
    Objects.Game.ComboAlertParticle:new(Inits.GameWidth+15, Inits.GameHeight/2+50)
    Objects.Game.Combo:new()
    Objects.Game.HitErrorMeter:new()
    Objects.Game.HealthBar:new()
    Objects.Game.HealthParticle:new(Skin.Params["Health Bar X"]+Inits.GameWidth/2, Skin.Params["Health Bar Y"]-Skin.Params["Health Bar Height"]+90+Inits.GameHeight/2)  -- translate by half the screen because the health bar is translated by half the screen
    Objects.Game.NoteUnderlay:new(#lanes)
    Objects.Game.JudgementCounter:new()
    Timer.after(0.4, function()
        Objects.Game.Background:setDimness(Settings.backgroundDim/100, true)

        for i, Receptor in ipairs(Receptors) do
            Timer.after(0.075*Receptor.lane, function() Receptor:appear() end)
        end
    end)

end

function PlayState:update(dt)
    if Mods.botPlay then PlayState:checkBotInput() else PlayState:checkInput() end

    PlayState:updateObjects(dt)
    
    ---@diagnostic disable-next-line: deprecated
    performance = metaData.difficulty * math.pow(accuracy/198, 6)

    performance = metaData.difficulty * accuracy  -- will this be better????      it wasnt better lmao

    updatemusicTimeFunction()
    self:updateTime()

    updateBPM()
    
    if Song and (musicTime >= 0 and not Song:isPlaying()) then -- to make sure it doesnt restart
        PlayState:startSong()
    end
    for _, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            if Note.StartTime - musicTime > 15000 then 
                break
            end
            Note:update(dt)
        end
    end

    if Mods.suddenDeath and Judgements["Miss"].Count > 0 then
        PlayState:gameOver()
    end

    if musicTime > metaData.lastNoteTime then
        State.switch(States.Game.Results)
    end

    if Mods.waves then
        waveTime = math.sin(love.timer.getTime()) * 0.3
        
        if Song then Song:setPitch(1 + waveTime) end 
    end

    if Mods.rampUp then
        if Mods.rampUp  then
        end
    end

    if doScript then
        if updateScript then
            updateScript(dt)
        end
    end
end

function PlayState:startSong()
    Song:setPitch(Mods.songRate)
    Song:play()
end

---Initializes the sv markers
function PlayState:initSVMarks()
    if #scrollVelocities < 1 then
        return
    end

    local first = scrollVelocities[1]

    local time = first.StartTime
    table.insert(self.ScrollVelocityMarks, time)

    for i = 2, #scrollVelocities do
        local prev = scrollVelocities[i-1]
        local current = scrollVelocities[i]

        time = time + (current.StartTime - prev.StartTime) * prev.Multiplier
        table.insert(self.ScrollVelocityMarks, time)
    end
end

---Initializes the noes sv positions
function PlayState:initNotePositions()
    for _, lane in ipairs(lanes) do
        for _, note in ipairs(lane) do
            note.InitialStartTime = self:getPositionFromTime(note.StartTime)
            note.InitialEndTime = self:getPositionFromTime(note.EndTime)
        end
    end
end

---Gets a y position based off the sv position of the note
---@param time number
---@param index? number
---@return number pos y position
function PlayState:getPositionFromTime(time, index)
    local index = index or -1

    if index == -1 then
        for i = 1, #scrollVelocities do
            if time < scrollVelocities[i].StartTime then
                index = i
                break
            else
                index = 1
            end
        end
    end

    local previous = scrollVelocities[index-1] or Objects.Game.ScrollVelocity(0, 1)

    local pos = self.ScrollVelocityMarks[index-1] or 0
    pos = pos + (time - previous.StartTime) * previous.Multiplier

    return pos
end

function PlayState:updateTime()
    while (self.SvIndex <= #scrollVelocities and scrollVelocities[self.SvIndex].StartTime <= (musicTime)) do
        self.SvIndex = plusEq(self.SvIndex)
    end

    self.CurrentTime = self:getPositionFromTime(musicTime, self.SvIndex)
end

function PlayState:updateObjects(dt)
    Objects.Game.HUD:update(dt)
    Objects.Game.HitErrorMeter:update(dt)
    Objects.Game.HealthBar:update(dt)
    Objects.Game.HealthParticle:update(dt)
    Objects.Game.ComboAlertParticle:update(dt)

    for _, Receptor in ipairs(Receptors) do
        Receptor:update(dt)
    end
    for _, Splash in ipairs(Splashes) do
        Splash:update(dt)
    end
end

function PlayState:gameOver()
    if gameOver then return end
    if Mods.noFail then return end
    print("fucking loser")
    gameOver = true

    doScreenWipe("rightIn", function() 
        if Song then Song:stop() end
        --Song:release() 
        Song = nil
        State.switch(States.Game.Results) 
    end)
end

---@param noteTime number
---Gives a judgement based off the hit notetime
function PlayState:judge(noteTime)
    local ConvertedNoteTime = math.abs(noteTime)
    for Judgement = 1, #JudgementNames do
        local judgement = Judgements[JudgementNames[Judgement]]
        if ConvertedNoteTime <= judgement.Timing then
            judgement.Count = judgement.Count + 1
            Objects.Game.Judgement:judge(judgement.Judgement)
            score = score + (BestScorePerNote*judgement.Score)
            health = health + judgement.Health
            PlayState:calculateAccuracy()
            print(judgement.Judgement)
            Objects.Game.JudgementCounter:bumpJudgement(judgement.Judgement)
            return
        end
    end
    -- must be a miss then lmfao LOSER you SUCK 
    Judgements["Miss"].Count = Judgements["Miss"].Count + 1
    Objects.Game.Judgement:judge("Miss")
    Objects.Game.JudgementCounter:bumpJudgement("Miss")
    health = health + Judgements["Miss"].Health
    PlayState:calculateAccuracy()
    return
end

---Calculates the accuracy 0%-100%
function PlayState:calculateAccuracy()
    allHits = (allHits or 0)
    allHits = plusEq(allHits)
    local currentBestPossibleScore = BestScorePerNote*allHits
    accuracy = (score/currentBestPossibleScore)*100 
end

function PlayState:checkInput()
    for i, Lane in ipairs(lanes) do
        -- PRESSED INPUT
        if Input:pressed("lane" .. i .. self.inputMode) then
            table.insert(NPSData.HPS, 1000)
            for _, Note in ipairs(Lane) do
                local NoteTime = (musicTime - Note.StartTime)
                local ConvertedNoteTime = math.abs(NoteTime)
                if Note.Lane == i and ConvertedNoteTime < Judgements["Miss"].Timing and not Note.wasHit then
                    local judgement = PlayState:judge(ConvertedNoteTime)
                    Note:hit(ConvertedNoteTime, NoteTime, judgement)

                    if ConvertedNoteTime < Judgements["Okay"].Timing then  -- to figure out whether or not to reset the combo
                        Objects.Game.Combo:incrementCombo(false)  -- false means we dont reset it
                    else
                        Objects.Game.Combo:incrementCombo(true)   -- true means we do reset it
                    end
                    table.insert(NPSData.NPS, 1000)
                    break
                end
            end
        end

        -- HELD INPUT
        if Input:down("lane" .. i .. self.inputMode) then
            Receptors[i].down = true
        end

        -- RELEASED INPUT
        if Input:released("lane" .. i .. self.inputMode) then
            Receptors[i].down = false
        end

        -- MISS CHECKER
        for _, Note in ipairs(Lane) do
            if Note.StartTime - musicTime > 15000 then 
                break
            end
            local NoteTime = (musicTime - Note.StartTime)
            local ConvertedNoteTime = math.abs(NoteTime)
            if NoteTime > Judgements["Miss"].Timing and not Note.wasHit then
                PlayState:judge(ConvertedNoteTime)
                Note:hit(ConvertedNoteTime, NoteTime, true)
                Objects.Game.Combo:incrementCombo(true)
                Objects.Game.HitErrorMeter:addHit(NoteTime)
                break
            end
        end
    end
end

function PlayState:checkBotInput()
    for i, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            local NoteTime = (musicTime - Note.StartTime)
            local ConvertedNoteTime = math.abs(NoteTime)
            if Note.Lane == i and NoteTime > 1 and not Note.wasHit then
                PlayState:judge(ConvertedNoteTime)
                Note:hit(ConvertedNoteTime, NoteTime)
                Objects.Game.HitErrorMeter:addHit(NoteTime)           
                table.insert(NPSData.NPS, 1000)
                break
            end

            if NoteTime > Judgements["Miss"].Timing and not Note.wasHit then
                PlayState:judge(ConvertedNoteTime)
                Note:hit(ConvertedNoteTime, NoteTime, true)
                Objects.Game.Combo:incrementCombo(true)
                Objects.Game.HitErrorMeter:addHit(NoteTime)
                break
            end
        end
    end
end

function PlayState:draw()
    Objects.Game.Background:draw() 
    if doScript then
        if drawScriptLayer1 then
            drawScriptLayer1()
        end
    end
    Objects.Game.NoteUnderlay:draw()
    love.graphics.push()
    love.graphics.translate(0, (Settings.scrollDirection == "Down" and -Settings.laneHeight) or Settings.laneHeight)
    for _, Splash in ipairs(Splashes) do
        Splash:draw()
    end
    for _, Receptor in ipairs(Receptors) do
        Receptor:draw()
    end

    for _, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            Note:draw()
        end
    end
    
    love.graphics.pop()
    if doScript then
        if drawScriptLayer2 then
            drawScriptLayer2()
        end
    end
    Objects.Game.Judgement:draw()
    Objects.Game.HUD:draw()
    Objects.Game.ComboAlertParticle:draw()
    Objects.Game.ComboAlert:draw()
    Objects.Game.Combo:draw()
    Objects.Game.HitErrorMeter:draw()
    Objects.Game.HealthBar:draw()
    Objects.Game.JudgementCounter:draw()
    Objects.Game.HealthParticle:draw()

    if doScript then
        if drawScriptLayer3 then
            drawScriptLayer3()
        end
    end
end

return PlayState
