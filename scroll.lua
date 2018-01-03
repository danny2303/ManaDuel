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

	showZoomBoarders = false

	toPanTo = {}
	panBuffer = 100

	minZoom,maxZoom = 1,20

	cameraBoarderX,cameraBoarderY = 100,100
	cameraBufferX,cameraBufferY = 600,450

	zoomInProgress = false
	zoomMode = "in"
	zoomDuration = 100
	defaultZoomSpeed = 1
	zoomSpeed = 1
	zoomTimer = 0

	tilemap = love.graphics.newImage("images/tilemap.png")
	tileSize = 10

	tilemap:setFilter("nearest","nearest")

	mapLength,mapHeight = 100,100
	zoom = 5
	cameraX,cameraY = -20,-20

	voidColor = {red=0,blue=0,green=0}

	setupMap()

end

function scroll.update()

	zoomSpeed = defaultZoomSpeed/(zoom*2)

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
			map[x][y] = createTiledata(math.random(0,2),0)
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

			love.graphics.draw(tilemap,map[x][y].quad,applyScroll(x,"x")-500,applyScroll(y,"y")-500,0,1,1)

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

		combinedPlayerPos = {lowest(applyScroll(players[1].x,"x"),applyScroll(players[2].x,"x"))+((highest(applyScroll(players[1].x,"x"),applyScroll(players[2].x,"x"))-lowest(applyScroll(players[1].x,"x"),applyScroll(players[2].x,"x")))/2),
							lowest(applyScroll(players[1].y,"y"),applyScroll(players[2].y,"y"))+((highest(applyScroll(players[1].y,"y"),applyScroll(players[2].y,"y"))-lowest(applyScroll(players[1].y,"y"),applyScroll(players[2].y,"y")))/2)}


		if p1x < cameraBoarderX or p1x > love.graphics.getWidth() - cameraBoarderX or p1y < cameraBoarderY or p1y >  love.graphics.getHeight() - cameraBoarderY or p2x < cameraBoarderX or p2x > love.graphics.getWidth() - cameraBoarderX or p2y < cameraBoarderY or p2y >  love.graphics.getHeight() - cameraBoarderY then--if it needs to zoom out

			zoomInProgress = true
			zoomMode = "out"

		end

		if p1x < love.graphics.getWidth() - cameraBufferX and p1x > cameraBufferX and p1y < love.graphics.getHeight() - cameraBufferY and p1y > cameraBufferY and p2x < love.graphics.getWidth() - cameraBufferX and p2x > cameraBufferX and p2y < love.graphics.getHeight() - cameraBufferY and p2y > cameraBufferY then

			zoomInProgress = true
			zoomMode = "in"

		end

	end

	toPanTo[#toPanTo+1] = combinedPlayerPos

	if #toPanTo > panBuffer then --WIP

		--cameraX = toPanTo[1][1]
		--cameraY = toPanTo[1][2]
		table.remove(toPanTo,1)

	end

end

function smoothZoom()

	if zoomInProgress then

		if zoomTimer < zoomDuration then

			if zoomMode == "in" and zoom < maxZoom-zoomSpeed then

				zoom = zoom + zoomSpeed

			end

			if zoomMode == "out" and zoom > minZoom+zoomSpeed then

				zoom = zoom - zoomSpeed

			end

			zoomTimer = zoomTimer + 1

		else

			zoomInProgress = false
			zoomTimer = 0

		end

	end

end

function lowest(a,b)
	if a < b then return a else return b end
end

function highest(a,b)
	if a > b then return a else return b end
end

return scroll