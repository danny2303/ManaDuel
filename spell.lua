local spell = {}

function spell.load()

	fireballImage = love.graphics.newImage("images/projectiles/fireball.png")

	projectilesIndex = {fireball = {image = fireballImage, projectileSpeed = 0.01, damage = 5, mana = 20, scale= 0.1}}

	uniqueProjectileCode = 1

	projectileStack = {}

end

function spell.update()

	manageStack()

end

function spell.draw()

	drawStack()

end

function cast(playerNum,projectile,x,y)

	pspeed = projectilesIndex[projectile].projectileSpeed
	manacost = projectilesIndex[projectile].mana

	addObject(uniqueProjectileCode,players[playerNum].x,players[playerNum].y,1,1,{projectileIndex = projectile}) --todo projectile size - Adds a projectile object - todo multi-shot
	push(uniqueProjectileCode,x*pspeed,y*pspeed)-- provide initial velocity

	players[playerNum].mana = players[playerNum].mana - manacost --dedeuct mana cost

	projectileStack[#projectileStack+1] = {projectileIndex = projectile, objectIndex = uniqueProjectileCode} --adds a new projectile to the stack

	uniqueProjectileCode = uniqueProjectileCode + 1

end

function drawStack()

	if #projectileStack > 0 then

		for i=1, #projectileStack do

			x,y = getLocation(projectileStack[i].objectIndex)
			image = projectilesIndex[projectileStack[i].projectileIndex].image
			scale = projectilesIndex[projectileStack[i].projectileIndex].scale

			love.graphics.draw(image,applyScroll(x,"x"),applyScroll(y,"y"),0,scale,scale)

		end

	end

end

function manageStack()

	if #projectileStack > 0 then

		for i=1, #projectileStack do

			if needsRemoving(projectileStack[i]) then
				table.remove(projectileStack,i)
			end

			result = checkForProjectileCollision(projectileStack[i])
			if result[1] then
				manageCollision(projectilesIndex[projectileStack[i].projectileIndex],result[2])
			end

		end

	end

end

function manageCollision(subject,object)

	if object.projectileIndex then

		print("hi")


	else


	end

end

function needsRemoving(projectileData)

	return false

end

function checkForProjectileCollision(projectileData)

	result = checkForCollision({subject = projectileData.objectIndex})

	return result

end

return spell