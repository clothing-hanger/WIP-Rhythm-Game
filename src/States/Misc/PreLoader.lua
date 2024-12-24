local PreLoader = State()
local SongContents
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
    PreLoader.stopArrows=false
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
    }
    bottomLineText = love.math.random(1,#bottomLineTexts)

    preloaderFont = love.graphics.newFont("Fonts/SourceCodePro-Medium.ttf", 30)
    logo = love.graphics.newImage("Images/Intro/logo.png")

    loadingArrows = {}
    local screenEnd = Inits.GameWidth - 265
    local screenTop = Inits.GameHeight - 180
    for i = 1,4 do
        local width = 60  -- yes you do
        local x = screenEnd + ((i-1)*width)
        local image = love.graphics.newImage("Images/Intro/" .. i .. ".png")
        table.insert(loadingArrows, {image = image, x = x, y = screenTop, sizeX = 0.2, sizeY = 0.2, alpha = 0})
    end
    self:updateLoadingArrows()

end

function PreLoader:update(dt)
    local i = 1
    while i < 10 do -- This should probably be a dynamic number so things can load faster
        i = i + 1
        foundMeta = false
        metaString = ""
        frame = plusEq(frame)
        local musicDirectory = "Music/" .. SongList[frame] .. "/"
        SongContents = love.filesystem.getDirectoryItems(musicDirectory)
        local DifficultyList = {}
        for i,file in ipairs(SongContents) do

            if file == "meta.lua" then
                if(deleteMetaFiles) then
                    love.filesystem.remove(musicDirectory .. "/meta.lua")
                    foundMeta = true  -- Mark as found so that it's not regenerated
                else
                    local meta = love.filesystem.load(musicDirectory .. "meta.lua")()
                    foundMeta = (meta.version and (tonumber(meta.version) or 0) == curMetaVersion)
                end
            elseif file:sub(-4) == ".qua" then
                table.insert(DifficultyList, SongContents[i])
            end
        end

        
        if not foundMeta and not deleteMetaFiles then
            local safeTitle
            local metas = {}
            for i = 1, #DifficultyList do
                chart = Tinyyaml.parse(love.filesystem.read(musicDirectory .. DifficultyList[i]))

            -- Escape quotes and backslashes in the strings
            safeTitle = tostring(chart.Title):gsub("\\", "\\\\"):gsub("\"", "\\\"")     -- tostring them because somehow I had one be a number????
            safeDiffName = tostring(chart.DifficultyName):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            safeArtist = tostring(chart.Artist):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            safeCharter = tostring(chart.Creator):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            safeBackground = tostring(chart.BackgroundFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            safeBanner = tostring(chart.BannerFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")
            safeAudio = tostring(chart.AudioFile):gsub("\\", "\\\\"):gsub("\"", "\\\"")

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
        State.switch(States.Menu.Intro) 
        preloaderFont = nil
    end
    
end
function PreLoader:exit()
    PreLoader.stopArrows=true
end
function PreLoader:updateLoadingArrows()
    print("what")
    local newAlpha = (loadingArrows[1].alpha == 1 and 0) or 1
    for i = 1,#loadingArrows do
        Timer.after((1*i)-1, function()
            Timer.tween(0.5, loadingArrows[i], {alpha = newAlpha}, "linear", function()
                if i == #loadingArrows then 
                    PreLoader:updateLoadingArrows()
                end
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
    love.graphics.printf(string.format("%.2f",math.min((frame/#SongList)*100,100)).."%", 100, Inits.GameHeight-180, 10000, "left")
    love.graphics.printf("Music/" .. SongList[frame], 100, Inits.GameHeight - 50, 1000, "left")
   love.graphics.printf(((foundMeta and "Reading ") or "Creating") .. " meta data for " .. (safeTitle or "???"), 100, Inits.GameHeight-150, 10000, "left")
    for i =1,#loadingArrows do
        love.graphics.setColor(1,1,1, loadingArrows[i].alpha)

        love.graphics.draw(loadingArrows[i].image, loadingArrows[i].x, loadingArrows[i].y, nil, loadingArrows[i].sizeX, loadingArrows[i].sizeY)
    end
end

return PreLoader
