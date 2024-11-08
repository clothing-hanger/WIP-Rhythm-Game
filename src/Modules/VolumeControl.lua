local alpha = 0.1
local momentum = {
    masterVolume = 0,
    effectVolume = 0,
    musicVolume = 0,
}

local wheelPositions = {
    masterVolume = {x = Inits.GameWidth - 100, y = Inits.GameHeight - 100},
    effectVolume = {x = Inits.GameWidth - 100, y = Inits.GameHeight - 230},
    musicVolume = {x = Inits.GameWidth - 230, y = Inits.GameHeight - 100},
}

local wheelSettings = {
    "masterVolume",
    "effectVolume",
    "musicVolume",
}

volume = {
    master = 0,
    effect = 0,
    music = 0
}

---@param wheel string The key for the momentum
---@param y number The momentum to increase
local function updateMomentum(wheel, y)
    momentum[wheel] = momentum[wheel] + y * 6
end

---@param y number the y value for the scroll wheel (-1 - 1)
function volumeScroll(y)
    for wheel, pos in pairs(wheelPositions) do
        if math.abs(cursorX - pos.x) < 50 and math.abs(cursorY - pos.y) < 50 then
            updateMomentum(wheel, y)
            return
        end
    end
    updateMomentum("masterVolume", y)
end

---Applies the momentum
---@param setting string
---@param dt number
local function applyMomentum(setting, dt)
    Settings[setting] = Settings[setting] + momentum[setting] * dt
    Settings[setting] = clamp(Settings[setting], 0, 100)

    if momentum[setting] > 0 then
        momentum[setting] = momentum[setting] - 50 * dt
        if momentum[setting] < 0 then momentum[setting] = 0 end
    elseif momentum[setting] < 0 then
        momentum[setting] = momentum[setting] + 50 * dt
        if momentum[setting] > 0 then momentum[setting] = 0 end
    end
end

function volumeUpdate(dt)
    if love.keyboard.isDown("ralt") or love.keyboard.isDown("lalt") then

        for _, setting in ipairs(wheelSettings) do
            applyMomentum(setting, dt)
        end

        alpha = alpha + 7*dt
    else
        alpha = alpha - 7*dt
        for key in pairs(momentum) do
            momentum[key] = 0
        end
    end


    alpha = clamp(alpha, 0, 1)
end

function volumeControlDraw()
    love.graphics.setColor(1,1,1,alpha)
    for wheel, pos in pairs(wheelPositions) do
        local angle = (Settings[wheel] / 100) * 2 * math.pi
        if wheel ~= "masterVolume" then
            love.graphics.setColor(1,1,1,alpha)
            love.graphics.arc("fill", pos.x, pos.y, 50, 0, angle, 1000)
            love.graphics.setColor(0,0,0,alpha)
            
            if Settings[wheel] > 99 then
                love.graphics.circle("line",pos.x, pos.y, 50)
            else
                love.graphics.arc("line", pos.x, pos.y, 50, 0, angle, 1000)
            end
            love.graphics.setColor(1,1,1,alpha)

        else
            love.graphics.setColor(1,1,1,alpha)


            love.graphics.arc("fill", pos.x, pos.y, 70, 0, angle, 1000)
            love.graphics.setColor(0,0,0,alpha)

            if Settings[wheel] > 99 then
                love.graphics.circle("line",pos.x, pos.y, 70)
            else
                love.graphics.arc("line", pos.x, pos.y, 70, 0, angle, 1000)
            end

        end
    end
    love.graphics.setColor(1,1,1)
end
