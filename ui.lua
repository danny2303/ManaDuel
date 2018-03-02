local ui = {}

function ui.load()

	clickBuffer = 0
	newplayername = ""

	characterButtonNames = {"New","Load","Import","Export"}

	love.keyboard.setTextInput(true)

	barPadding = 100
	barDistance = 1200
	healthLength = 15
	manaLength = 5

	effectFont = love.graphics.newFont("images/ui/effectFont.ttf", 16)

	timerImage = love.graphics.newImage("images/ui/timer.png")
	timerImage:setFilter("linear","linear")

	fireIcon = love.graphics.newImage("images/ui/fireIcon.png")
	fireIcon:setFilter("nearest","nearest")

	poisonIcon = love.graphics.newImage("images/ui/poisonIcon.png")
	poisonIcon:setFilter("nearest","nearest")

	paralyzedIcon = love.graphics.newImage("images/ui/paralyzedIcon.png")
	paralyzedIcon:setFilter("nearest","nearest")

	confusedIcon = love.graphics.newImage("images/ui/confusedIcon.png")
	confusedIcon:setFilter("nearest","nearest")

	healingIcon = love.graphics.newImage("images/ui/healingIcon.png")
	healingIcon:setFilter("nearest","nearest")

	invisibleIcon = love.graphics.newImage("images/ui/invisibleIcon.png")
	invisibleIcon:setFilter("nearest","nearest")

	mirroredIcon = love.graphics.newImage("images/ui/mirroredIcon.png")
	mirroredIcon:setFilter("nearest","nearest")

	effectImages = {mirrored = mirroredIcon, burning = fireIcon, poisoned = poisonIcon, paralyzed = paralyzedIcon, confused = confusedIcon, healing = healingIcon, invisibility = invisibleIcon}

end

function ui.update()

	clickBuffer = clickBuffer - 1
	if clickBuffer < 0 then clickBuffer = 0 end

	upholdBarLimits()
	if inGame and menuPage == 3 then
		characterMenu()
	end

end

function ui.draw()

	if inGame then

	love.graphics.setFont(effectFont)

	drawUI()
	drawStatusEffects()

	elseif menuPage == 3 then
		drawCharacterMenu()
	end

end

function love.mousepressed( x, y, button)

	if clickBuffer == 0 then

		clickBuffer = 10

		if button == 1 then

			if not(isDrawingPopupWindow) then
				for i=1,4 do
					if x > 700 and x < 1000 and y > i*200 and y < i*200+100 then
						if i == 1 then
							isDrawingPopupWindow = true
							popupArgs = {message = "Type the name of your new character:", selected = false, isTextInput = true, phase = "newCharacter"}
							inputText = ""
						end
						if i == 2 then
							isDrawingPopupWindow = true
							popupArgs = {message = "Type the name of the character you wish to load:", selected = false, isTextInput = true, phase = "loadCharacter1"}
							inputText = ""
						end
					end
				end
			end

			if x > 850 and x < 950 and y > 765 and y < 865 and isDrawingPopupWindow then
				isDrawingPopupWindow = false
				if popupArgs.phase == "newCharacter" then
					--make a new character
				end
				if popupArgs.phase == "loadCharacter1" then
					newplayername = inputText
					isDrawingPopupWindow = true
					popupArgs = {message = "Type either '1' or '2' - this is the player number you wish " .. newplayername .. " to play as:", selected = false, isTextInput = true, phase = "loadCharacter2"}
					inputText = ""
				elseif popupArgs.phase == "loadCharacter2" and not(inputText == "1" or inputText == "2") then
					isDrawingPopupWindow = true
					popupArgs = {message = "Type either '1' or '2' - this is the player number you wish " .. newplayername .. " to play as:", selected = false, isTextInput = true, phase = "loadCharacter2"}
					inputText = ""
				elseif popupArgs.phase == "loadCharacter2" and (inputText == "1" or inputText == "2") then
					--set this character to that player num
				end
			end

		end

	end

end

function characterMenu()



end

function drawCharacterMenu()

	love.graphics.setFont(digitalFont)
	love.graphics.setColor(255,255,255)
	love.graphics.print("You must use the computer to change characters:",450,0,0,0.5,0.5)
	--new change import export
	--drawPopupWindow("Important messsage ", false, true)

	if not(isDrawingPopupWindow) then
		for i=1,4 do
			mx,my = love.mouse.getX(),love.mouse.getY()
			love.graphics.setColor(255,255,255)
			if mx > 700 and mx < 1000 and my > i*200 and my < i*200+100 then
				love.graphics.setColor(50,50,50)
			end
			love.graphics.rectangle("fill",700,i*200,300,100)

			love.graphics.setColor(0,0,0)
			love.graphics.printf(characterButtonNames[i],700,i*200 + 10,300,"center")
		end
	end

	if isDrawingPopupWindow then drawPopupWindow(popupArgs) end

end

function drawPopupWindow(args)

	message = args.message
	selected = args.selected
	isTextInput = args.isTextInput

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill",400,300,25,500)
	love.graphics.rectangle("fill",1400,300,25,525)
	love.graphics.rectangle("fill",400,800,1000,25)
	love.graphics.rectangle("fill",400,300,1000,25)

	love.graphics.setColor(1, 51, 2)
	love.graphics.rectangle("fill",425,325,975,475)

	if selected then love.graphics.setColor(100,100,100) else love.graphics.setColor(255,255,255) end
	love.graphics.rectangle("fill",850,765,100,100)

	love.graphics.setFont(digitalFont)
	love.graphics.setColor(0,0,0)
	love.graphics.printf(message,425,350,1400,"center",0,0.7,0.7)
	love.graphics.print("OK",865,775,0,0.9,0.9)

	love.graphics.setColor(255,255,255)
	if isTextInput then love.graphics.print(inputText, 500, 600) end

end

function drawUI()

	for i=1, 2 do

		health,mana = players[i].health*healthLength,players[i].mana*manaLength

		love.graphics.setColor(172,173,196,200)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),50,maxHealth*healthLength,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*maxHealth*healthLength),60,10) end
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),100,maxMana*manaLength,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*maxMana*manaLength ),110,10) end

		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),50,health,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*health),60,10) end

		love.graphics.setColor(47, 54, 216)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),100,mana,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*mana ),110,10) end

		love.graphics.setColor(0,0,0)
		love.graphics.print("Health: "..round(players[i].health,1),(i*barDistance-(barDistance-barPadding)),53)
		love.graphics.print("Mana: "..round(players[i].mana,0),(i*barDistance-(barDistance-barPadding)),103)


	end

end

function upholdBarLimits()

	for i=1,2 do

		if players[i].health < 0 then players[i].health = 0 end
		if players[i].mana < 0 then players[i].mana = 0 end

		if players[i].health > maxHealth then players[i].health = maxHealth end
		if players[i].mana > maxMana then players[i].mana = maxMana end

	end

end

function drawStatusEffects()

	for i=1, 2 do

		if #players[i].effects > 0 then

			for effectNum =1,#players[i].effects do

				love.graphics.setColor(255,255,255)
				love.graphics.draw(effectImages[players[i].effects[effectNum].name],effectNum*100+(i*barDistance-(barDistance-barPadding)-50),150,0,0.2,0.2)
				love.graphics.printf(round(players[i].effects[effectNum].counter,0),effectNum*100+(i*barDistance-(barDistance-barPadding)-68),218,100,'center')
				love.graphics.draw(timerImage,effectNum*100+(i*barDistance-(barDistance-barPadding)-45),213,0.4,0.4)

			end

		end

	end

end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return ui