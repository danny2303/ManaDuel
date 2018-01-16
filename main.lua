scroll = require "scroll"
player = require "player"
object = require "object"
input = require "input"
ui = require "ui"
spell = require "spell"

function love.load()

	love.window.setFullscreen(true)

	scroll.load()
	spell.load()
	object.load()
	player.load()

	input.load()
	ui.load()

end

function love.update(dt)

	scroll.update()
	player.update(dt)
	object.update(dt)
	spell.update()

	input.update()
	ui.update()

end

function love.draw()


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

	player.draw()
	object.draw()
	spell.draw()

	love.graphics.pop()



	input.draw()
	ui.draw()   


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