local Intro = State()

local fakeMusicTime
local arrows
local timings

local arrowWhiteToBlack
function Intro:enter()
    fakeMusicTime = -100
    flashAlpha = {0}
    arrowWhiteToBlack = {1}
    Objects.Menu.ModifiersMenu:new()  -- :/
    timings = {
        370,
        760,
        1210,
        1612,
        2160,
    }
    arrows = {}
    for i = 1, 4 do
        local spacing = 50
        local sx = 0.5
        local sy = 0.5
        local image = love.graphics.newImage("Images/Intro/"..i..".png")
        local imageWidth = image:getWidth() * sx
        local imageHeight = image:getHeight() * sy
        local totalWidth = (spacing * (4 - 1)) + (imageWidth * 4)
        local startX = (Inits.GameWidth - totalWidth) / 2
        local x = startX + (imageWidth + spacing) * (i - 1)
        local y = Inits.GameHeight / 2 - imageHeight/2
        local alpha = 0
        local timing = timings[i]
    
        table.insert(arrows, {timing = timing, image = image, x = x, y = y, sx = sx, sy = sy, alpha = alpha})
    end

   -- SelectedSong = #SongList -- this should always be Harmonize (i hope...)   (  it wasnt :/  )


    for i = 1,#SongList do
        if SongList[i] == "Harmonize" then SelectedSong = i end
    end


    SelectedDifficulty = 1
    Intro:loadSong()

end

function Intro:loadSong()
    States.Menu.TitleScreen:setupDifficultyList()

    print("Switch Song")
    local metaData = love.filesystem.load("Music/"..SongList[SelectedSong].."/meta.lua")()
    background = "Music/"..SongList[SelectedSong].."/"..metaData.difficulties[SelectedDifficulty].background
    for i, difficulty in ipairs(metaData.difficulties) do
        print(tostring(DifficultyList[SelectedDifficulty]))
        if tostring(DifficultyList[SelectedDifficulty]) == difficulty.fileName then
            print("diff")
            if love.filesystem.getInfo("Music/"..SongList[SelectedSong].."/"..metaData.difficulties[SelectedDifficulty].background) and
                love.filesystem.getInfo("Music/"..SongList[SelectedSong].."/"..metaData.difficulties[SelectedDifficulty].background).type == "file" then
                    
                background = love.graphics.newImage("Music/"..SongList[SelectedSong].."/"..metaData.difficulties[SelectedDifficulty].background)
            else
                background = nil
            end
            songName = metaData.songName
            difficultyName = "Music/"..SongList[SelectedSong].."/"..metaData.difficulties[SelectedDifficulty].diffName
            print(metaData.difficulties[SelectedDifficulty].background)
        end
    end
    Objects.Menu.ModifiersMenu:configureMods()

    quaverParse("Music/"..SongList[SelectedSong].."/"..DifficultyList[SelectedDifficulty])
    if Song and Song:isPlaying() then
        Song:stop()
    end
end


function Intro:update(dt)
    if fakeMusicTime >= 0 then Song:play() end

    fakeMusicTime = fakeMusicTime + 1000*dt

    for i = 1,#arrows do
        if fakeMusicTime >= arrows[i].timing and not arrows[i].hit then
            Intro:hitArrows(arrows[i])
        end
    end

    if fakeMusicTime >= timings[#timings] and not introEnded then
        Intro:endIntro()
    end

end

function Intro:endIntro()
    introEnded = true
    if fadeInTimer then Timer.cancel(fadeInTimer) end
    for i = 1,#arrows do
        Timer.tween(3, arrows[i], {alpha = 1})
        
        flashTween = Timer.tween(3, flashAlpha, {1})
        Timer.tween(0.8, arrowWhiteToBlack, {0}, "linear", function()
            if flashTween then Timer.cancel(flashTween) end
            Timer.tween(1, flashAlpha, {0})
            State.switch(States.Menu.TitleScreen) 
        end)

    end
end

function Intro:hitArrows(arrow)
    arrow.hit = true
    print(arrow)
    fadeInTimer = Timer.tween(0.7, arrow, {alpha = 0.2})
end

function Intro:draw()
    love.graphics.setColor(1,1,1,flashAlpha[1])
    love.graphics.rectangle("fill",0,0,Inits.GameWidth,Inits.GameHeight)
    for i = 1,#arrows do
        love.graphics.setColor(arrowWhiteToBlack[1], arrowWhiteToBlack[1], arrowWhiteToBlack[1],arrows[i].alpha)
        love.graphics.draw(arrows[i].image, arrows[i].x, arrows[i].y, nil, arrows[i].sx, arrows[i].sy)
    end


end

return Intro 