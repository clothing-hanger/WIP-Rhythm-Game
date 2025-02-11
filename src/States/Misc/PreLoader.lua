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
    Objects.Menu.ModifiersMenu:new()
    Objects.Menu.ModifiersMenu:configureMods()

    SongList = love.filesystem.getDirectoryItems("Music")
    SongListTotalLength = #SongList
    frame = 0

    bottomLineTexts = {
        "I may look frozen, but I promise I'm not!",
        "please give me time im trying my best :(",
        "Don't close me! I'm doing important shit rn",
        "im going as fast as i can",
        "Have you tried getting a decent PC? Maybe the game would load faster",
        "dont close me if i look frozen im faking",
        "if your PC didn't SUCK SO MUCH i could load faster",
        "blame your computer",
        "not my fault your PC IS ASS",
        "just play quaver or something it wont take 9 years to load",
        "delete harmoni please",
        "osu is better in like every way why are you playing this shitass game",
        "my balls itch",
        "PLEASE get a better pc :sob:",
        "your pc is slow, not harmoni (this is a joke its harmoni's fault)",
        "if youre bored try throwing your nintendo switch down the stairs its kinda fun",
        "if the game looks like its frozen its because it is frozen lmao harmoni sucks",
    }
    bottomLineText = love.math.random(1,#bottomLineTexts)

    preloaderFont = love.graphics.newFont("Fonts/SourceCodePro-Medium.ttf", 30)
    logo = love.graphics.newImage("Images/Intro/logo.png")

    loadingArrows = {}
    for i = 1,4 do
        local girth = 60  -- i need to stop coding like this..
        local cock = (Inits.GameWidth - 265) + ((i-1)*girth)
        local dick = Inits.GameHeight - 180
        local penis = love.graphics.newImage("Images/Intro/" .. i .. ".png")
        table.insert(loadingArrows, {image = penis, x = cock, y = dick, sizeX = 0.2, sizeY = 0.2, alpha = 0})
    end
    self:updateLoadingArrows()

end

function PreLoader:update(dt)
    
    foundMeta = false
    metaString = ""
    frame = plusEq(frame)
    SelectedSong = frame
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
            SelectedDifficulty = i
            chart = quaverParse("Music/" .. SongList[frame] .. "/" .. DifficultyList[i])
            local noChartError = "idfk chart didnt process right idk"

            -- Escape quotes and backslashes in the strings
            safeTitle = (chart and tostring(chart.name):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError) -- tostring them because somehow I had one be a number????
            safeDiffName = (chart and tostring(chart.diffName):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeArtist = (chart and tostring(chart.artist):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeCharter = (chart and tostring(chart.creator):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeBackground = (chart and tostring(chart.background):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeBanner = (chart and tostring(chart.banner):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeAudio = (chart and tostring(chart.song):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError)
            safeDifficulty = (chart and tostring(chart.difficulty):gsub("\\", "\\\\"):gsub("\"", "\\\"") or noChartError) -- Added this line

            if i == 1 then
                metaString = string.format(
                    "return {\nsongName = \"%s\",\nversion = %d,\ndifficulties = {\n", 
                    safeTitle, curMetaVersion
                )
            end

            metaString = metaString .. string.format(
                "{fileName = \"%s\", diffName = \"%s\", artistName = \"%s\", charterName = \"%s\", background = \"%s\", banner = \"%s\", audio = \"%s\", difficulty = \"%s\", format = \"%s\"},\n", 
                DifficultyList[i],
                safeDiffName,
                safeArtist,
                safeCharter,
                safeBackground,
                safeBanner,
                safeAudio,
                safeDifficulty, -- Added here  (what the fuck does this comment mean)
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
        meta = require("Music/" .. SongList[frame] .. "/meta")
        safeTitle = meta.songName
    end
    
    if frame == #SongList and deleteMetaFiles then 
        love.event.quit()  -- Close the game once all meta files have been deleted
    elseif frame == #SongList then
        State.switch(States.Menu.Intro) 
        preloaderFont = nil
    end

    
end

function PreLoader:updateLoadingArrows()
    local currentBottomLineText = bottomLineText
    while currentBottomLineText == bottomLineText do
        bottomLineText = love.math.random(1, #bottomLineTexts)
    end
    local newAlpha = (loadingArrows[1].alpha == 1 and 0) or 1
    for i = 1,#loadingArrows do
        Timer.after((1*i)-1, function()
            Timer.tween(0.5, loadingArrows[i], {alpha = newAlpha}, "linear", function()
                if i == #loadingArrows then PreLoader:updateLoadingArrows() end
            end)
        end)
    end
end

function PreLoader:draw()
    love.graphics.setColor((foundMeta and {1,1,1}) or {0,1,1})
    love.graphics.rectangle("fill", 0, Inits.GameHeight-100,Inits.GameWidth*(frame/#SongList), 20)
    love.graphics.setFont((preloaderFont and preloaderFont) or defaultFont)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(logo, Inits.GameWidth/2, Inits.GameHeight/2-130, nil, 1.15, 1.15, logo:getWidth()/2, logo:getHeight()/2)
    love.graphics.printf("Hang tight! Harmoni is processing your songs!\nThis might take some time if the song has not been processed before.\nPlease don't close the game!! (unless you really wanna.. i dont care lmfao)\n\n"..(bottomLineTexts[bottomLineText] or ""), 0, Inits.GameHeight/2, Inits.GameWidth, "center")
    love.graphics.printf(frame .. "/" .. #SongList .. "  (" .. string.format("%.2f",math.min((frame/#SongList)*100,100)).."%)", 100, Inits.GameHeight-180, 10000, "left")
    love.graphics.printf("Music/" .. SongList[frame], 100, Inits.GameHeight - 50, 1000, "left")
   love.graphics.printf(((foundMeta and "Reading ") or "Creating") .. " meta data for " .. (safeTitle or "???"), 100, Inits.GameHeight-150, 10000, "left")
    for i =1,#loadingArrows do
        love.graphics.setColor(1,1,1, loadingArrows[i].alpha)

        love.graphics.draw(loadingArrows[i].image, loadingArrows[i].x, loadingArrows[i].y, nil, loadingArrows[i].sizeX, loadingArrows[i].sizeY)
    end
end

return PreLoader