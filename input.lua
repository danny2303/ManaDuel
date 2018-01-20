local input = {}

function input.load()

	cooldownTime = 20

    sticks = love.joystick.getJoysticks()
    inputs = {{button1 = {state=false,cooldown=0}, button2 = {state=false,cooldown=0}, button3 = {state=false,cooldown=0}, button4 = {state=false,cooldown=0}, trshoulder = {state=false,cooldown=0}, brshoulder = {state=false,cooldown=0}, tlshoulder = {state=false,cooldown=0}, blshoulder = {state=false,cooldown=0}, ballxl = 0, ballyl = 0, ballxr = 0, ballyr = 0},
    		{button1 = {state=false,cooldown=0}, button2 = {state=false,cooldown=0}, button3 = {state=false,cooldown=0}, button4 = {state=false,cooldown=0}, trshoulder = {state=false,cooldown=0}, brshoulder = {state=false,cooldown=0}, tlshoulder = {state=false,cooldown=0}, blshoulder = {state=false,cooldown=0}, ballxl = 0, ballyl = 0, ballxr = 0, ballyr = 0}}

    if love.joystick.getJoystickCount() < 2 then
    	love.errhand("Please connect at least 2 controllers")
    end

end

function input.update()

	updateCooldowns()

	updateStates()

end

function updateStates()

	for stickNum = 1, 2 do

		if inputs[stickNum].button1.cooldown < 0 then inputs[stickNum].button1.state = sticks[stickNum]:isDown(1) end
		if inputs[stickNum].button2.cooldown < 0 then inputs[stickNum].button2.state = sticks[stickNum]:isDown(2) end
		if inputs[stickNum].button3.cooldown < 0 then inputs[stickNum].button3.state = sticks[stickNum]:isDown(3) end
		if inputs[stickNum].button4.cooldown < 0 then inputs[stickNum].button4.state = sticks[stickNum]:isDown(4) end
		if inputs[stickNum].tlshoulder.cooldown < 0 then inputs[stickNum].tlshoulder.state = sticks[stickNum]:isDown(5) end
		if inputs[stickNum].blshoulder.cooldown < 0 then inputs[stickNum].blshoulder.state = sticks[stickNum]:isDown(6) end
		if inputs[stickNum].trshoulder.cooldown < 0 then inputs[stickNum].trshoulder.state = sticks[stickNum]:isDown(7) end
		if inputs[stickNum].brshoulder.cooldown < 0 then inputs[stickNum].brshoulder.state = sticks[stickNum]:isDown(9) end

		inputs[stickNum].ballxl, inputs[stickNum].ballyl, inputs[stickNum].ballxr, inputs[stickNum].ballyr = sticks[stickNum]:getAxes()

	end

end

function updateCooldowns()

	buttons = {"button1","button2","button3","button4","trshoulder","brshoulder","tlshoulder","blshoulder"}

	for stickNum = 1, 2 do
		for button = 1, 8 do

			if inputs[stickNum][buttons[button]].state == true and inputs[stickNum][buttons[button]].cooldown < 0 then
				inputs[stickNum][buttons[button]].cooldown = cooldownTime
				inputs[stickNum][buttons[button]].state = false
			end

			inputs[stickNum][buttons[button]].cooldown = inputs[stickNum][buttons[button]].cooldown - 1

		end
	end

end

function input.draw()



end

return input