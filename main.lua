scroll = require "scroll"
player = require "player"
object = require "object"
input = require "input"
ui = require "ui"
spell = require "spell"
lslui = require "lslui"

function love.load()

	inGame = false

	love.window.setFullscreen(true)

	scroll.load()
	spell.load()
	object.load()
	player.load()

	input.load()
	ui.load()
	lslui.load()

	lslui.addButton(170,180,240,60,255,255,255,"Play",0,0,0,"run")
	lslui.addButton(170,290,240,60,255,255,255,"Options",0,0,0,1)
	lslui.addButton(170,510,240,60,255,255,255,"Exit",0,0,0,"exit")

	lslui.addButton(170,180,280,60,255,255,255,"Volume:100",0,0,1,1)
	lslui.addButton(170,290,280,60,255,255,255,"Fullscreen",0,0,1,"fullscreen")
	lslui.addButton(170,400,240,60,255,255,255,"Back",0,0,1,0)

	lslui.addButton(love.graphics.getWidth()/2-160,love.graphics.getHeight()/2-230,220,60,255,255,255,"Resume",5,0,"gameMenu1","run")
	lslui.addButton(love.graphics.getWidth()/2-190,love.graphics.getHeight()/2-30,280,60,255,255,255,"Back to menu",5,0,"gameMenu1",0)
	lslui.addButton(love.graphics.getWidth()/2-160,love.graphics.getHeight()/2+170,220,60,255,255,255,"Exit",2,0,"gameMenu1","exit")

	lslui.setMenuBackground({page = {0,1},image = "images/backgroundPicture.png"})

end

function love.update(dt)

	if(inGame == true and lslui.getPage() ~= "gameMenu1")then
		scroll.update()
		player.update(dt)
		object.update(dt)
		spell.update()
		input.update()
		ui.update()
	end

	lslui.update()

	lslui.inGameMenu("start","gameMenu1")

	lslui.replaceButton(love.graphics.getWidth()/2-160,love.graphics.getHeight()/2-230,220,60,255,255,255,"Resume",5,0,"gameMenu1","run",8)
	lslui.replaceButton(love.graphics.getWidth()/2-190,love.graphics.getHeight()/2-30,280,60,255,255,255,"Back to menu",5,0,"gameMenu1",0,9)
	lslui.replaceButton(love.graphics.getWidth()/2-160,love.graphics.getHeight()/2+170,220,60,255,255,255,"Exit",2,0,"gameMenu1","exit",10)

end

function love.draw()

	if(inGame == true)then
		love.graphics.push()

		love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
		love.graphics.scale(zoom)

		scroll.draw()

		love.graphics.pop()

		love.graphics.push()

		love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)

		love.graphics.setColor(255,255,255)
		for i=1,2 do
			love.graphics.line(applyScroll(players[i].x+players[i].facingX,"x")*zoom,applyScroll(players[i].y+players[i].facingY,"y")*zoom,applyScroll(players[i].x+players[i].facingX*2,"x")*zoom,applyScroll(players[i].y+players[i].facingY*2,"y")*zoom)
		end

		love.graphics.pop()

		love.graphics.push()

		love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
		love.graphics.scale(zoom)

		--draw back stack

		if #projectileStack > 0 then

			for i=#projectileStack,1,-1  do
				if (not projectileStack[i].removed)then

					if projectilesIndex[projectileStack[i].projectileIndex].image and projectilesIndex[projectileStack[i].projectileIndex].layer == "back" then

						x,y = getLocation(projectileStack[i].objectIndex)
						image = projectilesIndex[projectileStack[i].projectileIndex].image
						scale = projectilesIndex[projectileStack[i].projectileIndex].scale
						if projectilesIndex[projectileStack[i].projectileIndex].isAnimation then
							love.graphics.draw(image,getAnimationQuad(projectileStack[i]),applyScroll(x,"x"),applyScroll(y,"y"),0,scale,scale)
						else
							love.graphics.draw(image,applyScroll(x,"x"),applyScroll(y,"y"),projectileStack[i].rotation,scale,scale,image:getWidth()/2,image:getHeight()/2)
						end

					end
				end

			end

		end

		player.draw()
		object.draw()
		spell.draw()

		love.graphics.pop()

		input.draw()
		ui.draw()
	end

	lslui.draw()

	if showZoomBoarders then
		love.graphics.line(cameraBoarderX,cameraBoarderY,cameraBoarderX, love.graphics.getHeight() - cameraBoarderY)
		love.graphics.line(cameraBoarderX,cameraBoarderY,love.graphics.getWidth() - cameraBoarderX, cameraBoarderY)
		love.graphics.line(love.graphics.getWidth() - cameraBoarderX, cameraBoarderY,love.graphics.getWidth() - cameraBoarderX, love.graphics.getHeight() - cameraBoarderY)
		love.graphics.line(cameraBoarderX, love.graphics.getHeight() - cameraBoarderY, love.graphics.getWidth() - cameraBoarderX, love.graphics.getHeight() - cameraBoarderY)

		love.graphics.line(cameraBufferX, cameraBufferY, love.graphics.getWidth() - cameraBufferX, cameraBufferY)
		love.graphics.line(love.graphics.getWidth() - cameraBufferX, cameraBufferY, love.graphics.getWidth()- cameraBufferX, love.graphics.getHeight() - cameraBufferY)
		love.graphics.line(love.graphics.getWidth()- cameraBufferX, love.graphics.getHeight() - cameraBufferY,cameraBufferX, love.graphics.getHeight() - cameraBufferY)
		love.graphics.line(cameraBufferX, cameraBufferY,cameraBufferX, love.graphics.getHeight() - cameraBufferY)
	end

end