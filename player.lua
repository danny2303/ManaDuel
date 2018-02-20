local player = {}

function player.load()

	playerFront = love.graphics.newImage("images/player/playerFront.png")
	playerBack = love.graphics.newImage("images/player/playerBack.png")
	playerSide = love.graphics.newImage("images/player/playerSide.png")
	playerDead = love.graphics.newImage("images/player/playerDead.png")

	playerFront:setFilter("nearest","nearest")
	playerBack:setFilter("nearest","nearest")
	playerSide:setFilter("nearest","nearest")
	playerDead:setFilter("nearest","nearest")

	maxHealth,maxMana = 20,100
	timeSinceDead = 5

	spellbooks = {{l1 = "dragonsBreath",l2 = "wisp",r1 = "fireball",r2 = "heal",s1 = "lightOrb",s2 = "mirror",s3 = "fireball",s4 = "orbitingSheild"},
				  {l1 = "whirlwind",l2 = "wisp",r1 = "fireball",r2 = "heal",s1 = "timeStop",s2 = "poisonOrb",s3 = "fireball",s4 = "orbitingSheild"}}

	players = {{manaRegen = 0.1, image = playerFront,x=0,y=0,"down",health=maxHealth,mana=maxMana,facingX=0,facingY=1, effects = {}},{manaRegen = 0.1, image = playerFront,x=0,y=0, facing = "down",health=maxHealth,mana=maxMana,facingX=0,facingY=1, effects = {}}}
	playerScale = 0.25
	playerOffsetX,playerOffsetY = playerFront:getWidth()/2*playerScale,playerFront:getHeight()/2*playerScale

	speed = 0.05

	addObject("player1Hitbox",players[1].x,players[1].y,1,2.5,{playerHitbox = true})
	addObject("player2Hitbox",players[2].x,players[2].y,1,2.5,{playerHitbox = true})

end

function player.update(dt)

	movePlayers()
	moveHitboxes()
	castSpells()
	manageStatusEffects(dt)
	regenerateMana()
	checkCurrentTile()
	checkIfDead(dt)

end

function checkCurrentTile()

	for playerNum = 1,2 do
		playerX,playerY = math.floor(players[playerNum].x)+mapLength/2, math.floor(players[playerNum].y)+mapHeight/2
		if map[playerX][playerY].type.name == "harmfull" and not(map[playerX][playerY].type.immunePlayer == playerNum) then
			players[playerNum].health = players[playerNum].health - map[playerX][playerY].type.damage
		end
	end

end

function checkIfDead(dt)

	for i=1,2 do
		if players[i].health <= 0 then
			players[i].image = playerDead
			players[i].mana = 0
			players[i].facing = "front"
			for effectNum=1,#players[i].effects do
				table.remove(players[i].effects,effectNum)
			end
			timeSinceDead = timeSinceDead - dt
			if(timeSinceDead <= 0)then
				newRound = true
			end
		end
	end

end

function player.getPlayersState()
	if(players[1].image == playerDead or players[2].image == playerDead)then return("dead")
	else return("alive") end
end

function regenerateMana()

	for i=1,2 do
		if timeStopped ~= i and players[i].image ~= playerDead then
			players[i].mana = players[i].mana + players[i].manaRegen
		end
	end

end	

function manageStatusEffects(dt)

	for i=1,2 do

		if #players[i].effects > 0 and timeStopped ~= i and players[i].image ~= playerDead then

			for effectNum = #players[i].effects, 1, -1 do

				currentEffect = players[i].effects[effectNum].name
				players[i].effects[effectNum].counter = players[i].effects[effectNum].counter - dt

				if players[i].effects[effectNum].counter < 1 then
					table.remove(players[i].effects,effectNum)
				end

				--applyEffects

				if currentEffect == "burning" then 
					players[i].health = players[i].health - 0.01
				end

				if currentEffect == "poisoned" then 
					players[i].health = players[i].health - 0.05
				end

				if currentEffect == "healing" then
					players[i].health = players[i].health + 0.008
				end

			end

		end

	end

end

function castSpells()

	for i=1,2 do

		if timeStopped == false and players[i].image ~= playerDead then

			if inputs[i].button1.state == true then cast(i,spellbooks[i].s1) end
			if inputs[i].button2.state == true then cast(i,spellbooks[i].s2) end
			if inputs[i].button3.state == true then cast(i,spellbooks[i].s3) end
			if inputs[i].button4.state == true then cast(i,spellbooks[i].s4) end
			if inputs[i].tlshoulder.state == true then cast(i,spellbooks[i].l1) end
			if inputs[i].blshoulder.state == true then cast(i,spellbooks[i].l2) end
			if inputs[i].trshoulder.state == true then cast(i,spellbooks[i].r1) end
			if inputs[i].brshoulder.state == true then cast(i,spellbooks[i].r2) end

		end

	end

end

function moveHitboxes()

	put("player1Hitbox",players[1].x-((playerFront:getWidth()/2*playerScale)/tileSize) ,players[1].y-((playerFront:getHeight()/2*playerScale)/tileSize))
	put("player2Hitbox",players[2].x-((playerFront:getWidth()/2*playerScale)/tileSize),players[2].y-((playerFront:getHeight()/2*playerScale)/tileSize))

end


function player.draw()

	for i=1,2 do

		invisible = false
		mirroredAmount = 0
		mirroredTimer = 0

		if #players[i].effects > 0 then
			for effectNum=1,#players[i].effects do
				if players[i].effects[effectNum].name == "invisibility" then 
					invisible = true 
					invisibilityTimer = players[i].effects[effectNum].counter
				end
				if players[i].effects[effectNum].name == "mirrored" then 
					mirroredAmount = 1
					mirroredTimer = players[i].effects[effectNum].counter
				end
			end
		end

		local amplitude = 20
		local frequency = 2
		local phase = 15

		mirroredSeperation = amplitude*math.sin(frequency*mirroredTimer+phase)

		for j=0,mirroredAmount do

			if not(invisible) then

				love.graphics.setColor(255,255,255,255)

				if players[i].facing == "left" then
					love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX+(playerFront:getWidth()*playerScale-(j*mirroredSeperation)),applyScroll(players[i].y,"y")-playerOffsetY,0,-playerScale,playerScale)
				else
					if players[i].image == playerDead then
						love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale*1.3,playerScale*1.3)
					else
						love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX-(j*mirroredSeperation),applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale,playerScale)
					end
				end

			else

				local amplitude = 127.5
				local frequency = 1
				local phase = 15

				love.graphics.setColor(255,255,255,amplitude*math.sin(frequency*invisibilityTimer+phase))

				if players[i].facing == "left" then
					love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX+(playerFront:getWidth()*playerScale)-(j*mirroredSeperation),applyScroll(players[i].y,"y")-playerOffsetY,0,-playerScale,playerScale)
				else
					if players[i].image == playerDead then
						love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0.5,playerScale,playerScale,players[i].image:getWidth()/2-playerOffsetX,players[i].image:getHeight()/2-playerOffsetY)
					else
						love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-(j*mirroredSeperation)-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale,playerScale)
					end
				end

			end

		end
	end

end

function movePlayers()

	sticks = love.joystick.getJoysticks()

	for i=1,2 do

		if timeStopped ~= i and players[i].image ~= playerDead then

			movementModifier = "none"

			if #players[i].effects > 0 then
				for effectNum=1,#players[i].effects do
					if players[i].effects[effectNum].name == "confused" then movementModifier = "confused" end
					if players[i].effects[effectNum].name == "paralyzed" then movementModifier = "paralyzed" end
				end
			end

			if movementModifier == "none" then

				players[i].facingX = inputs[i].ballxl
				players[i].facingY = inputs[i].ballyl

				if sticks[1]:isDown(10) == false then
					players[i].x = players[i].x + inputs[i].ballxl*speed
					players[i].y = players[i].y + inputs[i].ballyl*speed
				end

				if math.abs(inputs[i].ballxl) > math.abs(inputs[i].ballyl) then
					if inputs[i].ballxl < 0 then
						players[i].image = playerSide
						players[i].facing = "left"
					else
						players[i].image = playerSide
						players[i].facing = "right"
					end
				else
					if inputs[i].ballyl < 0 then
						players[i].image = playerBack
						players[i].facing = "up"
					else
						players[i].image = playerFront
						players[i].facing = "down"
					end
				end
			end

		end

		if movementModifier == "confused" then

			players[i].facingX = -inputs[i].ballxl
			players[i].facingY = -inputs[i].ballyl

			players[i].x = players[i].x - inputs[i].ballxl*speed
			players[i].y = players[i].y - inputs[i].ballyl*speed

			if math.abs(inputs[i].ballxl) > math.abs(inputs[i].ballyl) then
				if inputs[i].ballxl < 0 then
					players[i].image = playerSide
					players[i].facing = "right"
				else
					players[i].image = playerSide
					players[i].facing = "left"
				end
			else
				if inputs[i].ballyl < 0 then
					players[i].image = playerFront
					players[i].facing = "down"
				else
					players[i].image = playerBack
					players[i].facing = "up"
				end
			end

		end

	end

end

return player