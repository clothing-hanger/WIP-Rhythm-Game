local TitleScreen = State()

local selection
local logo
local buttons
local logoSize
local menuState

firstTimeOnTitle = true


function TitleScreen:enter()
    Objects.Menu.ModifiersMenu:new()
    Objects.Menu.Visualizer:new()

    debugHY = Inits.GameHeight/2
    debugHX = Inits.GameWidth/2
    if firstTimeOnTitle then   -- so we only start on the H on first time seeing the title screen
        menuState = "H"
        firstTimeOnTitle = false
        menuSlide = {Inits.GameHeight}

        logoSize = {x = 1, y = 1, r = 1}
        logoPosition = {x = 0, y = Inits.GameHeight/2}
        hSize = {x = 2,y = 2}
        hPosition = {x = Inits.GameWidth/2, y = Inits.GameHeight/2}

    else
        menuState = "title"
        menuSlide = {0}
        logoSize = {x = 1, y = 1, r = 1}
        logoPosition = {x = Inits.GameWidth/2, y = Inits.GameHeight/2-250}
        hSize = {x = 1,y = 1}
        hPosition = {x = 478, y = Inits.GameHeight/2-250}

    end


    
    SelectedDifficulty = 1
    if not SelectedSong then SelectedSong = love.math.random(1,#SongList) end
--[[

    if not Song or (Song and not Song:isPlaying()) then 
        TitleScreen:switchSong()
        SelectedSong = love.math.random(1,#SongList)
        print("case 1")
    else
        TitleScreen:switchSong()
        print("case 2")
    end
--]]
    TitleScreen:switchSong()


    buttons = {    -- time to make yet another completely different button format because i cant code consistently
        {
            text = "Play", 
            x = Inits.GameWidth/2-100,
            y = Inits.GameHeight/2, 
            width = 200, 
            height = 50,
            func = function()
                State.switch(States.Menu.SongSelect)
            end,
        },
        {
            text = "Settings",
            x = Inits.GameWidth/2-100, 
            y = Inits.GameHeight/2-100, 
            width = 200, 
            height = 50, 
            func = function()
                State.switch(States.Menu.SettingsMenu)
            end,     
        },
    }
end

function TitleScreen:switchSong()   -- icky disgusting code copy but its fine i guess (this almost exact code is in 2 places in the game)
    TitleScreen:setupDifficultyList()

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
    Song:play()
end


function TitleScreen:setupDifficultyList()  -- same comment here as in the function above :(
    DifficultyButtons = {}
    DifficultyList = {}
    local SongContents = love.filesystem.getDirectoryItems("Music/" .. SongList[SelectedSong])
    local metaData = love.filesystem.load("Music/"..SongList[SelectedSong].."/meta.lua")()
    for i = 1, #SongContents do
        if getFileExtension(tostring(SongContents[i])) == ".qua" then
            table.insert(DifficultyList, SongContents[i])
            for j, difficulty in ipairs(metaData.difficulties) do
                if tostring(DifficultyList[i]) == difficulty.fileName then
                    table.insert(DifficultyButtons, Objects.Menu.DifficultyButton(difficulty.diffName, "PLACEHOLDER", "PLACEHOLDER", i))
                end
            end
        end
    end
end 

function TitleScreen:logoBump()
    local visualizerBump = (Objects.Menu.Visualizer:getAverageBarLength() or 0)
    if menuState == "title" then
        visualizerBump = visualizerBump/2   
    elseif menuState == "H" then            -- bump twice as strong when on H screen
        visualizerBump = visualizerBump*2
    end
    logoSize = {x = 1+visualizerBump, y = 1+visualizerBump, r = 0}
    
    Timer.tween(0.5, logoSize, {x = 1, y = 1}, "in-out-bounce")
end

function TitleScreen:switchState(state)
    if not state then 
        print("dumbass you gotta put a state in there") 
        return
    end
    local speed, tweenType
    if tweens then
        for i = 1, #tweens do
            if tweens[i] then Timer.cancel(tweens[i]) end
        end
    end
    tweens = {}
    if state == "title" then
        menuState = "title"
        speed = 0.5
        tweenType = "out-expo"
        tweens = {
            Timer.tween(speed, hSize, {x = 1, y = 1}, tweenType),
            Timer.tween(speed, hPosition, {x = 478, y = Inits.GameHeight/2-250}, tweenType),
            Timer.tween(speed, logoPosition, {x = Inits.GameWidth/2, y = Inits.GameHeight/2-250}, tweenType),
            Timer.tween(speed, menuSlide, {0}, tweenType),
        }
    elseif state == "H" then
        menuState = "H"
        speed = 2
        tweenType = "out-expo"
        tweens = {
            Timer.tween(speed, hSize, {x = 2, y = 2}, tweenType),
            Timer.tween(speed, hPosition, {x = Inits.GameWidth/2, y = Inits.GameHeight/2}, tweenType),
            Timer.tween(speed, logoPosition, {x = 0, y = Inits.GameHeight/2}, tweenType),
            Timer.tween(speed, menuSlide, {Inits.GameHeight}, tweenType),
        }
    end
end


function TitleScreen:doReturnToHTimer()
    if not returnToHTTimer then
        returnToHTTimer = Timer.after(5, function() 
            TitleScreen:switchState("H")
            returnToHTTimer = nil
        end)
    end

    if mouseMoved and returnToHTTimer then
        Timer.cancel(returnToHTTimer)
        returnToHTTimer = nil
    end
end
function TitleScreen:update(dt)
    updateBPM()
    if onBeat then TitleScreen:logoBump() end
    if Song and Song:isPlaying() then
        Objects.Menu.Visualizer:update(dt)
    end
    

    if menuState == "title" then
        TitleScreen:doReturnToHTimer()
        if Input:pressed("menuClickLeft") then
            for _, Button in pairs(buttons) do
                if cursorX >= Button.x and cursorX <= Button.x+Button.width and cursorY >= Button.y and cursorY <= Button.y + Button.height then
                    Button.func()
                end
            end
        end
    elseif menuState == "H" then
        if Input:pressed("menuClickLeft") or Input:pressed("menuConfirm") then
            TitleScreen:switchState("title")
        end
    end
end

function TitleScreen:draw()
    local parallaxStrength, speed, growScale, normalScale = 0.05, 0.01, 1.1, 1.0 
    local targetOffsetX, targetOffsetY = (cursorX - Inits.GameWidth / 2) * parallaxStrength, (cursorY - Inits.GameHeight / 2) * parallaxStrength 
    if menuState == "title" then 
        self.parallaxOffsetX = lerp(self.parallaxOffsetX or 0, targetOffsetX, speed)
        self.parallaxOffsetY = lerp(self.parallaxOffsetY or 0, targetOffsetY, speed)
        self.scale = lerp(self.scale or normalScale, growScale, speed)
    else 
        self.parallaxOffsetX = lerp(self.parallaxOffsetX or 0, 0, speed)
        self.parallaxOffsetY = lerp(self.parallaxOffsetY or 0, 0, speed)
        self.scale = lerp(self.scale or growScale, normalScale, speed)
    end 
    if background then love.graphics.draw(background, Inits.GameWidth / 2 - (self.parallaxOffsetX or 0), Inits.GameHeight / 2 - (self.parallaxOffsetY or 0), 0, (Inits.GameWidth / background:getWidth()) * (self.scale or 1), (Inits.GameHeight / background:getHeight()) * (self.scale or 1), background:getWidth() / 2, background:getHeight() / 2) end 



    Objects.Menu.Visualizer:draw()

    local hWidth = Skin.Menu["H"]:getWidth() * hSize.x  -- set the scissor 
    local hHeight = Skin.Menu["H"]:getHeight() * hSize.y
    love.graphics.setScissor(hPosition.x+25, hPosition.y-1000, 100000, 100000)
    if menuState == "title" and hPosition.x < 479 then
        love.graphics.setScissor()  -- unset the scissor
    end 
    
    love.graphics.draw(Skin.Menu["Main Logo"], logoPosition.x, logoPosition.y,  0, logoSize.x, logoSize.y, Skin.Menu["Main Logo"]:getWidth()/2, Skin.Menu["Main Logo"]:getHeight()/2)
    
    love.graphics.setScissor()  -- unset the scissor
    if menuState == "title" and hPosition.x < 479 then
        love.graphics.setColor(1,1,1,0)
    else                                  -- only draw the H when its not displaying the entire logo
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.draw(Skin.Menu["H"], hPosition.x, hPosition.y, 0, hSize.x+(logoSize.x-1), hSize.y+(logoSize.y-1), Skin.Menu["H"]:getWidth()/2, Skin.Menu["H"]:getHeight()/2)
    
   love.graphics.setColor(1,1,1)
   
    love.graphics.translate(0, menuSlide[1])    -- translate stuff for the slide thingy 
    love.graphics.setFont(Skin.Fonts["Menu Small"])
    for _, Button in pairs(buttons) do
        love.graphics.setColor(0,0,0,0.8)
        love.graphics.rectangle("fill", Button.x, Button.y, Button.width, Button.height)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", Button.x, Button.y, Button.width, Button.height)
        love.graphics.printf(Button.text, Button.x, Button.y+10, Button.width, "center")
    end
end


return TitleScreen