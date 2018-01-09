local object = {}

function object.load()

	indexList = {}
	objects = {} --x, y, velx, vely, active, width, height, playerHitbox?
	numObjects = 0

end

function object.update()

	applyVelocities()

end

function object.draw()



end

function applyVelocities()

	if numObjects > 0 then

		for i=1, numObjects do

			if objects[indexList[i]].active == true then
				objects[indexList[i]].x = objects[indexList[i]].x + objects[indexList[i]].velx
				objects[indexList[i]].y = objects[indexList[i]].y + objects[indexList[i]].vely

			end

		end

	end

end

function addObject(ID,x,y,w,h,args)

	objects[ID] = {x=x,y=y,velx=0,vely=0,active=true,width=w,height=h}
	indexList[#indexList+1] = ID
	numObjects = numObjects + 1

	if args.playerHitbox then
		objects[ID].playerHitbox = true
	end

	if args.projectileIndex then
		objects[ID].projectileIndex = args.projectileIndex
	end

	if args.owner then
		objects[ID].owner = args.owner
	end

end

function removeObject(ID)

	objects[ID].active = false

end

function push(ID,x,y)

	objects[ID].velx = objects[ID].velx + x
	objects[ID].vely = objects[ID].vely + y

end

function put(ID, x,y)

	objects[ID].x=x
	objects[ID].y=y

end

function checkForCollision(args)

	SubjectID = args.subject

	isColliding = false
	withWhat = {}

	SmaxX,SminX = objects[SubjectID].x + objects[SubjectID].width, objects[SubjectID].x
	SmaxY,SminY = objects[SubjectID].y + objects[SubjectID].height, objects[SubjectID].y

	for i=1, numObjects do

		if args.object then
			ObjectID = args.object
		else
			ObjectID = indexList[i]
		end

		if objects[ObjectID].active == true and not(ObjectID==SubjectID) then

			OmaxX,OminX = objects[ObjectID].x + objects[ObjectID].width, objects[ObjectID].x
			OmaxY,OminY = objects[ObjectID].y + objects[ObjectID].height, objects[ObjectID].y

			if (OmaxY > SminY and OminY < SmaxY) and (OmaxX > SminX and OminX < SmaxX) then

				isColliding = true
				withWhat[#withWhat+1] = ObjectID

			end

		end

	end

	return {isColliding,withWhat}

end

function getObject(ID)
	return objects[ID]
end

function setObject(ID,object)
	objects[ID] = object
end

function getLocation(ID)

	return objects[ID].x,objects[ID].y

end

function drawObject(ID)

	if objects[ID].active then

		love.graphics.rectangle("line",applyScroll(objects[ID].x,"x"),applyScroll(objects[ID].y,"y"),objects[ID].width*tileSize,objects[ID].height*tileSize)

	end

end

return object