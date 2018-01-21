local spell = {}

function spell.load()

	timeStopped = false
	timeStoppedTimer = -1

	playerFront = love.graphics.newImage("images/player/playerFront.png")

	fireballImage = love.graphics.newImage("images/projectiles/fireball.png")
	poisonOrbImage = love.graphics.newImage("images/projectiles/poison.png")
	orbitarsImage = love.graphics.newImage("images/projectiles/orbitarsAnimation.png")
	whirlwindImage = love.graphics.newImage("images/projectiles/whirlwindAnimation.png")

	orbitarsImage:setFilter("nearest","nearest")
	poisonOrbImage:setFilter("nearest","nearest")
	fireballImage:setFilter("nearest","nearest")
	orbitarsImage:setFilter("nearest","nearest")
	whirlwindImage:setFilter("nearest","nearest")


	--speed = pixels/second
	--rotationSpeed = radians/tick/10

	projectilesIndex = {fireball = {layer = "front", lifetime = 40, rotationSpeed = 1,image = fireballImage, width = 0.5, height = 0.5, projectileSpeed = 2, damage = 5, mana = 20, scale= 0.1, collisionMode = "projectile",isOffence = true, effect = "confused",effectDuration = 10,updateCall = "home", updateArgs = {accuracy = 100}},
						timeStop = {width = 0.5, height = 0.5, projectileSpeed = 0, mana = 100, scale= 0.1, collisionMode = "barrier", loadCall = "stopTime", updateCall = "updateTimeStop"},
						wisp = {layer = "front",lifetime  = 40, image = fireballImage, width = 0.4, height = 0.5, projectileSpeed = 1, damage = 5, mana = 5, scale= 0.1, collisionMode = "wisp",isOffence = true, effect = "paralyzed",effectDuration = 15},
						orbitingSheild = {layer = "back",lifetime  = 40,image = orbitarsImage, isAnimation = true, numFrames = 40, playSpeed = 10, frameWidth = 35, width = 3.5, height = 3.5, projectileSpeed = 0, damage = 0, mana = 20, scale= 1, collisionMode = "barrier",isOffence = false},
						poisonOrb = {layer = "front",lifetime  = 40,image = poisonOrbImage, width = 0.5, height = 0.5, projectileSpeed = 3, damage = 0, mana = 10, scale= 0.1, collisionMode = "projectile",isOffence = true, effect = "poisoned",effectDuration = 5, rotationSpeed = 0.5},
						whirlwind = {layer = "back",lifetime  = 40,scale = 0.05,image = whirlwindImage, isAnimation = true, numFrames = 6, playSpeed = 5, frameWidth = 27, width = 3.5, height = 3.5, projectileSpeed = 2, damage = 0, mana = 20, scale= 1, collisionMode = "barrier",isOffence = false}
}

	uniqueProjectileCode = 1

	projectileStack = {}

	toRemove = {}

	multiCastSpells = {dragonsBreath = {mana = 30}, heal = {mana = 10, amount = 10}}--spellname = true, ...

end

function convertVector(vector)

	mag = math.sqrt(vector.x^2 + vector.y^2)
	dir = math.atan(vector.x/vector.y)

	return mag,dir

end

function convertDirection(dir,mag)

	x = (mag * math.cos(1.5708-dir))
	y = (mag * math.sin(1.5708-dir))

	return {x = x, y = y}

end

function cast(playerNum,spell)

	if not (multiCastSpells[spell]) then
		launch(playerNum,spell,players[playerNum].facingX,players[playerNum].facingY,false)
	else

		manacost = multiCastSpells[spell].mana

		if players[playerNum].mana >= manacost then
			players[playerNum].mana = players[playerNum].mana - manacost

			--custom cast code here:

			if spell == "dragonsBreath" then
				facingX,facingY = players[playerNum].facingX,players[playerNum].facingY
				for i=-1,1,0.2 do
					mag,dir = convertVector({x=facingX,y=facingY})
					vector = convertDirection(dir + i, mag)
					launch(playerNum,"poisonOrb",vector.x,vector.y,true)
				end
			end

			if spell == "heal" then

				players[playerNum].health = players[playerNum].health + multiCastSpells["heal"].amount

			end

		end

	end

end

function launch(playerNum,projectile,x,y,isCustomCast)

	pspeed = projectilesIndex[projectile].projectileSpeed
	manacost = projectilesIndex[projectile].mana

	rotation = 0
	if projectilesIndex[projectile].rotationSpeed then rotation = projectilesIndex[projectile].rotationSpeed end

	if players[playerNum].mana >= manacost or isCustomCast then

		addObject(uniqueProjectileCode,players[playerNum].x+players[playerNum].facingX,players[playerNum].y+players[playerNum].facingY, projectilesIndex[projectile].width,projectilesIndex[projectile].height,{removed = false,projectileStackIndex = #projectileStack+1,projectileIndex = projectile,owner = playerNum}) --todo projectile size - Adds a projectile object - todo multi-shot
		push(uniqueProjectileCode,x*pspeed,y*pspeed)-- provide initial velocity

		if not isCustomCast then players[playerNum].mana = players[playerNum].mana - manacost end --dedeuct mana cost

		projectileStack[#projectileStack+1] = {removed = false, lifetime = projectilesIndex[projectile].lifetime, rotation = rotation, projectileIndex = projectile, objectIndex = uniqueProjectileCode,animationStage = 1, frameTimer = 0, playerNum = playerNum} --adds a new projectile to the stack
		uniqueProjectileCode = uniqueProjectileCode + 1

		if projectilesIndex[projectile].loadCall then
			_G[projectilesIndex[projectile].loadCall](playerNum,projectilesIndex[projectile].loadArgs)
		end

	end

end

function stopTime(playerNum)

	timeStoppedTimer = 100
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

	projectileStack[projectileStackIndex].removed = true
	objects[projectileStack[projectileStackIndex].objectIndex].removed = true

end

function getAnimationQuad(projectile)

	frameWidth, frameHeight = projectilesIndex[projectile.projectileIndex].frameWidth, projectilesIndex[projectile.projectileIndex].frameHeight
	image = projectilesIndex[projectile.projectileIndex].image

	return love.graphics.newQuad((projectile.animationStage-1)*frameWidth,0,frameWidth,image:getHeight(),image:getWidth(),image:getHeight())

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

	manageStack()

end

function spell.draw()

	drawStack()
end

function addEffect(playerNum,effect)

	players[playerNum].effects[#players[playerNum].effects + 1] = {name = effect, count = 0}

end

function drawStack()

	if #projectileStack > 0 then

		for i=#projectileStack,1,-1  do
			if (not projectileStack[i].removed)then

				if projectilesIndex[projectileStack[i].projectileIndex].image and projectilesIndex[projectileStack[i].projectileIndex].layer == "front" then

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

end

function updateAnimation(projectile)

	if projectile.frameTimer <= 0 then
		projectile.frameTimer = 10/projectilesIndex[projectile.projectileIndex].playSpeed
		if projectile.animationStage < projectilesIndex[projectile.projectileIndex].numFrames then
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

			if not projectileStack[i].removed then

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

			if not objects[objectsList[i]].removed then

				if objects[objectsList[i]].projectileIndex then

					removedOrNot = objects[objectsList[i]].removed

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

				--damage stuff
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

	if timeStopped == false then
		if subject.rotationSpeed then projectileData.rotation = projectileData.rotation +  subject.rotationSpeed/10 end
		if projectileData.lifetime then 
			projectileData.lifetime = projectileData.lifetime - 0.1 
			if projectileData.lifetime < 0 then
				removeProjectile(findStackIndex(projectileData.objectIndex))
			end
		end


	end

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