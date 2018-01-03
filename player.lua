local player = {}

function player.load()

	playerFront = love.graphics.newImage("images/player/playerFront.png")
	playerBack = love.graphics.newImage("images/player/playerBack.png")
	playerSide = love.graphics.newImage("images/player/playerSide.png")

	playerFront:setFilter("nearest","nearest")
	playerBack:setFilter("nearest","nearest")
	playerSide:setFilter("nearest","nearest")

	players = {{image = playerFront,x=0,y=0,"down"},{image = playerFront,x=0,y=0, facing = "down"}}
	playerScale = 0.25
	playerOffsetX,playerOffsetY = playerFront:getWidth()/2*playerScale,playerFront:getHeight()/2*playerScale

	speed = 1

	addObject("ball",1,1,3,1)
	addObject("barrier",1,5,1,1)
	push("ball",0,0.01)

end

function player.update()

	movePlayers()

	if checkForCollision("ball")[1] == true then
		setObject("ball",{x=1,y=1,width=1,height=1,active=false})
	end

end

function player.draw()

	for i=1,2 do

		if players[i].facing == "left" then
			love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX+(playerFront:getWidth()*playerScale),applyScroll(players[i].y,"y")-playerOffsetY,0,-playerScale,playerScale)
		else
			love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale,playerScale)
		end

	end

	x,y = getLocation("ball")
	--love.graphics.circle("fill",applyScroll(x,"x"),applyScroll(y,"y"),1)
	drawObject("barrier")
	drawObject("ball")


end

function movePlayers()

	for i=1,2 do	

		players[i].x = players[i].x + inputs[i].ballxl*speed/(zoom*5)
		players[i].y = players[i].y + inputs[i].ballyl*speed/(zoom*5)

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