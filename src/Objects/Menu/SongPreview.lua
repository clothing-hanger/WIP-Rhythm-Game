local SongPreview = Class:extend()

function SongPreview:new(x, y, width, height, chart)
    previewingSong = true
    updatemusicTime = true
    musicTime = 0
    self.x = (x or 100)
    self.y = (x or 100)
    self.width = (width or 300)
    self.height = (height or 300)

    self.ScrollVelocityMarks = {}
    self.SvIndex = 1
    self.CurrentTime = 0
    self.startedmusicTime = false
    self.strumYPosition = Settings.scrollDirection == "Down" and Inits.GameHeight or 0
    self.inputMode = self.inputMode or "4K"

    self:initSVMarks()
    self:initNotePositions()

    quaverParse(chart)
end

function SongPreview:update(dt)
    updatemusicTimeFunction()
    self:updateTime()

    updateBPM()
    
    if Song and (musicTime >= 0 and not Song:isPlaying()) then -- to make sure it doesnt restart
        Song:setPitch(Mods.songRate)

        Song:play()
    end

    for _, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            if Note.StartTime - musicTime > 15000 then 
                break
            end
            Note:update(dt)
        end
    end

end

---Initializes the sv markers
function SongPreview:initSVMarks()
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
function SongPreview:initNotePositions()
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
function SongPreview:getPositionFromTime(time, index)
    if #self.ScrollVelocityMarks == 0 then
        return time
    end
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

function SongPreview:updateTime()
    while (self.SvIndex <= #scrollVelocities and scrollVelocities[self.SvIndex].StartTime <= (musicTime)) do
        self.SvIndex = plusEq(self.SvIndex)
    end

    self.CurrentTime = self:getPositionFromTime(musicTime, self.SvIndex)
end

function SongPreview:checkBotInput()
    for i, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            local NoteTime = (musicTime - Note.StartTime)
            local ConvertedNoteTime = math.abs(NoteTime)
            if Note.Lane == i and NoteTime > 1 and not Note.wasHit then
                SongPreview:judge(ConvertedNoteTime)
                Note:hit(ConvertedNoteTime, NoteTime)
                Objects.Game.HitErrorMeter:addHit(NoteTime)           
                table.insert(NPSData.NPS, 1000)
                break
            end

            if NoteTime > Judgements["Miss"].Timing and not Note.wasHit then
                SongPreview:judge(ConvertedNoteTime)
                Note:hit(ConvertedNoteTime, NoteTime, true)
                Objects.Game.Combo:incrementCombo(true)
                Objects.Game.HitErrorMeter:addHit(NoteTime)
                break
            end
        end
    end
end


function SongPreview:draw()
    for _, Lane in ipairs(lanes) do
        for _, Note in ipairs(Lane) do
            Note:draw()
        end
    end
end

return SongPreview

