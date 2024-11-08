local PreLoader = State()
local SongContents
local DifficultyList = {}
local foundMeta
local chart
local fileName
local songName
local diffName
local frame
local metaString

local curMetaVersion = 3       -- doesnt work correctly yet
local deleteMetaFiles = false  -- Set this to true to delete meta files instead of creating them (the game will close when it finishes)

function PreLoader:enter()
    SongList = love.filesystem.getDirectoryItems("Music")
    frame = 0
end

function PreLoader:update(dt)
    foundMeta = false
    metaString = ""
    frame = plusEq(frame)
    SongContents = love.filesystem.getDirectoryItems("Music/" .. SongList[frame] .. "/")
    DifficultyList = {}

    for i = 1, #SongContents do
        if deleteMetaFiles and SongContents[i] == "meta.lua" then
            love.filesystem.remove("Music/" .. SongList[frame] .. "/meta.lua")
            foundMeta = true  -- Mark as found so that it's not regenerated
        elseif getFileExtension(SongContents[i]) == ".qua" then
            table.insert(DifficultyList, SongContents[i])
        elseif SongContents[i] == "meta.lua" then
            local meta = love.filesystem.load("Music/" .. SongList[frame] .. "/" .. "meta.lua")()
            if meta.version and (tonumber(meta.version) or 0) == curMetaVersion then
                foundMeta = true
            else
                foundMeta = false
            end
        end
    end
    
    if not foundMeta and not deleteMetaFiles then
        for i = 1, #DifficultyList do
            chart = Tinyyaml.parse(love.filesystem.read("Music/" .. SongList[frame] .. "/" .. DifficultyList[i]))

            -- Escape quotes and backslashes in the strings
            local safeTitle = tostring(chart.Title):gsub("\\", "\\\\"):gsub("\"", "\\\"")     -- tostring them because somehow I had one be a number????
            local safeDiffName = tostring(chart.DifficultyName):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            local safeArtist = tostring(chart.Artist):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            local safeCharter = tostring(chart.Creator):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            local safeBackground = tostring(chart.BackgroundFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            local safeBanner = tostring(chart.BannerFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            local safeAudio = tostring(chart.AudioFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")

            if i == 1 then
                metaString = string.format(
                    "return {\nsongName = \"%s\",\nversion = %d,\ndifficulties = {\n", 
                    safeTitle, curMetaVersion
                )
            end
            
            metaString = metaString .. string.format(
                "{fileName = \"%s\", diffName = \"%s\", artistName = \"%s\", charterName = \"%s\", background = \"%s\", banner = \"%s\", audio = \"%s\", format = \"%s\"},\n", 
                DifficultyList[i],
                safeDiffName,
                safeArtist,
                safeCharter,
                safeBackground,
                safeBanner,
                safeAudio,
                "Quaver"
            )
            if i == #DifficultyList then 
                metaString = metaString .. "}}"
            end

        end
        
        love.filesystem.write("Music/" .. SongList[frame] .. "/meta.lua", metaString)
    elseif deleteMetaFiles then
        print("Meta file deleted for:", SongList[frame])
    else
        print("Meta Found")
    end
    
    if frame == #SongList and deleteMetaFiles then 
        love.event.quit()  -- Close the game once all meta files have been deleted
    elseif frame == #SongList then
        State.switch(States.Menu.TitleScreen) 
    end
end

function PreLoader:draw()

    love.graphics.rectangle("fill", 0, Inits.GameHeight-100,Inits.GameWidth*(frame/#SongList), 20)
end

return PreLoader
