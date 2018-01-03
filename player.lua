local player = {}

function player.load()

	player = love.graphics.newImage("images/player.png")
	player:setFilter("nearest","nearest")
	players = {{image = player,x=0,y=0},{image = player,x=0,y=0}}
	playerScale = 0.25
	playerOffsetX,playerOffsetY = player:getWidth()/2*playerScale,player:getHeight()/2*playerScale

	speed = 1

end

function player.update()

	for i=1,2 do	

		players[i].x = players[i].x + inputs[i].ballxl*speed/(zoom*5)
		players[i].y = players[i].y + inputs[i].ballyl*speed/(zoom*5)

	end

end

function player.draw()

	for i=1,2 do

		love.graphics.draw(players[i].image,applyScroll(players[i].x,"x")-playerOffsetX,applyScroll(players[i].y,"y")-playerOffsetY,0,playerScale,playerScale)

	end

end

return player