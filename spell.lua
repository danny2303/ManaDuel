local spell = {}

function spell.load()

	timeStopped = false
	timeStoppedTimer = -1

	playerFront = love.graphics.newImage("images/player/playerFront.png")

	fireballImage = love.graphics.newImage("images/projectiles/fireball.png")

	orbitarsImage = love.graphics.newImage("images/projectiles/orbitarsAnimation.png")
	orbitarsImage:setFilter("nearest","nearest")

	--speed = pixels/second

	projectilesIndex = {fireball = {image = fireballImage, width = 0.5, height = 0.5, projectileSpeed = 2, damage = 5, mana = 20, scale= 0.1, collisionMode = "projectile",isOffence = true, effect = "confused",effectDuration = 10,updateCall = "home", updateArgs = {accuracy = 100}},
						timeStop = {width = 0.5, height = 0.5, projectileSpeed = 0, mana = 20, scale= 0.1, collisionMode = "barrier", loadCall = "stopTime", updateCall = "updateTimeStop"},
						wisp = {image = fireballImage, width = 0.5, height = 0.5, projectileSpeed = 1, damage = 5, mana = 20, scale= 0.1, collisionMode = "wisp",isOffence = true, effect = "paralyzed",effectDuration = 5},
						orbitingSheild = {image = orbitarsImage, isAnimation = true, numFrames = 40, playSpeed = 1, frameWidth = 38, frameHeight = 37, width = 3.5, height = 3.5, projectileSpeed = 0, damage = 0, mana = 20, scale= 1, collisionMode = "barrier",isOffence = false},
}

	uniqueProjectileCode = 1

	projectileStack = {}

	toRemove = {}

	multiCastSpells = {}--spellname = true, ...

end

function stopTime(playerNum)

	timeStoppedTimer = 10
	if playerNum == 1 then timeStopped = 2 else timeStopped = 1 end

end

function updateTimeStop(projectileData)

	if timeStoppedTimer < 0 then 
		timeStopped = false
	else
		timeStoppedTimer = timeStoppedTimer - 0.1
	end

end

function home(projectileData,args)

	if args.accuracy then accuracy = args.accuracy else
    	love.errhand("The spell update 'home' requires an 'accuracy' arguement")
	end

	if projectileData.homingTimer then

		projectileData.homingTimer = projectileData.homingTimer - 1

		if projectileData.homingTimer < 0 then

			homingspeed = projectilesIndex[projectileData.projectileIndex].projectileSpeed

			if projectileData.playerNum == 1 then target = 2 else target = 1 end

			xDiff, yDiff = (players[target].x - objects[projectileData.objectIndex].x), (players[target].y - objects[projectileData.objectIndex].y)

			totalDistance = math.sqrt((xDiff^2)+(yDiff^2))

			objects[projectileData.objectIndex].velx = (xDiff/totalDistance)*homingspeed
			objects[projectileData.objectIndex].vely = (yDiff/totalDistance)*homingspeed

			projectileData.homingTimer = (100-accuracy)

		end

	else

		projectileData.homingTimer = 0

	end

end

function removeProjectile(projectileStackIndex)

	toRemove[#toRemove+1] = projectileStackIndex

end

function getAnimationQuad(projectile)

	frameWidth, frameHeight = projectilesIndex[projectile.projectileIndex].frameWidth, projectilesIndex[projectile.projectileIndex].frameHeight
	image = projectilesIndex[projectile.projectileIndex].image

	return love.graphics.newQuad((projectile.animationStage-1)*frameWidth,0,frameWidth,frameHeight,image:getWidth(),image:getHeight())

end

function findStackIndex(objectIndexToFind)

	returnValue = false

	for i=1, #projectileStack do

		if projectileStack[i].objectIndex == objectIndexToFind then

			returnValue = i

		end

	end

	return returnValue

end

function spell.update()

	if #toRemove > 0 then
		for i=#toRemove,1,-1 do

			removeObject(projectileStack[toRemove[i]].objectIndex)
			table.remove(projectileStack,toRemove[i])
			table.remove(toRemove,i)

		end
	end

	manageStack()

end

function spell.draw()

	drawStack()

end

function addEffect(playerNum,effect)

	players[playerNum].effects[#players[playerNum].effects + 1] = {name = effect, count = 0}

end

function launch(playerNum,projectile)

	x,y = players[playerNum].facingX,players[playerNum].facingY

	pspeed = projectilesIndex[projectile].projectileSpeed
	manacost = projectilesIndex[projectile].mana

	if players[playerNum].mana >= manacost then

		addObject(uniqueProjectileCode,players[playerNum].x+players[playerNum].facingX,players[playerNum].y+players[playerNum].facingY,projectilesIndex[projectile].width,projectilesIndex[projectile].height,{projectileIndex = projectile,owner = playerNum}) --todo projectile size - Adds a projectile object - todo multi-shot
		push(uniqueProjectileCode,x*pspeed,y*pspeed)-- provide initial velocity

		players[playerNum].mana = players[playerNum].mana - manacost --dedeuct mana cost

		projectileStack[#projectileStack+1] = {projectileIndex = projectile, objectIndex = uniqueProjectileCode,animationStage = 1, frameTimer = 0, playerNum = playerNum} --adds a new projectile to the stack

		uniqueProjectileCode = uniqueProjectileCode + 1

		if projectilesIndex[projectile].loadCall then
			_G[projectilesIndex[projectile].loadCall](playerNum,projectilesIndex[projectile].loadArgs)
		end

	end

end

function cast(playerNum,spell)

	if not multiCastSpells.spell then
		launch(playerNum,spell)
	else

	end

end

function drawStack()

	if #projectileStack > 0 then

		for i=#projectileStack,1,-1  do

			if projectilesIndex[projectileStack[i].projectileIndex].image then

				x,y = getLocation(projectileStack[i].objectIndex)
				image = projectilesIndex[projectileStack[i].projectileIndex].image
				scale = projectilesIndex[projectileStack[i].projectileIndex].scale
				if projectilesIndex[projectileStack[i].projectileIndex].isAnimation then
					love.graphics.draw(image,getAnimationQuad(projectileStack[i]),applyScroll(x,"x"),applyScroll(y,"y"),0,scale,scale)
				else
					love.graphics.draw(image,applyScroll(x,"x"),applyScroll(y,"y"),0,scale,scale)
				end

			end

		end

	end

end

function updateAnimation(projectile)

	if projectile.frameTimer <= 0 then
		projectile.frameTimer = projectilesIndex[projectile.projectileIndex].playSpeed
		if projectile.animationStage < 40 then
			projectile.animationStage = projectile.animationStage + 1
		else
			projectile.animationStage = 1
		end
	end

	projectile.frameTimer = projectile.frameTimer - 1

	return projectile

end

function manageStack()

	if #projectileStack > 0 then

		for i=#projectileStack,1,-1  do

			updateProjectile(projectileStack[i])

			if timeStopped == false then

				checkForProjectileCollision(projectileStack[i])

				if projectilesIndex[projectileStack[i].projectileIndex].isAnimation then
					projectileStack[i] = updateAnimation(projectileStack[i])
				end

			end

		end

	end

end

function manageCollision(subjectData,objectsList) --subjectData = the subject's projectile data, objects = the list of object IDs of what was hit

	subject = projectilesIndex[subjectData.projectileIndex]

	if subject.collisionCall then
		_G[subject.collisionCall](subject,objectsList,subject.collisionArgs)
	end

	--Then do standard collision stuff

		--barrier, projectile, wisp interaction

		subjectCollisionMode = subject.collisionMode

		for i=1, #objectsList do

			if objects[objectsList[i]].projectileIndex then

				objectCollisionMode = projectilesIndex[objects[objectsList[i]].projectileIndex].collisionMode
				
				result = calculateProjectileHit(subjectCollisionMode,objectCollisionMode)

				subjectObjectId = findStackIndex(subjectData.objectIndex)
				objectObjectId = findStackIndex(objectsList[i])

				if not (subjectObjectId == false) then
					if result[1] == true then removeProjectile(subjectObjectId) end
				end
				if not (objectObjectId == false) then
					if result[2] == true then removeProjectile(objectObjectId) end
				end

			end

		end



		--damage stuff

		for i=1, #objectsList do

			if (objectsList[i] == "player1Hitbox") or (objectsList[i] == "player2Hitbox") then

				if projectilesIndex[subjectData.projectileIndex].isOffence then

					if objectsList[i] == "player1Hitbox" and objects[subjectData.objectIndex].owner == 2 then 
						players[1].health = players[1].health - projectilesIndex[subjectData.projectileIndex].damage
						removeProjectile(findStackIndex(subjectData.objectIndex))
					end

					if objectsList[i] == "player2Hitbox" and objects[subjectData.objectIndex].owner == 1 then 
						players[2].health = players[2].health - projectilesIndex[subjectData.projectileIndex].damage 
						removeProjectile(findStackIndex(subjectData.objectIndex))
					end


				end

			end

		end

		--effect stuff

		for i=1, #objectsList do

			if objectsList[i] == "player1Hitbox" or objectsList[i] == "player2Hitbox" then

				playerNumHit = "objectHitWasntAPlayer"

				if objectsList[i] == "player1Hitbox" then playerNumHit = 1 end
				if objectsList[i] == "player2Hitbox" then playerNumHit = 2 end

				if projectilesIndex[subjectData.projectileIndex].effect and not(subjectData.playerNum == playerNumHit) then

					alreadyActive = false
					indexOfAlreadyActiveEffect = "noIndexFound"

					if #players[playerNumHit].effects > 0 then

						for i =1, #players[playerNumHit].effects do

							if players[playerNumHit].effects[i].name == projectilesIndex[subjectData.projectileIndex].effect then
								alreadyActive = true
								indexOfAlreadyActiveEffect = i
							end

						end

					end

					if alreadyActive == false then players[playerNumHit].effects[#players[playerNumHit].effects+1] = {name = projectilesIndex[subjectData.projectileIndex].effect, counter = projectilesIndex[subjectData.projectileIndex].effectDuration} end
					if alreadyActive == true then players[playerNumHit].effects[indexOfAlreadyActiveEffect].counter = projectilesIndex[subjectData.projectileIndex].effectDuration end

				end

			end

		end

end

function updateProjectile(projectileData)

	subject = projectilesIndex[projectileData.projectileIndex]

	if subject.updateCall then
		_G[subject.updateCall](projectileData,subject.updateArgs)
	end

	--Then do standard update stuff

end

function checkForProjectileCollision(projectileData)

	result = checkForCollision({subject = projectileData.objectIndex})

	projectileAboutToBeRemoved = false

	if #toRemove > 0 then
		for i=1,#toRemove do

			if toRemove[i] == projectileData.objectIndex then 
				projectileAboutToBeRemoved = true 
			end

		end
	end

	if result[1] and not(projectileAboutToBeRemoved) then 
		manageCollision(projectileData,result[2])
	end

end

function calculateProjectileHit(subject, object)

	subjectReturn, objectReturn = false,false

	if subject == "barrier" and (object == "wisp" or object == "projectile") then
		objectReturn = true
	end

	if object == "barrier" and (subject == "wisp" or subject == "projectile") then
		subjectReturn = true
	end

	if object == "wisp" then
		objectReturn = true
	end

	if subject == "wisp" then
		subjectReturn = true
	end

	return {subjectReturn,objectReturn}

end

return spell