local player = {}

function player.load()

	playerFront = love.graphics.newImage("images/player/playerFront.png")
	playerBack = love.graphics.newImage("images/player/playerBack.png")
	playerSide = love.graphics.newImage("images/player/playerSide.png")

	playerFront:setFilter("nearest","nearest")
	playerBack:setFilter("nearest","nearest")
	playerSide:setFilter("nearest","nearest")

	maxHealth,maxMana = 20,100

	players = {{image = playerFront,x=0,y=0,"down",health=maxHealth,mana=maxMana},{image = playerFront,x=0,y=0, facing = "down",health=maxHealth,mana=maxMana}}
	playerScale = 0.25
	playerOffsetX,playerOffsetY = playerFront:getWidth()/2*playerScale,playerFront:getHeight()/2*playerScale

	speed = 0.05

	addObject("player1Hitbox",players[1].x,players[1].y,1,2.5,{playerHitbox = true})
	addObject("player2Hitbox",players[2].x,players[2].y,1,2.5,{playerHitbox = true})

end

function player.update()

	movePlayers()

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

return player