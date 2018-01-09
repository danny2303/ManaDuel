local ui = {}

function ui.load()

	barPadding = 100
	barDistance = 1200
	healthLength = 15
	manaLength = 5

end

function ui.update()



end

function ui.draw()

	drawUI()
	drawStatusEffects()

end

function drawUI()

	for i=1, 2 do

		health,mana = players[i].health*healthLength,players[i].mana*manaLength

		love.graphics.setColor(172,173,196,200)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),50,maxHealth*healthLength,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*maxHealth*healthLength),60,10) end
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),100,maxMana*manaLength,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*maxMana*manaLength ),110,10) end

		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),50,health,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*health),60,10) end

		love.graphics.setColor(47, 54, 216)
		love.graphics.rectangle("fill",i*barDistance-(barDistance-barPadding),100,mana,20)
		for j=1,2 do love.graphics.circle("fill",i*barDistance-(barDistance-barPadding)+((j-1)*mana ),110,10) end

		love.graphics.setColor(0,0,0)
		love.graphics.print("Health: "..round(players[i].health,1),(i*barDistance-(barDistance-barPadding)),53)
		love.graphics.print("Mana: "..round(players[i].mana,0),(i*barDistance-(barDistance-barPadding)),103)


	end

end

function drawStatusEffects()



end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return ui