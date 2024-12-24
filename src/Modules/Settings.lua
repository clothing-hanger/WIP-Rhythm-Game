function loadSettings()
    settingsFile = love.filesystem.load("Settings/Settings.lua")

    if Settings == nil then Settings = {} end
    if not settingsFile then
        States.Menu.SettingsMenu:saveSettings()  -- sets up default 
        settingsFile = love.filesystem.load("Settings/Settings.lua")
    end
        
    -- check for missing settings
    Settings = settingsFile() or {}
    local hasMissing = States.Menu.SettingsMenu:checkForMissingSettings()
    
    if hasMissing then
        States.Menu.SettingsMenu:saveSettings()
    end
    local GameScreenMiddle = Inits.GameWidth/2
    LanesPositions = {
        ["4K"] = {
            GameScreenMiddle - (Settings.laneWidth*1.5),
            GameScreenMiddle - (Settings.laneWidth*0.5),
            GameScreenMiddle + (Settings.laneWidth*0.5),
            GameScreenMiddle + (Settings.laneWidth*1.5),
        },
        ["7K"] = {
            GameScreenMiddle - (Settings.laneWidth*3),
            GameScreenMiddle - (Settings.laneWidth*2),
            GameScreenMiddle - (Settings.laneWidth),
            GameScreenMiddle,
            GameScreenMiddle + (Settings.laneWidth),
            GameScreenMiddle + (Settings.laneWidth*2),
            GameScreenMiddle + (Settings.laneWidth*3),
        }
    }

    if Settings.keyBinds4k then
        keyBinds4k = splitIntoLetters(Settings.keyBinds4k)
    else
        Settings.keyBinds4k = splitIntoLetters("dfjk")
    end
    if Settings.keyBinds7k then
        keyBinds7k = splitIntoLetters(Settings.keyBinds7k)
    else
        keyBinds7k = splitIntoLetters("sdf jkl")
    end

    Input = setupControls()
end

---@param speed number The speed in ms
---@return number convertedScrollspeed the speed in pixels/ms
function convertScrollSpeed(speed)
    local convertedSpeed = (Inits.GameHeight) / speed
    return convertedSpeed
end
