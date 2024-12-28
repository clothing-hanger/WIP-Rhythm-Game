Inits = require("inits")
utf8 = require("utf8")
love.filesystem.createDirectory("Music")
love.filesystem.createDirectory("Settings")
love.filesystem.createDirectory("Logs")

love._framerate = 1025 -- Due to frametime differences, this lets it sit at the 1000fps mark

function love.run()
    -- Locals run faster than globals, so to juice out some extra performance, we'll use locals for the main loop
    local g_origin, g_clear, g_present = love.graphics.origin, love.graphics.clear, love.graphics.present
    local g_active, g_getBGColour = love.graphics.isActive, love.graphics.getBackgroundColor
    local e_pump, e_poll = love.event.pump, love.event.poll, {}, 0
    local t_step = love.timer.step
    local t_getTime = love.timer.getTime
    local t_sleep = love.timer.sleep
    local dt = 0
    local love = love
    local love_load, love_update, love_draw = love.load, love.update, love.draw
    local love_quit, a_parseGameArguments = love.quit, love.arg.parseGameArguments
    local collectgarbage = collectgarbage
    local love_handlers = love.handlers

    love_load(a_parseGameArguments(arg), arg)

	t_step()
    t_step()
    collectgarbage()

    local lastFrame = 0

	return function()
        e_pump()

        ---@diagnostic disable-next-line: redefined-local
        for name, a,b,c,d,e,f in e_poll() do
            if name == "quit" then
                if not love_quit or not love_quit() then
                    return a or 0
                end
            end
            love_handlers[name](a,b,c,d,e,f)
        end

        dt = t_step()

        love_update(dt)

        while t_getTime() - lastFrame < 1 / love._framerate do
            t_sleep(0.0005)
        end

        lastFrame = t_getTime()
        
        if g_active() then
            g_origin()
            g_clear(g_getBGColour())
            love_draw()
            g_present()
        end

        collectgarbage("step")
    end
end

print(jit and jit.version or _VERSION)

love.audio.setVolume(0.15)

--function print() return end

function toGameScreen(x, y)
    -- converts a position to the game screen
    local ratio = 1
    ratio = math.min(Inits.WindowWidth/Inits.GameWidth, Inits.WindowHeight/Inits.GameHeight)
    local x, y = x - Inits.WindowWidth/2, y - Inits.WindowHeight/2
    x, y = x / ratio, y / ratio
    x, y = x + Inits.GameWidth/2, y + Inits.GameHeight/2

    return x, y
end

function love.load()

    love.graphics.setDefaultFilter("linear")
    -- Setup Libraries
    require("Modules.Controls") -- this goes with other libs since it inits a lib
    Class = require("Libraries.Class")
    State = require("Libraries.State")
    Tinyyaml = require("Libraries.Tinyyaml")
    Timer = require("Libraries.Timer")

    -- Initialize Game
    GameScreen = love.graphics.newCanvas(Inits.GameWidth, Inits.GameHeight)
    States = require("Modules.States")
    Shaders = require("Modules.Shaders")
    Objects = require("Modules.Objects")
    Threads = require("Modules.Threads")
    require("Modules.Love")
    require("Modules.Lua")
    require("Modules.Constants")
    require("Modules.Logs")
    require("Modules.RGB")
    require("Modules.MusicTime")
    require("Modules.TableToFile")
    require("Modules.Skin")
    require("Modules.Settings")
    require("Modules.Gradient")
    require("Modules.Parse")
    require("Modules.Debug")
    require("Modules.BPM")
    require("Modules.screenWipe")
    require("Modules.Notifications")
    require("Modules.Judgements")
    require("Modules.Grades")
    require("Modules.StylizedRectangles")
    require("Modules.DifficultyCalculator")
    require("Modules.Cursor")
    require("Modules.VolumeControl")

    Log = ""
    
    Skin:loadSkin()

    loadSettings()
    defaultFont = love.graphics.newFont(12)

    State.switch(States.Misc.PreLoader)
    debugInit()
    __updateDebugStats() -- force our stats to update

    --shaders
    riodejanerio = love.graphics.newShader("Shaders/rio-de-janerio.glsl")  --👅👅👅
   --error("test")
end

---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
    cursorText = nil
    if not console.isOpen then Input:update() end
    debugUpdate(dt)
    State.update(dt)
    Timer.update(dt)
    updateCursor(dt)
    debugUpdate(dt)
    notificationUpdate(dt)
    volumeUpdate(dt)
    
    love.audio.setVolume((Settings["masterVolume"]/100) or 0)

   -- updatemusicTimeFunction()   -- TEMPORARY FIX FOR SONGS NOT RESETTING       theres nothing more permanent than a temporary fix

    mouseTimer = (mouseTimer and mouseTimer - 1000*dt) or 1000
    mouseMoved = false
    
end
function love.wheelmoved(_, y)
    if love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt") then
        volumeScroll(y)
        return
    end
    State.wheelmoved(y)
end

function love.mousemoved()
    mouseMoved = true
    mouseTimer = 1000
end

function love.textinput(text)
    if console.isOpen then consoleTextinpput(text) end

    if State.current() == States.Menu.SettingsMenu then
        for _, TextBox in pairs(textBoxes) do
            TextBox:textinput(text)
        end
    end
end

function love.keypressed(key)
    if console.isOpen then
        consoleKeypressed(key)
    end
    if key == "f1" then
        console.isOpen = not console.isOpen
    end
    if State.current() == States.Menu.SettingsMenu then
        for _, TextBox in pairs(textBoxes) do
            TextBox:keypressed(key)
        end
    end
end


function love.draw()
    love.graphics.push()
        love.graphics.setCanvas(GameScreen)
            love.graphics.clear(0,0,0,1)
            State.draw()
            screenWipeDraw()
            notificationDraw()
            volumeControlDraw()
        love.graphics.setCanvas()
    love.graphics.pop()

    -- ratio
    local ratio = 1
    ratio = math.min(Inits.WindowWidth/Inits.GameWidth, Inits.WindowHeight/Inits.GameHeight)
    love.graphics.setColor(1,1,1,1)

    -- draw game screen with the calculated ratio and center it on the screen
    love.graphics.setShader(Shaders.CurrentShader)
    if freakyMode then
        love.graphics.setShader(riodejanerio)
    end
    love.graphics.draw(GameScreen, Inits.WindowWidth/2, Inits.WindowHeight/2, 0, ratio, ratio, Inits.GameWidth/2, Inits.GameHeight/2)
    love.graphics.setShader()
    
    cursorTextDraw()
    debugDraw()
end

function love.resize(w, h)
    Inits.WindowWidth = w
    Inits.WindowHeight = h
end

function love.quit()
    --States.Menu.SettingsMenu:saveSettings()
end