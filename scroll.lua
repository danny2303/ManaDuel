local scroll = {}

function scroll.setTile(x,y,tiledata)

	if not(x<1 or x>mapLength) and not(y<1 or y>mapHeight) then
		map[x][y] = tiledata
	end

end	

function love.wheelmoved(x, y)

	    if y > 0 then
	        zoom = zoom + 0.1
	    elseif y < 0 then
	        zoom = zoom - 0.1
	 	end

end

function scroll.load()

	cameraBoarder = 200
	cameraBuffer = 500

	zoomInProgress = false
	zoomMode = "in"
	zoomDuration = 100
	defaultZoomSpeed = 3
	zoomSpeed = 1
	zoomTimer = 0

	tilemap = love.graphics.newImage("images/tilemap.png")
	tileSize = 10

	mapLength, mapHeight = 10, 10

	tilemap:setFilter("nearest","nearest")

	mapLength,mapHeight = 10,10
	zoom = 50
	cameraX,cameraY = -20,-20

	voidColor = {red=0,blue=0,green=0}

	setupMap()

end

function scroll.update()

	zoomSpeed = defaultZoomSpeed/zoom

	panCamera()
	smoothZoom()

end

function scroll.draw()

	drawTiles()

end

function setupMap()

	map = {}

	for x = 1,mapLength do
		map[x] = {}
		for y = 1,mapHeight do
			map[x][y] = createTiledata(0,0)
		end
	end

end

function createTiledata(x,y)

	local quad = love.graphics.newQuad(x*tileSize,y*tileSize,tileSize,tileSize,tilemap:getWidth(),tilemap:getHeight())

	return {quad=quad}

end


function drawTiles()

	love.graphics.setBackgroundColor(voidColor.red,voidColor.blue,voidColor.green)

	for x=1,mapLength do
		for y=1, mapHeight do

			love.graphics.setColor(255,255,255)

			love.graphics.draw(tilemap,map[x][y].quad,applyScroll(x,"x"),applyScroll(y,"y"),0,1,1)

		end
	end

end

function applyScroll(num,axis) --num is x position in tiles
	
	if axis == "x" then 
		camera = cameraX
	elseif axis == "y" then 
		camera = cameraY 
	else 
		print("Arguement 2 for applyScroll() must be \"x\" or \"y\"")
	end

	return num*tileSize+camera

end

function panCamera()

	if not zoomInProgress then

		p1x,p2x = (applyScroll(players[1].x,"x")*zoom)+love.graphics.getWidth()/2, (applyScroll(players[2].x,"x")*zoom)+love.graphics.getWidth()/2
		p1y,p2y = (applyScroll(players[1].y,"y")*zoom)+love.graphics.getHeight()/2, (applyScroll(players[2].y,"y")*zoom)+love.graphics.getHeight()/2

		xDifference = math.abs(p1x-p2x)
		yDifference = math.abs(p1y-p2y)


		if p1x < cameraBoarder or p1x > love.graphics.getWidth() - cameraBoarder or p1y < cameraBoarder or p1y >  love.graphics.getHeight() - cameraBoarder or p2x < cameraBoarder or p2x > love.graphics.getWidth() - cameraBoarder or p2y < cameraBoarder or p2y >  love.graphics.getHeight() - cameraBoarder then--if it needs to zoom out

			zoomInProgress = true
			zoomMode = "out"

		end

		if p1x < love.graphics.getWidth() - cameraBuffer and p1x > cameraBuffer and p1y < love.graphics.getHeight() - cameraBuffer and p1y > cameraBuffer and p2x < love.graphics.getWidth() - cameraBuffer and p2x > cameraBuffer and p2y < love.graphics.getHeight() - cameraBuffer and p2y > cameraBuffer then

			zoomInProgress = true
			zoomMode = "in"

		end

	end

end

function smoothZoom()

	if zoomInProgress then

		if zoomTimer < zoomDuration then

			if zoomMode == "in" then

				zoom = zoom + zoomSpeed

			end

			if zoomMode == "out" then

				zoom = zoom - zoomSpeed

			end

			zoomTimer = zoomTimer + 1

		else

			zoomInProgress = false
			zoomTimer = 0

		end

	end

end

return scroll