local player = {}

function player.load()

	player = love.graphics.newImage("images/player.png")
	player:setFilter("nearest","nearest")
	players = {{image = player,x=0,y=0},{image = player,x=0,y=0}}

end

function player.update()

	for i=1,2 do	

		players[i].x = players[i].x + inputs[i].ballxl*0.01
		players[i].y = players[i].y + inputs[i].ballyl*0.01

	end

end

function player.draw()

	for i=1,2 do

		love.graphics.draw(players[i].image,applyScroll(players[i].x,"x"),applyScroll(players[i].y,"y"),0,0.25,0.25)

	end

end

return player