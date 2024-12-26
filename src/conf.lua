function love.conf(t)
    versionNumber = "Rewrite 0.1.0"

    t.window.title = "Harmoni " .. versionNumber
    t.identity = "Harmoni Rewrite"


    t.window.width = 1280
    t.window.height = 720
    t.console = true

    t.window.resizable = true
    t.window.vsync = 0
    t.highdpi = true
end