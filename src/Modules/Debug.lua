local stateString = ""
local cursorTimer


console = {}

commands = {
    {
        name = "help",
        help = "I think you know what this one does lmao",
        func = function()
            local debugHelpTable = {}
            for Key, Command in ipairs(commands) do
                local helpText = Command.name .. "- " .. Command.help
                table.insert(debugHelpTable, helpText)
            end
            consoleWriteLine(debugHelpTable) 
        end
    },
    {
        name = "saveFolder",
        help = "Opens the save directory in explorer",
        func = function()
            local saveDir = love.filesystem.getSaveDirectory()
            if love.system.getOS() == "Windows" then
                os.execute('start "" "' .. saveDir .. '"')
            elseif love.system.getOS() == "Linux" then
                os.execute('xdg-open "' .. saveDir .. '"')
            elseif love.system.getOS() == "OS X" then
                os.execute('open "' .. saveDir .. '"')
            else
                print("Unsupported operating system.")
            end
        end
    },
    {
        name = "clear",
        help = "clears the console history",
        func = function()
            console.history = {}
        end
    },
    {
        name = "skipToEnd",
        help = "is SUPPOSED to skip to 5 seconds before the last note BUT IT DOESNT FUCKING WORK",
        func = function()
           -- musicTime = (metaData.songLengthToLastNote - 5)*1000
          --  Song:seek(metaData.songLengthToLastNote)
        end
    },
    {
        name = "crash",
        help = "causes an intentional crash",
        func = function()
            error("Test Crash")

        end
    },
    {
        name = "get freaky",
        help = "...",
        func = function()
            freakyMode = true
            Skin.Fonts = {
                ["HUD Large"] = love.graphics.newFont("FONTS/papyrus.ttf", 65),
                ["HUD Small"] = love.graphics.newFont("FONTS/papyrus.ttf", 15),
                ["HUD Extra Small"] = love.graphics.newFont("FONTS/papyrus.ttf", 12),
                ["Combo"] = love.graphics.newFont("FONTS/papyrus.ttf", 35),
                ["Menu Large"] = love.graphics.newFont("FONTS/papyrus.ttf", 25),
                ["Menu Small"] = love.graphics.newFont("FONTS/papyrus.ttf", 15),
                ["Menu Extra Small"] = love.graphics.newFont("FONTS/papyrus.ttf", 12),
            }
            defaultFont = love.graphics.newFont("FONTS/papyrus.ttf", 12)

        end
    },
}


function debugInit()
    console.isOpen = false
    console.textInput = ""
    console.width = 500
    console.height = 500
    cursorTimer = 1000
    console.textPrompt = "> "
    console.history = {"Type help for a list of available commands"}
    console.blinkingCursor = "|"
end

function consoleCursorBlink() -- this is so useless lmao
    cursorTimer = 1000
    if console.blinkingCursor == "|" then
        console.blinkingCursor = ""
    else
        console.blinkingCursor = "|"
    end
end

---@param text table
function consoleWriteLine(text)
    if not text then return end

    local function writeTableText(textTable)
        for i = 1,#textTable do
            table.insert(console.history, tostring(textTable[i]))
        end
    end

    if type(text) == "table" then
        writeTableText(text)
    else
        table.insert(console.history, tostring(text))
    end
end

function debugUpdate(dt)
    cursorTimer = cursorTimer - 1000*dt
    if cursorTimer <= 0 then
        consoleCursorBlink()
    end

end

---@param key love.KeyConstant
function consoleKeypressed(key)
    if key == "backspace" then
        local byteoffset = utf8.offset(console.textInput, -1)
        if byteoffset then
            console.textInput = string.sub(console.textInput, 1, byteoffset - 1)
        end
    elseif key == "return" then
        table.insert(console.history, console.textInput)
        table.insert(console.history, "")

        consoleExecute(console.textInput)
        console.textInput = ""
    end
end

---@param input string
function consoleExecute(input)
    for Key, Command in ipairs(commands) do
        if Command.name == input then
            Command.func()
            return        -- return so it doesnt try to run it as a function
        end
    end

    local func, err = loadstring(input)
    if func then
        local success, result = pcall(func)
        if success then
            table.insert(console.history, tostring(result))
        else
            table.insert(console.history, "Error: " .. result)
        end
    else
        table.insert(console.history, "Syntax Error: " .. err)
    end

    return    -- return even tho this is useless just cuz the code looks better with it lmao

end

function consoleTextinpput(text)
    cursorTimer = 1000

    console.textInput = console.textInput .. text
end

function debug.printInfo()
    if stateDebugString then stateString = stateDebugString end
    
    love.graphics.translate(0, Inits.GameHeight-200)
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill", 0, 0, 200, 200)
    love.graphics.setColor(1,1,1)
    love.graphics.print(
        "FPS: " .. tostring(love.timer.getFPS()) .. 
        "\nLua Memory (KB): " .. tostring(math.floor(collectgarbage("count"))) ..
        "\nGraphics Memory (MB): " .. tostring(math.floor(love.graphics.getStats().texturememory/1024/1024)) ..
        stateString
    )
    love.graphics.translate(0, -Inits.GameHeight-200)
end

function consoleDraw()
    if not console.isOpen then return end
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle("fill", 0, 0, console.width, console.height)
    love.graphics.setColor(1,1,1)
    for i = 1,#console.history do
        love.graphics.print(console.history[i], 10, i*15)
    end
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 10, console.height + 25, console.width, 15)
    love.graphics.setColor(1,1,1)
    love.graphics.print(console.textPrompt .. console.textInput .. console.blinkingCursor, 10, console.height + 25)
end

local debugStats = {}


local mFloor = math.floor
local statsUpdateTime, statsUpdateTimeMax = 0, 1

function __updateDebugStats()
    debugStats.fps = love.timer.getFPS()
    debugStats.memUsage = mFloor(collectgarbage("count"))

    local graphicsStats = love.graphics.getStats()
    debugStats.graphicsMem = mFloor(graphicsStats.texturememory / 1024 / 1024)
    debugStats.drawCalls = graphicsStats.drawcalls
    debugStats.frameTime = string.format("%.2f", love.timer.getDelta())
    debugStats.rectCalls = graphicsStats.rectCalls
end

function debugUpdate(dt)

    statsUpdateTime = statsUpdateTime + dt
    if statsUpdateTime >= statsUpdateTimeMax then
        __updateDebugStats()
        statsUpdateTime = 0
    end
end

function debugDraw()
    consoleDraw()
    
    love.graphics.push()
    
    love.graphics.translate(0, 600)

    love.graphics.setFont(defaultFont)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 200, 200)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        "FPS: " .. debugStats.fps .. 
        "\nLua Memory (KB): " .. debugStats.memUsage ..
        "\nGraphics Memory (MB): " .. debugStats.graphicsMem .. 
        "\nMusic Time (MS): " .. string.format("%.3f", musicTime) ..
        "\nBeat Time (MS): " .. string.format("%.3f", debugBeatTime) .. 
        "\nDraw Calls: " .. debugStats.drawCalls ..
        "\nFrame Time (MS): " .. debugStats.frameTime ..
        "\nRectangle Calls: " .. debugStats.rectCalls
    )

    love.graphics.pop()

    love.graphics.translate(0, -Inits.GameHeight + 200)
end
