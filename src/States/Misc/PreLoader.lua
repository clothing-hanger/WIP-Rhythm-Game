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
    frame = 0

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
                --  ^ Actually, %q automatically does this
                if i == 1 then
                    local safeTitle = tostring(chart.Title)     -- tostring them because somehow I had one be a number????
                end
                local safeDiffName = tostring(chart.DifficultyName)
                local safeArtist = tostring(chart.Artist)
                local safeCharter = tostring(chart.Creator)
                local safeBackground = tostring(chart.BackgroundFile)
                local safeBanner = tostring(chart.BannerFile)
                local safeAudio = tostring(chart.AudioFile)

                
                metas[#metas+1] = ("{fileName = %q, diffName = %q, artistName = %q, charterName = %q, background = %q, banner = %q, audio = %q, format = %q},\n"):format( 
                    DifficultyList[i],
                    safeDiffName,
                    safeArtist,
                    safeCharter,
                    safeBackground,
                    safeBanner,
                    safeAudio,
                    "Quaver"
                )


            end
            if(safeTitle ~= nil) then
                metaString = ("return {\nsongName = %q,\nversion = %d,\ndifficulties = {\n\t%s\n}}"):format(
                    safeTitle, curMetaVersion,
                    table.concat(metas, ",\n\t")
                )
            end
            love.filesystem.write("Music/" .. SongList[frame] .. "/meta.lua", metaString)
        elseif deleteMetaFiles then
            print("Meta file deleted for:", SongList[frame])
        else
            print("Meta Found")
        end
        
        if frame == #SongList then
            if deleteMetaFiles then 
                love.event.quit()  -- Close the game once all meta files have been deleted
                return
            end
            State.switch(States.Menu.Intro) 
            preloaderFont = nil
            return
        end
    end
    
end
function PreLoader:exit()
    PreLoader.stopArrows=true
end
function PreLoader:updateLoadingArrows()
    if(PreLoader.stopArrows) then
        return
    end
    -- The timer isn't being stopped when switching states
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
    love.graphics.printf("Hang tight! Harmoni is processing your songs!\nThis might take some time if the song has not been processed before.\nPlease don't close the game!! (unless you really wanna.. i dont care lmfao)\n\n(A blue loading bar means the song is being first-time processed.)", 0, Inits.GameHeight/2, Inits.GameWidth, "center")
    for i =1,#loadingArrows do
        love.graphics.setColor(1,1,1, loadingArrows[i].alpha)

        love.graphics.draw(loadingArrows[i].image, loadingArrows[i].x, loadingArrows[i].y, nil, loadingArrows[i].sizeX, loadingArrows[i].sizeY)
    end
end

return PreLoader
