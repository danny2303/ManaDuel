scroll = require "scroll"
player = require "player"
object = require "object"
input = require "input"
ui = require "ui"
spell = require "spell"
lslui = require "lslui"
bitser = require 'bitser'
local utf8 = require("utf8")

function love.textinput(t)
    inputText = inputText .. t
end
 
function love.keypressed(key)
    if key == "backspace" then
        local byteoffset = utf8.offset(inputText, -1)
        if byteoffset then
            inputText = string.sub(inputText, 1, byteoffset - 1)
        end
    end
end

function love.load()

	inputText  = ""

	spellbooks = {{l1 = "dragonsBreath",l2 = "wisp",r1 = "fireball",r2 = "heal",s1 = "smokebomb",s2 = "mirror",s3 = "fireball",s4 = "orbitingSheild"},
				  {l1 = "whirlwind",l2 = "wisp",r1 = "fireball",r2 = "heal",s1 = "timeStop",s2 = "poisonOrb",s3 = "fireball",s4 = "orbitingSheild"}}


	--saving and loading demo 

	print(bitser.loads(love.filesystem.read("testSave.txt"))[1].s1)

	testTable = {hellotoyouall = 1,2,4,5,6,7,{1,2,3}}
	love.filesystem.write("testSave.txt", bitser.dumps(spellbooks))


	-----

	takeMouseInputsForUI = false

	soundtrack = love.audio.newSource("sounds/soundtrack.wav")
	soundtrack:play()

	inGame = false
	newRound = false

	love.window.setFullscreen(true)

	scroll.load()
	spell.load()
	object.load()
	player.load()

	input.load()
	ui.load()
	lslui.load()

	cooldownTime = 5

	--shaders

	blurShader = love.graphics.newShader[[

	// This shader is only here to help you understand how a very basic box blur works.
	// It should not be used as it's fairly inefficient and doesn't look as good as
	// a gaussian blur. Look at the "Blur (convoluted)" examples instead.
	extern float blurRadius;
	#define SAMPLE_RANGE 4
	vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
	  vec4 sum = vec4(0);
	  for(int x = -SAMPLE_RANGE; x < SAMPLE_RANGE + 1; x++){
	    for(int y = -SAMPLE_RANGE; y < SAMPLE_RANGE + 1; y++){
	      // textureOffset
	      sum += Texel(currentTexture, texCoords + blurRadius*vec2(x, y)/love_ScreenSize.xy);
	    }
	  }
	  sum = sum/(2*SAMPLE_RANGE*2*SAMPLE_RANGE);
	  return sum * color;
	}

	]]

	deathShader = love.graphics.newShader[[

	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	  vec4 pixel = Texel(texture, texture_coords );

	  vec4 combinedColor = pixel * color;

	  float adverageShade = (combinedColor.r + combinedColor.b + combinedColor.g)/3;

	  combinedColor.r = adverageShade;
	  combinedColor.b = adverageShade;
	  combinedColor.g = adverageShade;

	  return combinedColor;
	}

	  ]]


	--pause menu (gameMenu1)

	lslui.addButton({pos  = {x = love.graphics.getWidth()/2-160,y = love.graphics.getHeight()/2-230},size = {xsize = 220,ysize = 60}, textData = {text = "Resume",textx = 5,texty = 0},page = "gameMenu1",action = "run",joystickActions = {up = 2,down = 3,autoButtonSelect = 5}}) --2
	lslui.addButton({pos  = {x = love.graphics.getWidth()/2-190,y = love.graphics.getHeight()/2-30},size = {xsize = 280,ysize = 60}, textData = {text = "Back to menu",textx = 5,texty = 0},page = "gameMenu1",action = 0,joystickActions = {up = 2,down = 4,autoButtonSelect = 5}}) --3
	lslui.addButton({pos  = {x = love.graphics.getWidth()/2-160,y = love.graphics.getHeight()/2+170},size = {xsize = 220,ysize = 60}, textData = {text = "Exit",textx = 0,texty = 0},page = "gameMenu1",action = "exit",joystickActions = {up = 3,down = 4,autoButtonSelect = 5}}) -- 4

	--main menu (0)
	lslui.addButton({pos  = {x = 170,y = 100},size = {xsize = 240,ysize = 60}, textData = {text = "Fight"},page = 0,action = "enterSpellbook",joystickActions = {up = 8,down = 6,autoButtonSelect = 12},buttonType = {name = "rune", r= 255, b=0, g=0, runeNum = 1,size = 2}}) --5
	lslui.addButton({pos  = {x = 170,y = 270},size = {xsize = 240,ysize = 60}, textData = {text = "Options"},page = 0,action = 1,joystickActions = {up = 5,down = 7,autoButtonSelect = 11},buttonType = {name = "rune", r= 0, b=255, g=0, runeNum = 2,size = 2}}) --6
	lslui.addButton({pos  = {x = 170,y = 440},size = {xsize = 240,ysize = 60}, textData = {text = "Characters"},page = 0,action = 3,joystickActions = {up = 6,down = 8,autoButtonSelect = 7},buttonType = {name = "rune", r= 0, b=0, g=255, runeNum = 3,size = 2}}) --7
	lslui.addButton({pos  = {x = 170,y = 610},size = {xsize = 240,ysize = 60}, textData = {text = "Exit"},page = 0,action = "exit",joystickActions = {up = 7,down =5 ,autoButtonSelect = 5},buttonType = {name = "rune", r= 30, b=30, g=30, runeNum = 4,size = 2}}) --8

	--options menu (1)

	lslui.addButton({pos  = {x = 170,y = 180},size = {xsize = 280,ysize = 60}, textData = {text = "Volume:100",textx = 0,texty = 0},page = 1,action = 1,joystickActions = {up = 9,down = 10,left = 9,right = 9,autoButtonSelect = 9}}) --9
	lslui.addButton({pos  = {x = 170,y = 290},size = {xsize = 280,ysize = 60}, textData = {text = "Fullscreen",textx = -15,texty = -6},page = 1,action = "fullscreen",joystickActions = {up = 9,down = 11,autoButtonSelect = 10}}) --10
	lslui.addButton({pos  = {x = 170,y = 400},size = {xsize = 240,ysize = 60}, textData = {text = "Back",textx = 3,texty = -5},page = 1,action = 0,joystickActions = {up = 10,down = 11,autoButtonSelect = 6}}) --11

	--spellbook(2)

	lslui.addButton({pos  = {x = 20,y = 1000},size = {xsize = 240,ysize = 60}, textData = {text = "Back",textx = 3,texty = -5},page = 2,action = 0,joystickActions = {up=16,right=16,down=16,autoButtonSelect = 5}}) --12
	lslui.addButton({pos  = {x = 1600,y = 1000},size = {xsize = 240,ysize = 60}, textData = {text = "Next",textx = 3,texty = -5},page = 2,action = "nextcontrollingPlayer",joystickActions = {up=16,left=16,autoButtonSelect = 13}}) --13
	lslui.addButton({pos  = {x = 1400,y = 50},size = {xsize = 240,ysize = 60}, textData = {text = "Sort",textx = 3,texty = -5},page = 2,action = "cyclesort",joystickActions = {up=16,left=16,autoButtonSelect = 14}}) --14

	lslui.setMenuBackground({page = {0,1},image = "images/ui/ancientWall.png"})
	lslui.setMenuBackground({page = {2},image = "images/ui/spellbook.png"})

	lslui.loadSpellbookButtons("all")



end

function love.update(dt)

	--lslui.moveButton(love.mouse.getX(),love.mouse.getY(),5) --test code

	uiscale = love.graphics.getWidth()/1920

	input.update()

	if(inGame == true and lslui.getPage() ~= "gameMenu1")then
		cooldownTime = 20
		scroll.update()
		player.update(dt)
		object.update(dt)
		spell.update(dt)
	end

	lslui.update()
	ui.update()

	lslui.inGameMenu("start","gameMenu1")

	if(newRound == true)then
		scroll.load()
		spell.load()
		object.load()
		player.load()
		newRound = false
	end

end

function love.draw()

	blurShader:send("blurRadius", 3*math.pow(math.sin(love.timer.getTime()), 2))

	love.graphics.push()
	love.graphics.scale(uiscale)

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

		invisible = false
		mirrored = false

		if #players[i].effects > 0 then
			for effectNum=1,#players[i].effects do
				if players[i].effects[effectNum].name == "invisibility" then invisible = true end
				if players[i].effects[effectNum].name == "mirrored" then mirrored = true end
			end
		end

		if not(invisible) and not(mirrored) then 
			love.graphics.line(applyScroll(players[i].x+players[i].facingX,"x")*zoom,applyScroll(players[i].y+players[i].facingY,"y")*zoom,applyScroll(players[i].x+players[i].facingX*2,"x")*zoom,applyScroll(players[i].y+players[i].facingY*2,"y")*zoom) 
		end
		
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
							love.graphics.draw(image,applyScroll(x,"x")+2.5,applyScroll(y,"y")+2.5,projectileStack[i].rotation,scale,scale,image:getWidth()/2,image:getHeight()/2)
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
		drawEffects()
		
	end

	lslui.draw()
	ui.draw()
	for i = 1,10 do
	--	drawRune(math.random(0,1800),math.random(0,1000),math.random(1,8),"glowing",math.random(0,255),math.random(0,255),math.random(0,255))
	end

	love.graphics.pop()

	--debugging tools

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

	if player.getPlayersState() == "dead" then
		local roundedTime = math.floor(timeSinceDead * 10^(2 or 0) + 0.5) / 10^(2 or 0)
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(runeFont)
		love.graphics.setShader(deathShader)
		love.graphics.print(roundedTime,550,250,0,5,5)
	else
		love.graphics.setShader()
	end
end