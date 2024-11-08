
---@param file string
---@return boolean passed If whether or not, the parser failed whilst loading the chart
function quaverParse(file, argument)
    local noLane = false
    if argument == "no lanes" then
        noLane = true
    end
    doScript = false
    print("quaverParse(" .. file .. ")")
    songFolder = ""
    if not file then State.switch(States.SongSelectState) end
    --[[ if not love.filesystem.getInfo(file, "file") then
        State.switch(States.SongSelectState)
    end ]]

    metaData = {}
    metaData.songLength = 0
    metaData.songLengthToLastNote = 0
    BestScorePerNote = 0
    currentBpm = 0
    metaData.difficulty = 0

    local chart = Tinyyaml.parse(love.filesystem.read(file))
    lanes = {}
    timingPoints = {}
    scrollVelocities = {}

    metaData = {
        name = chart.Title,
        song = chart.AudioFile,
        artist = chart.Artist,
        source = chart.Source, -- not sure what this one even is really
        tags = chart.Tags, -- not gonna be used in this file but im putting it here for now so i dont forget it
        diffName = chart.DifficultyName,
        creator = chart.Creator,
        background = chart.BackgroundFile,
        banner = chart.BannerFile or nil,
        previewTime = (chart.SongPreviewTime or 0), --/ Modifiers[2], -- also wont be used here
        noteCount = 0,
        holdNoteCount = 0,
        length = 0,
        bpm = 0,
        inputMode = chart.Mode:gsub("Keys", ""),  -- will be used to make sure its 4 key
    }

    songFolder = "Music/" .. SongList[SelectedSong] -- make this used more here instead of repeating the path over and over  (this was added with scripts in mind)

    for i = 1, tonumber(metaData.inputMode) do
        table.insert(lanes, {})
    end
    States.Game.PlayState.inputMode = #lanes .. "K"

    if Song and Song:isPlaying() then
        Song:stop()
    end
    
    if love.filesystem.getInfo("Music/" .. SongList[SelectedSong] .. "/" .. metaData.song, "file") then        --look for song file and try to load it
        Song = love.audio.newSource("Music/" .. SongList[SelectedSong] .. "/" .. metaData.song, "static")
        SongData = love.sound.newSoundData("Music/" .. SongList[SelectedSong] .. "/" .. metaData.song)
    else
        print("Audio Failed to Load! Chart Loading Cancelled.", notifErrorIcon)
        print("Audio File Not Found For Song " .. SelectedSong)
        return false
    end

    if love.filesystem.getInfo("Music/" .. SongList[SelectedSong] .. "/" .. metaData.background, "file") then     --look for background file and try to load it
        background = love.graphics.newImage("Music/" .. SongList[SelectedSong] .. "/" .. metaData.background)
    else
        print("Background Failed to Load! Incorrect Background Will be Displayed.", notifErrorIcon)
        print("Background File Not Found For Song " .. SelectedSong)
    end 


    if love.filesystem.getInfo("Music/" .. SongList[SelectedSong] .. "/" .. "script.lua", "file") then      -- look for script file and try to load it
        doScript = true
        love.filesystem.load("Music/" .. SongList[SelectedSong] .. "/" .. "script.lua")()
    end


    if not noLane then
        for i = 1,#chart.TimingPoints do
            local timingPoint = chart.TimingPoints[i]
            local startTime = timingPoint.StartTime
            local bpm = (timingPoint.Bpm or 0)
            table.insert(timingPoints, {startTime, bpm})

            if i == 1 then
                metaData.bpm = bpm
            end
        end

        for i = 1,#chart.HitObjects do
            local hitObject = chart.HitObjects[i]
            local startTime = (hitObject.StartTime or 0) / Mods.songRate
            if not startTime then goto continue end
            local endTime = hitObject.EndTime or 0
            local lane = hitObject.Lane

            metaData.noteCount = metaData.noteCount + 1
            if endTime > 0 then
                metaData.holdNoteCount = metaData.holdNoteCount + 1
            end
            
            if Mods.mirror then
                local mirrorMap4 = {4,3,2,1}
                local mirrorMap7 = {7,6,5,4,3,2,1}
                
                if metaData.inputMode == "4" then
                    lane = mirrorMap4[lane]
                elseif metaData.inputMode == "7" then
                    lane = mirrorMap7[lane]
                end
            end

            local note = Objects.Game.Note(lane, startTime, endTime)
            table.insert(lanes[lane], note)
            
            if not metaData.firstNoteTime and startTime then
                metaData.firstNoteTime = math.floor(startTime/1000)
            end
            ::continue::
        end

        for i = 1, #chart.SliderVelocities do
            local velocity = chart.SliderVelocities[i]
            local startTime = (velocity.StartTime or 0)
            local velocityChange = velocity.Multiplier

            table.insert(scrollVelocities, Objects.Game.ScrollVelocity(startTime, velocityChange))
        end

        for i = 1, #lanes do
            table.sort(lanes[i], function(a, b) return a.StartTime < b.StartTime end)

            metaData.lastNoteTime = lanes[i][#lanes[i]].StartTime > (metaData.lastNoteTime or 0) and lanes[i][#lanes[i]].StartTime or (metaData.lastNoteTime or 0)
        end
        metaData.songLengthToLastNote = metaData.lastNoteTime/1000
        BestScorePerNote = 1000000/(#lanes[1]+#lanes[2]+#lanes[3]+#lanes[4])
        metaData.difficulty = calculateDifficulty(lanes, metaData.songLengthToLastNote)

    end
    metaData.songLength = Song:getDuration()

    InitializeJudgments()
    currentBPM = metaData.bpm
    calculateBeatLength(currentBPM)
    print(currentBPM)
    print(bpm)

    

    return true
end
