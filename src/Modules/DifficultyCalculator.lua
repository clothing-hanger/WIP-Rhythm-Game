 
local chunkLength = 5               -- seconds per chunk
local npsWindows = 6             --now many different windows there are (i would stop around where the highest window is from lke 35- whatever)
local npsWindowWidth = 5             -- how many notes per second per window to increase difficulty score (im ass at explaining things)
local npsChunkScoreBase = 10          --how much difficulty score to add per nps window before calculating the difficulty score for that window
local npsChunkScoreIncrease = 0.5    -- how much difficculty score is multipled by per window
local overallMultiplier = 75    -- overall difficulty mulitplier
local jackDifficultyIncrease = 0.01 -- how much a second note in a row adds to that chunks difficulty score


local calcMetaData
local makeChunks
local calculateNps


function calculateDifficulty(lanes, songDuration, metaData)
    calcMetaData = metaData
    if not calcMetaData.name and not calcMetaData.difficulty then
        notification("Difficulty Calculation Failed!\nMetaData Not Found!", "error")
        State.switch(States.Menu.SongSelect)
        return
    end

    if calcMetaData.inputMode == "7" or calcMetaData.inputMode == 7 then -- lmao i dont know if its a number or string and its my own code 
        notification("7K Difficulty is currently not calculated", "warning")
    end
    

    local leftSide = {lanes[1], lanes[2]}
    local rightSide = {lanes[3], lanes[4]}

    local secondsPerBeat = 60/calcMetaData.bpm
    local leftChunks = makeChunks(leftSide)
    local rightChunks = makeChunks(rightSide)
    
    for i, Chunk in ipairs(leftChunks) do
        Chunk.nps = calculateNps(Chunk.notes)
        Chunk.difficulty = 0
        for i = 1, npsWindows do
            if Chunk.nps >= npsWindowWidth * npsWindows then
                Chunk.difficulty = (1 * (npsChunkScoreBase)) * (math.max(1 - (npsChunkScoreIncrease * i), 0))
            end
            for j, Note in ipairs(Chunk.notes) do
                if j > 1 then
                    local previousNote = Chunk.notes[j - 1]
                    if previousNote.Lane == Note.Lane then
                        Chunk.difficulty = Chunk.difficulty + jackDifficultyIncrease
                    end
                end
            end
        end
    end
    
    for i, Chunk in ipairs(rightChunks) do
        Chunk.nps = calculateNps(Chunk.notes)
        Chunk.difficulty = 0 
        for i = 1, npsWindows do
            if Chunk.nps >= npsWindowWidth * npsWindows then
                Chunk.difficulty = (1 * (npsChunkScoreBase)) * (math.max(1 - (npsChunkScoreIncrease * i), 0))
            end
            for j, Note in ipairs(Chunk.notes) do
                if j > 1 then
                    local previousNote = Chunk.notes[j - 1]
                    if previousNote.Lane == Note.Lane then
                        Chunk.difficulty = Chunk.difficulty + jackDifficultyIncrease
                    end
                end
            end
        end
    end
    

    leftChunks.nps = calculateAverageNPS(leftChunks)
    rightChunks.nps = calculateAverageNPS(rightChunks)

    leftChunks.difficulty = calculateAverageDifficulty(leftChunks)
    rightChunks.difficulty = calculateAverageDifficulty(rightChunks)

    local finalDifficulty = ((leftChunks.difficulty + rightChunks.difficulty) / 2)*overallMultiplier

    print("FINAL DIFFICULTY")
    print(finalDifficulty)
    return (finalDifficulty or 0)
end


function makeChunks(lanes)
    local notes = {}
    local chunks = {}
    local chunkLengthInSeconds = chunkLength
    local chunkLengthInMilliseconds = chunkLength*1000
    for i, Lane in ipairs(lanes) do
        for j, Note in ipairs(lanes[1]) do
            table.insert(notes, Note)
        end
    end

    local totalChunks = math.ceil(calcMetaData.songLengthToLastNote / chunkLength) -- we dont want anything after the last note to count because a song with a long (and empty) outro will throw off the accuracy of the calculation
 
    for i = 0,totalChunks do  -- 0 indexing 😭😭   i think itll make this easier tho so im using it
        table.insert(chunks, {startTime = chunkLengthInMilliseconds*i, notes = {}})
    end
    for i,Note in ipairs(notes) do
        for j,Chunk in ipairs(chunks) do
            if Note.StartTime >= Chunk.startTime then table.insert(Chunk.notes, Note) end
            break
        end
    end
    return chunks

    
end

function calculateNps(notes)
    local notesInChunk = #notes
    local notesPerSecond = notesInChunk/chunkLength
    return notesPerSecond
end

function calculateAverageNPS(chunks)
    local notesCount = 0
    for _, Chunk in ipairs(chunks) do
        notesCount = notesCount + #Chunk.notes
    end
    local nps = notesCount / calcMetaData.songLengthToLastNote
    return nps
end


function calculateAverageDifficulty(chunks)
    local totalDifficulty = 0
    local chunkCount = #chunks
    for _, Chunk in ipairs(chunks) do
        if Chunk.difficulty then
            totalDifficulty = totalDifficulty + Chunk.difficulty
        end
    end
    local averageDifficulty = totalDifficulty / chunkCount
    return averageDifficulty
end