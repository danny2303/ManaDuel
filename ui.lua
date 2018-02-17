local ui = {}

function ui.load()

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

	upholdBarLimits()

end

function ui.draw()

	love.graphics.setFont(effectFont)

	drawUI()
	drawStatusEffects()

	if players[1].effects[1] then
		if players[1].effects[1].name == "test" then
			--love.graphics.circle("fill",500,500,500,500,500)
		end
	end

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