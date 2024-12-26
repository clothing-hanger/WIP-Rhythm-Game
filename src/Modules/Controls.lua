function setupControls()
    return (require("Libraries.Baton")).new({
        controls = {
            menuUp = {"key:up", "button:dpup"},
            menuDown = {"key:down", "button:dpdown"},
            menuRight = {"key:right", "button:dpright"},
            menuLeft = {"key:left", "button:dpleft"},
            menuConfirm = {"key:return", "button:a"},
            menuBack = {"key:escape", "button:b"},

            menuClickLeft = {"mouse:1"},

            lane14K = {"key:" .. keyBinds4k[1], "axis:triggerleft+"},
            lane24K = {"key:" .. keyBinds4k[2], "button:leftshoulder"},
            lane34K = {"key:" .. keyBinds4k[3], "button:rightshoulder"},
            lane44K = {"key:" .. keyBinds4k[4], "axis:triggerright+"},

            lane17K = {"key:" .. keyBinds7k[1]},
            lane27K = {"key:" .. keyBinds7k[2]},
            lane37K = {"key:" .. keyBinds7k[3]},
            lane47K = {"key:" .. keyBinds7k[4]},
            lane57K = {"key:" .. keyBinds7k[5]},
            lane67K = {"key:" .. keyBinds7k[6]},
            lane77K = {"key:" .. keyBinds7k[7]},

            debugConsoleToggle = {"key:`"}
        },
        joystick = love.joystick.getJoysticks()[1]
    })
end