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

end