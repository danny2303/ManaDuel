local player = {}

function player.load()

	playerFront = love.graphics.newImage("images/player/playerFront.png")
	playerBack = love.graphics.newImage("images/player/playerBack.png")
	playerSide = love.graphics.newImage("images/player/playerSide.png")

	playerFront:setFilter("nearest","nearest")
	playerBack:setFilter("nearest","nearest")
	playerSide:setFilter("nearest","nearest")

	maxHealth,maxMana = 20,100

	spellbooks = {{l1 = "dragonsBreath",l2 = "wisp",r1 = "fireball",r2 = "wisp",s1 = "timeStop",s2 = "poisonOrb",s3 = "fireball",s4 = "orbitingSheild"},
				  {l1 = "orbitingSheild",l2 = "wisp",r1 = "fireball",r2 = "wisp",s1 = "timeStop",s2 = "poisonOrb",s3 = "fireball",s4 = "orbitingSheild"}}

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

end

function regenerateMana()

	for i=1,2 do

		players[i].mana = players[i].mana + players[i].manaRegen

	end

end	

function manageStatusEffects(dt)

	for i=1,2 do

		if #players[i].effects > 0 then

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

		if timeStopped == false then

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

		if players[i].facing == "left" then
			love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX+(playerFront:getWidth()*playerScale),applyScroll(players[i].y,"y")-playerOffsetY,0,-playerScale,playerScale)
		else
			love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale,playerScale)
		end

	end


end

function movePlayers()

	for i=1,2 do

		if not(timeStopped == i) then

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

				players[i].x = players[i].x + inputs[i].ballxl*speed
				players[i].y = players[i].y + inputs[i].ballyl*speed

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