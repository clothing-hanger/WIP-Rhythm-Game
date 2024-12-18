local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
    log((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
    createLog()
end


function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

    local logo = love.graphics.newImage("Images/CrashHandler/logo.png")

    local selection = 1
 


	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")



	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

    local buttons = {
        {
            text = "Open crash log folder", 
            x = 50, 
            y = 460,
            func = function()
                love.system.openURL(love.filesystem.getSaveDirectory() .. "/Logs")
            end
        },
        {
            text = "Copy error", 
            x = 50, 
            y = 520,
            func = function()
                copyToClipboard()
            end
        },
        {
            text = "Close game", 
            x = 50, 
            y = 580,
            func = function()
                love.event.quit()
            end
        }
    }

    local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(0,0,0)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(logo, love.graphics.getWidth()-200,20)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        if buttons then
            for i = 1,#buttons do

                love.graphics.rectangle("line", buttons[i].x, buttons[i].y, 185, 50)
                love.graphics.print(buttons[i].text, buttons[i].x+14, buttons[i].y+14)
                if selection == i then
                    love.graphics.setColor(0,1,1)
                    love.graphics.rectangle("line", buttons[i].x-5, buttons[i].y-5, 195, 60)
                end
                love.graphics.setColor(1,1,1)

            end
        end
		love.graphics.present()
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
            elseif e == "keypressed" and a == "up" then
                selection = selection - 1 -- not using minusEq here to avoid outside functions in the error handler
                if selection < 1 then
                    selection = #buttons
                end
            elseif e == "keypressed" and a == "down" then
                selection = selection + 1
                if selection > #buttons then
                    selection = 1
                end
            elseif e == "keypressed" and a == "return" then
                for i = 1,#buttons do
                    if selection == i then
                        buttons[i].func()
                    end
                end
            
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end
