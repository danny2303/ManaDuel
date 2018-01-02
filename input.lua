local input = {}

function input.load()

    sticks = love.joystick.getJoysticks()
    inputs = {{button1 = false, button2 = false, button3 = false, button4 = false, trshoulder = false, brshoulder = false, tlshoulder = false, blshoulder = false, ballxl = 0, ballyl = 0, ballxr = 0, ballyr = 0},{button1 = false, button2 = false, button3 = false, button4 = false, trshoulder = false, brshoulder = false, tlshoulder = false, blshoulder = false, ballxl = 0, ballyl = 0, ballxr = 0, ballyr = 0}}

    if love.joystick.getJoystickCount() < 2 then
    	love.errhand("Please connect at least 2 controllers")
    end

end

function input.update()

	for stickNum = 1, 2 do

		inputs[stickNum].button1 = sticks[stickNum]:isDown(1)
		inputs[stickNum].button2 = sticks[stickNum]:isDown(2)
		inputs[stickNum].button3 = sticks[stickNum]:isDown(3)
		inputs[stickNum].button4 = sticks[stickNum]:isDown(4)
		inputs[stickNum].tlshoulder = sticks[stickNum]:isDown(5)
		inputs[stickNum].blshoulder = sticks[stickNum]:isDown(6)
		inputs[stickNum].trshoulder = sticks[stickNum]:isDown(7)
		inputs[stickNum].brshoulder = sticks[stickNum]:isDown(8)

		inputs[stickNum].ballxl, inputs[stickNum].ballyl, inputs[stickNum].ballxr, inputs[stickNum].ballyr = sticks[stickNum]:getAxes()

	end

end

function input.draw()



end

return input