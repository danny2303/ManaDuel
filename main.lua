scroll = require "scroll"
player = require "player"
objects = require "objects"
input = require "input"

function love.load()

	love.window.setFullscreen(true)

	scroll.load()
	player.load()
	objects.load()

	input.load()

end

function love.update()

	scroll.update()
	player.update()
	objects.update()

	input.update()

end

function love.draw()

	love.graphics.push()

	love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	love.graphics.scale(zoom)

	scroll.draw()
	player.draw()
	objects.draw()

	love.graphics.pop()

	input.draw()

	love.graphics.line(cameraBoarder,cameraBoarder,cameraBoarder, love.graphics.getHeight() - cameraBoarder)
	love.graphics.line(cameraBoarder,cameraBoarder,love.graphics.getWidth() - cameraBoarder, cameraBoarder)
	love.graphics.line(love.graphics.getWidth() - cameraBoarder, cameraBoarder,love.graphics.getWidth() - cameraBoarder, love.graphics.getHeight() - cameraBoarder)
	love.graphics.line(cameraBoarder, love.graphics.getHeight() - cameraBoarder, love.graphics.getWidth() - cameraBoarder, love.graphics.getHeight() - cameraBoarder)

	love.graphics.line(cameraBuffer, cameraBuffer, love.graphics.getWidth() - cameraBuffer, cameraBuffer)
	love.graphics.line(love.graphics.getWidth() - cameraBuffer, cameraBuffer, love.graphics.getWidth()- cameraBuffer, love.graphics.getHeight() - cameraBuffer)
	love.graphics.line(love.graphics.getWidth()- cameraBuffer, love.graphics.getHeight() - cameraBuffer,cameraBuffer, love.graphics.getHeight() - cameraBuffer)
	love.graphics.line(cameraBuffer, cameraBuffer,cameraBuffer, love.graphics.getHeight() - cameraBuffer)


end