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

    preloaderFont = love.graphics.newFont("Fonts/SourceCodePro-Medium.ttf", 30)
    logo = love.graphics.newImage("Images/Intro/logo.png")

    loadingArrows = {}
    for i = 1,4 do
        local girth = 60  -- i need to stop coding like this..
        local cock = (Inits.GameWidth - 265) + ((i-1)*girth)
        local dick = Inits.GameHeight - 180
        local penis = love.graphics.newImage("images/intro/" .. i .. ".png")
        table.insert(loadingArrows, {image = penis, x = cock, y = dick, sizeX = 0.2, sizeY = 0.2, alpha = 0})
    end
    self:updateLoadingArrows()

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
        State.switch(States.Menu.Intro) 
        preloaderFont = nil
    end

    
end

function PreLoader:updateLoadingArrows()
    print("what")
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
    love.graphics.printf("Hang tight! Harmoni is processing your songs!\nThis might take some time if the song has not been processed before.\nPlease don't close the game!! (unless you really wanna.. i dont care lmfao)\n\n(A blue loading bar means the song is being first-time processed.)", 0, Inits.GameHeight/2, Inits.GameWidth, "center")
    for i =1,#loadingArrows do
        love.graphics.setColor(1,1,1, loadingArrows[i].alpha)

        love.graphics.draw(loadingArrows[i].image, loadingArrows[i].x, loadingArrows[i].y, nil, loadingArrows[i].sizeX, loadingArrows[i].sizeY)
    end
end

return PreLoader
