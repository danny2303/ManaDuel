local lslui = {}

local font = love.graphics.getFont()
local utf8 = require("utf8")

function lslui.load()

	buttonScrollBuffer = 0

	sticks = love.joystick.getJoysticks()

	menuPage = 0
	runPage = "run"
	inGameMenuOpen = false
	canOpenMenu = true

	lineTimer = 0

	mouseX, mouseY = love.mouse.getPosition()
	
	click = love.audio.newSource("sounds/click.wav")

	backgrounds = {} --template {page,backgroundType,background}
	buttonArray = {{}}

	selectedButton = 5

end

function lslui.inGameMenu(key,inGameMenuPage)

	if inGame == true then
		if sticks[1]:isDown(8) == true or sticks[2]:isDown(8) == true then
			if canOpenMenu == true then
				inGameMenuOpen = not inGameMenuOpen
				canOpenMenu = false
			end
		elseif sticks[1]:isDown(8) == false and sticks[2]:isDown(8) == false then
			canOpenMenu = true
		end
		if inGameMenuOpen == true then
			menuPage = inGameMenuPage
		elseif inGameMenuOpen == false then
			menuPage = runPage
		end
		if menuPage == inGameMenuPage or menuPage == runPage then
			inGame = true
		else
			inGame = false
		end
	end

end

function lslui.addButton(args)

	if action == "inputText" then
		args.space = ""
		buttonArray[#buttonArray+1]=args
	else
		buttonArray[#buttonArray+1]=args
	end

end

function lslui.replaceButton(x,y,xsize,ysize,r,g,b,text,textx,texty,page,action,buttonNumber)

	if action == "inputText" then
		buttonArray[buttonNumber+1]={x,y,xsize,ysize,r,g,b,text,textx,texty,page,action,""}
	else
		buttonArray[buttonNumber+1]={x,y,xsize,ysize,r,g,b,text,textx,texty,page,action}
	end

end

function lslui.moveButton(x,y,buttonNumber)

	buttonArray[buttonNumber][1] = x
	buttonArray[buttonNumber][2] = y

end

function drawButton()

	for i=1,#buttonArray do
		if buttonArray[i].page == menuPage then

			 if not (selectedButton == i) then 
			 	love.graphics.setColor(50,50,50)
			 	love.graphics.rectangle("fill", buttonArray[i].pos.x-10, buttonArray[i].pos.y, buttonArray[i].size.xsize+10, buttonArray[i].size.ysize+10) 
			 end

			if takeMouseInputsForUI and mouseX > buttonArray[i].pos.x and mouseX < buttonArray[i].pos.x+buttonArray[i].size.xsize and mouseY > buttonArray[i].pos.y and mouseY < buttonArray[i].pos.y+buttonArray[i].size.ysize then
		    	love.graphics.setColor(buttonArray[i].color.r-150, buttonArray[i].color.b-150, buttonArray[i].color.g-150)
		    else
		        love.graphics.setColor(buttonArray[i].color.r, buttonArray[i].color.b, buttonArray[i].color.g)
		    end
		    if selectedButton == i then
			love.graphics.setColor(100,100,100)
		    end
		    love.graphics.rectangle("fill", buttonArray[i].pos.x, buttonArray[i].pos.y, buttonArray[i].size.xsize, buttonArray[i].size.ysize)
		    love.graphics.setColor(0, 0, 0)
		 --   love.graphics.rectangle("line", buttonArray[i].pos.x, buttonArray[i].pos.y, buttonArray[i].size.xsize, buttonArray[i].size.ysize)

		    if buttonArray[i].action == "inputText" or buttonArray[i].action == "typing" then
		    	love.graphics.print(buttonArray[i].textData.text, buttonArray[i].pos.x+buttonArray[i].textData.textx+10, buttonArray[i].pos.y+buttonArray[i].textData.texty+10, 0, 3, 3)
		    	love.graphics.setColor(255, 255, 255)
		    	love.graphics.rectangle("fill", buttonArray[i].pos.x+font:getWidth(buttonArray[i].textData.text)*3+10, buttonArray[i].pos.y+5, -font:getWidth(buttonArray[i].textData.text)*3-10+buttonArray[i].size.xsize-5, buttonArray[i].size.ysize-10)
		    else
			    --NOTE : Text centralisation doesn't work amazingly so use textx and texty to get it right vv
			    love.graphics.print(buttonArray[i].textData.text, buttonArray[i].pos.x+buttonArray[i].size.xsize/2-font:getWidth(buttonArray[i].textData.text)*1.5-5+buttonArray[i].textData.textx, buttonArray[i].pos.y+buttonArray[i].size.ysize/2-20+buttonArray[i].textData.texty, 0, 3, 3)
			end

		end

	end

end

function drawInputText()

	for i=1,#buttonArray do
		if buttonArray[i].page == menuPage then
			love.graphics.setColor(0, 0, 0)
	    	if buttonArray[i].action == "typing" then
	    		if (love.mouse.isDown(1) == true and (mouseX < buttonArray[i].pos.x or mouseX > buttonArray[i].pos.x+buttonArray[i].size.xsize or mouseY < buttonArray[i].pos.y or mouseY > buttonArray[i].pos.y +buttonArray[i].size.ysize)) or menuPage ~= buttonArray[i].page then
					buttonArray[i].action = "inputText"
					lineTimer = 1
				end
	    		lineTimer = lineTimer - 0.05
	    		if lineTimer <= 0 then
	    			if buttonArray[i].space == "" then
						love.graphics.print("|",buttonArray[i].pos.x+string.len(buttonArray[i].textData.text)*22+font:getWidth(buttonArray[i].space)*3+string.len(buttonArray[i].space)*5-4,buttonArray[i].pos.y+1, 0, 3.6, 3.63)
					else
						love.graphics.print("|",buttonArray[i].pos.x+string.len(buttonArray[i].textData.text)*22+font:getWidth(buttonArray[i].space)*3+string.len(buttonArray[i].space)*5-10,buttonArray[i].pos.y+1, 0, 3.6, 3.63)
					end
				end
				if lineTimer <= -1 then
					lineTimer = 1
				end
			end
			if buttonArray[i].action == "inputText" or buttonArray[i].action == "typing" then
				love.graphics.print(buttonArray[i].space,buttonArray[i].pos.x+font:getWidth(buttonArray[i].textData.text)*3+10,buttonArray[i].pos.y+10, 0, 3.6, 3.63)
			end
		end
	end

end

function mousepressed()

	for i=1,#buttonArray do
		if buttonArray[i].page == menuPage then
			if love.mouse.isDown(1) == true then
				if canClick == true then
					if mouseX > buttonArray[i].pos.x and mouseX < buttonArray[i].pos.x+buttonArray[i].size.xsize and mouseY > buttonArray[i].pos.y and mouseY < buttonArray[i].pos.y+buttonArray[i].size.ysize then
						manageClick(i)
				    end
				end
			elseif love.mouse.isDown(1) == false then
			    canClick = true
			end
		end
	end

end

function love.textinput(text)

	for i=1,#buttonArray do
		if buttonArray[i].action == "typing" and buttonArray[i].pos.x+string.len(buttonArray[i].textData.text)*22+font:getWidth(buttonArray[i].space)*3+string.len(buttonArray[i].space)*5-4 < buttonArray[i].pos.x+font:getWidth(buttonArray[i].textData.text)*3+10-font:getWidth(buttonArray[i].textData.text)*3-10+buttonArray[i].size.xsize-5 then
			buttonArray[i].space = buttonArray[i].space .. text
		end
	end

end

function love.keypressed(key)

	for i=1,#buttonArray do
		if buttonArray[i].action == "typing" then
		    if key == "backspace" then
		        local byteoffset = utf8.offset(buttonArray[i].space, -1)
		        if byteoffset then
		            buttonArray[i].space = string.sub(buttonArray[i].space, 1, byteoffset - 1)
		        end
		    end
		end
	end

end

function drawMenuBackgrounds() --Image or colour

	if menuPage ~= "gameMenu1" then
		for i=1,#backgrounds do
			for j=1,#backgrounds[i][1] do
				if menuPage == backgrounds[i][1][j] then
					if backgrounds[i][2] == "colour" then
						love.graphics.setBackgroundColor(backgrounds[i][3][1], backgrounds[i][3][2], backgrounds[i][3][3])
					elseif backgrounds[i][2] == "image" then
						background = love.graphics.newImage(backgrounds[i][3])
						love.graphics.setColor(255,255,255)
						love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth()/background:getWidth(), love.graphics.getHeight()/background:getHeight())
					end
				end
			end
		end
	end

end

function lslui.setMenuBackground(args)

	bType = "nil"
	bData = "nil"
	if args.image then 
		bType = "image"
		bData = args.image
	end

	if args.colour then 
		bType = "colour"
		bData = args.colour 
	end

	backgrounds[#backgrounds+1] = {args.page,bType,bData}

end

function lslui.setPage(page)
	menuPage = page
end

function lslui.getPage()
	return menuPage
end

function lslui.getInputButtonText(ID)
	if buttonArray[ID+1][13] ~= nil then
		return buttonArray[ID+1].space
	else
		return nil
	end
end

function lslui.update()

	mouseX, mouseY = love.mouse.getPosition()
	if takeMouseInputsForUI then mousepressed() end
	if inGame == false then checkForJoystickMovement() end

	if menuPage == runPage then
		inGame = true
		inGameMenuOpen = false
	elseif menuPage == 0 then
		inGame = false
		inGameMenuOpen = false
	end

end

function lslui.draw()

	drawMenuBackgrounds()
	drawButton()
	drawInputText()

end

function checkForJoystickMovement()

	if buttonScrollBuffer <= 0 then

		if inputs[1].ballyl < 0 then
		   selectedButton = buttonArray[selectedButton].joystickActions.up
		   buttonScrollBuffer = 2
		end

		if inputs[1].ballyl > 0 then
			selectedButton = buttonArray[selectedButton].joystickActions.down
			buttonScrollBuffer = 2
		end

		if inputs[1].ballxl < 0 then
			selectedButton = buttonArray[selectedButton].joystickActions.left
			buttonScrollBuffer = 2
		end

		if inputs[1].ballxl > 0 then
		    selectedButton = buttonArray[selectedButton].joystickActions.right
		   buttonScrollBuffer = 2
		end

	end

	if inputs[1].button1.state == true then
		manageClick(selectedButton)
	end

	buttonScrollBuffer = buttonScrollBuffer - 0.5

end

function manageClick(buttonID)

	if buttonArray[buttonID].action == "exit" then
		love.event.quit()
	elseif buttonArray[buttonID].action == "run" then
		menuPage = runPage
	elseif buttonArray[buttonID].action == "fullscreen" then
	if love.window.getFullscreen() == true then love.window.setFullscreen(false) elseif love.window.getFullscreen() == false then love.window.setFullscreen(true) end
		canClick = false
	elseif buttonArray[buttonID].action == "inputText" then
		buttonArray[buttonID].action = "typing"
		lineTimer = 0
	elseif buttonArray[buttonID].action ~= "typing" then
		menuPage = buttonArray[buttonID].action
		canClick = false
	end

	click:play()	
	selectedButton = buttonArray[selectedButton].joystickActions.autoButtonSelect

end

return lslui