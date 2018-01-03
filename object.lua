local object = {}

function object.load()

	indexList = {}
	objects = {} --x, y, velx, vely, active, width, height
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

function addObject(ID,x,y,w,h)

	objects[ID] = {x=x,y=y,velx=0,vely=0,active=true,width=w,height=h}
	indexList[#indexList+1] = ID
	numObjects = numObjects + 1

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

function checkForCollision(ID)

	print("new check:\n")

	isColliding = false
	withWhat = false

	SmaxX,SminX = objects[ID].x + objects[ID].width, objects[ID].x
	SmaxY,SminY = objects[ID].y + objects[ID].height, objects[ID].y

	for i=1, numObjects do

		if objects[indexList[1]].active == true and not(indexList[i]==ID) then

			OmaxX,OminX = objects[indexList[i]].x + objects[indexList[i]].width, objects[indexList[i]].x
			OmaxY,OminY = objects[indexList[i]].y + objects[indexList[i]].height, objects[indexList[i]].y

			print("S (maxx, minx, maxy, miny):"..SmaxX..", "..SminX..", "..SmaxY..", "..SminY)
			print("O (maxx, minx, maxy, miny):"..OmaxX..", "..OminX..", "..OmaxY..", "..OminY)

			if (OmaxY > SminY and OminY < SmaxY) and (OmaxX > SminX and OminX < SmaxX) then

				isColliding = true
				withWhat = objects[indexList[i]]

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