local lslui = {}

local font = love.graphics.getFont()
local utf8 = require("utf8")

function lslui.load()

	spellbookScroll = 0
	spellbookScrollDir = 0 

	menuScrollSpeed = 0.1

	prevXDown = false

	runeFont = love.graphics.newFont("images/ui/runeFont.ttf", 36)
	runeFontSmall = love.graphics.newFont("images/ui/runeFont.ttf", 18)

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

	numMenuButtons=0

	inactiveRunes = love.graphics.newImage("images/ui/inactiveRunes.png")
	glowingRunes = love.graphics.newImage("images/ui/glowingRunes.png")
	button = love.graphics.newImage("images/ui/button.png")
	longButton = love.graphics.newImage("images/ui/longButton.png")

end

function drawRune(x,y,num,state,r,b,g,size,rotation)

	if state == "glowing" then love.graphics.setColor(r,b,g) else love.graphics.setColor(255,255,255) end

	quad = love.graphics.newQuad(0,(num-1)*100, 100, 100, 100, 800 )

	image = inactiveRunes
	if state == "glowing" then image = glowingRunes end

	love.graphics.draw(image,quad,x+50,y+50,rotation,size,size,50,50)

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

function lslui.getButton(buttonNumber)

	return buttonArray[buttonNumber]

end

function lslui.addButton(args)

	if not(args.color) then args.color = {r=255,g=255,b=255} end

	if not(args.textData.size) then args.textData.size = 3 end	

	if not(args.joystickActions.up) then args.joystickActions.up = #buttonArray+1 end
	if not(args.joystickActions.down) then args.joystickActions.down = #buttonArray+1 end
	if not(args.joystickActions.left) then args.joystickActions.left = #buttonArray+1 end
	if not(args.joystickActions.right) then args.joystickActions.right = #buttonArray+1 end

	if not(args.joystickActions.autoButtonSelect) then args.joystickActions.autoButtonSelect = #buttonArray+1 end

	if not(args.buttonType) then args.buttonType = {name = "button"} end

	if action == "inputText" then
		args.space = ""
		buttonArray[#buttonArray+1]=args
	else
		buttonArray[#buttonArray+1]=args
	end

end

function lslui.changeButton(args,buttonNumber)

	if not(args.color) then args.color = {r=255,g=255,b=255} end

	if not(args.textData.size) then args.textData.size = 3 end	

	if not(args.joystickActions.up) then args.joystickActions.up = buttonNumber end
	if not(args.joystickActions.down) then args.joystickActions.down = buttonNumber end
	if not(args.joystickActions.left) then args.joystickActions.left = buttonNumber end
	if not(args.joystickActions.right) then args.joystickActions.right = buttonNumber end

	if not(args.joystickActions.autoButtonSelect) then args.joystickActions.autoButtonSelect = buttonNumber end

	if not(args.buttonType) then args.buttonType = {name = "button"} end
	
	if action == "inputText" then
		buttonArray[buttonNumber]=args
	else
		buttonArray[buttonNumber]=args
	end

end

function lslui.moveButton(x,y,buttonNumber)

	buttonArray[buttonNumber].pos.x = x
	buttonArray[buttonNumber].pos.y = y

end

function drawButton()

	for i=1,#buttonArray do
		if buttonArray[i].page == menuPage then

			if buttonArray[i].buttonType.name == "button" then

				love.graphics.setNewFont(12)

				 if not (selectedButton == i) then 
				 	love.graphics.setColor(50,50,50)
				-- 	love.graphics.rectangle("fill", buttonArray[i].pos.x-10, buttonArray[i].pos.y, buttonArray[i].size.xsize+10, buttonArray[i].size.ysize+10) 
				 end

				if takeMouseInputsForUI and mouseX > buttonArray[i].pos.x and mouseX < buttonArray[i].pos.x+buttonArray[i].size.xsize and mouseY > buttonArray[i].pos.y and mouseY < buttonArray[i].pos.y+buttonArray[i].size.ysize then
			    	love.graphics.setColor(buttonArray[i].color.r-150, buttonArray[i].color.b-150, buttonArray[i].color.g-150)
			    else
			        love.graphics.setColor(buttonArray[i].color.r, buttonArray[i].color.b, buttonArray[i].color.g)
			    end
			    if selectedButton == i then
				love.graphics.setColor(100,100,100)
			    end
			    love.graphics.draw(button, buttonArray[i].pos.x, buttonArray[i].pos.y)
			    love.graphics.setColor(0, 0, 0)

			    if buttonArray[i].action == "inputText" or buttonArray[i].action == "typing" then
			    	love.graphics.print(buttonArray[i].textData.text, buttonArray[i].pos.x+buttonArray[i].textData.textx+10, buttonArray[i].pos.y+buttonArray[i].textData.texty+10, 0, 3, 3)
			    	love.graphics.setColor(255, 255, 255)
			    	love.graphics.rectangle("fill", buttonArray[i].pos.x+font:getWidth(buttonArray[i].textData.text)*3+10, buttonArray[i].pos.y+5, -font:getWidth(buttonArray[i].textData.text)*3-10+buttonArray[i].size.xsize-5, buttonArray[i].size.ysize-10)
			    else
				    --NOTE : Text centralisation doesn't work amazingly so use textx and texty to get it right vv
				    love.graphics.print(buttonArray[i].textData.text, buttonArray[i].pos.x+buttonArray[i].size.xsize/2-font:getWidth(buttonArray[i].textData.text)*1.5-5+buttonArray[i].textData.textx, buttonArray[i].pos.y+buttonArray[i].size.ysize/2-20+buttonArray[i].textData.texty, 0, buttonArray[i].textData.size, buttonArray[i].textData.size)
				end

			end

			if buttonArray[i].buttonType.name == "rune" then

				love.graphics.setFont(runeFont)

				if selectedButton == i then 
					drawRune(buttonArray[i].pos.x-50,buttonArray[i].pos.y+50,buttonArray[i].buttonType.runeNum,"glowing",buttonArray[i].buttonType.r,buttonArray[i].buttonType.b,buttonArray[i].buttonType.g,buttonArray[i].buttonType.size)
				else
					drawRune(buttonArray[i].pos.x-50,buttonArray[i].pos.y+50,buttonArray[i].buttonType.runeNum,"inactive",buttonArray[i].buttonType.r,buttonArray[i].buttonType.b,buttonArray[i].buttonType.g,buttonArray[i].buttonType.size)
				end

				love.graphics.setColor(0, 0, 0)				
				love.graphics.print(buttonArray[i].textData.text,buttonArray[i].pos.x + 100,buttonArray[i].pos.y+5, 0, buttonArray[i].textData.size, buttonArray[i].textData.size)

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
						background:setFilter("linear","linear")
						love.graphics.setColor(255,255,255)
						love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth()/background:getWidth()/uiscale, love.graphics.getHeight()/background:getHeight()/uiscale)
					end
				end
			end
		end
	end

	if menuPage == 0 then

		drawRune(800,900,5,"inactive",0,0,0,6,-1)
		drawRune(900,100,6,"inactive",0,0,0,4,-0.5)
		drawRune(1600,900,7,"inactive",0,0,0,4,1)
		drawRune(1200,500,8,"inactive",0,0,0,6,1)
		drawRune(1700,50,3,"inactive",0,0,0,8,-0.5)


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

	if menuPage == 2 then menuScrollSpeed = 1 else menuScrollSpeed  = 0.1 end

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

	if generatedSpellbookButtons then
		for i=numMenuButtons+1,numMenuButtons+#allCastableSpells do
			lslui.moveButton(1150,(i-numMenuButtons)*100+50+(spellbookScroll),i)
		end
		lslui.changeButton({pos  = {x = 50,y = 1000},size = {xsize = 240,ysize = 60}, textData = {text = "Back",textx = 3,texty = -5},page = 2,action = 0,joystickActions = {up=16-(spellbookScroll/100),right=16-(spellbookScroll/100),autoButtonSelect = 7}},12)
		if menuPage == 2 and not(selectedButton==12) then selectedButton = 16-(spellbookScroll/100) end
	end

end

function lslui.draw()

	drawScrollingSpellbook()
	drawMenuBackgrounds()
	drawButton()
	drawInputText()

end

function checkForJoystickMovement()

	print(spellbookScroll)

	if buttonScrollBuffer <= 0 then

		if inputs[1].ballyl < 0 then
		   selectedButton = buttonArray[selectedButton].joystickActions.up
		   buttonScrollBuffer = 2
		   	if menuPage == 2 and not(selectedButton==12) and spellbookScroll < 300 then
				spellbookScroll = spellbookScroll + 100
		   	end
		end

		if inputs[1].ballyl > 0 then
			selectedButton = buttonArray[selectedButton].joystickActions.down
			buttonScrollBuffer = 2
			if menuPage == 2 and not(selectedButton==12) and spellbookScroll > -(#allCastableSpells-4)*100 then
				spellbookScroll = spellbookScroll - 100
		   	end
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


	if sticks[1]:isDown(1) and prevXDown == false then
		manageClick(selectedButton)
	end

	if sticks[1]:isDown(1) then  
		prevXDown = true
	end	

	if sticks[1]:isDown(1) == false then 
		prevXDown = false 
	end

	buttonScrollBuffer = buttonScrollBuffer - menuScrollSpeed

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

function drawScrollingSpellbook()

	for i=1,#buttonArray do
		if buttonArray[i].page == menuPage then

			if buttonArray[i].buttonType.name == "spell" then

				if selectedButton == i then
					love.graphics.setColor(100,100,100)
			    else
			    	love.graphics.setColor(255,255,255)
			    end

			    love.graphics.draw(longButton, buttonArray[i].pos.x, buttonArray[i].pos.y)

			    love.graphics.setFont(runeFontSmall)
				love.graphics.setColor(0, 0, 0)
				love.graphics.print(buttonArray[i].textData.text, buttonArray[i].pos.x+50, buttonArray[i].pos.y+10, 0, buttonArray[i].textData.size, buttonArray[i].textData.size)

			end
		end
	end

end

function lslui.loadSpellbookButtons()

	numMenuButtons = #buttonArray

	for i=1,#allCastableSpells do
		lslui.addButton({pos  = {x = 1150,y = i*100+50},size = {xsize = 360,ysize = 100}, textData = {text = allCastableSpells[i][3],textx = 0,texty = 0},page = 2,action = "doNothing",joystickActions = {up = #buttonArray,down = #buttonArray+2,left = 12,right = #buttonArray+1,autoButtonSelect = #buttonArray+1},buttonType={name="spell"}})
	end

	generatedSpellbookButtons = true

end

return lslui