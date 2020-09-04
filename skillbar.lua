function learnAttacks(attackNames,doDialog)
  if doDialog==nil then doDialog=true end
  for i,attackName in ipairs(attackNames) do
    local attack=nil
    for j,cAttack in ipairs(attacks) do
      if cAttack.name==attackName then
        attack=cAttack
      end
    end
    
    for j,cAttack in ipairs(players[1].attacks) do --On verifie que le joueur ne l'as pas deja
      if cAttack==attack then
        attack=nil
      end
    end
    
    if attack~=nil then
      table.insert(players[1].attacks,attack)
      if #players[1].skillbar<6 then 
        table.insert(players[1].skillbar,attack) 
        players[1].attack=players[1].skillbar[players[1].cattack]
      end
      if doDialog then
        talkies.say("NOUVELLE ATTAQUE !",attack.dName.."\n\n"..attack.desc,{image=attack.icon,onstart=function() onDialog=true end, oncomplete=function() onDialog=false love.graphics.setFont(dusty) end})
        players[1].interactcd=0.2
      end
    end
  end
end

function skillbarUpdate()
  local condition3=true
  if players[1].attack~=nil then condition3=(players[1].attack.hasEquipFunction~=true or players[1].attack.currentcd<0) end
  for i=1,6 do
    if players[1].cattack~=i and love.keyboard.isScancodeDown(skillKeys[i]) and players[1].skillbar[i]~=nil and condition3 then
      if players[1].attack~=nil then
        if players[1].attack.hasEquipFunction==true then
          players[1].attack:unequip(players[1])
        end
      end
      players[1].cattack=i
      players[1].attack=players[1].skillbar[i]
      print(players[1].attack.globulgaga)
      if players[1].attack.hasEquipFunction then
        players[1].attack:equip(players[1])
      end
      love.mouse.setCursor(arrowCursor)
    end
  end
end

function skillbarDraw(x,y)
  love.graphics.setFont(dusty)
  for i,skill in ipairs(players[1].skillbar) do
    if i==players[1].cattack then
      love.graphics.setColor(1,1,1,1)
    else
      love.graphics.setColor(0.7,0.7,0.7,0.7)
    end
    local width=40
    local height=40
    local scale=0.3
    local rectX=x+(i-1)*(width+5)
    local rectY=y
    local middleX=rectX+0.5*width-0.5*scale*players[1].width
    local middleY=rectY+0.5*height-0.5*scale*players[1].height
    
    love.graphics.rectangle("fill",rectX,rectY,width,height) --On dessine le rectangle de fond du rectangle
    love.graphics.draw(skill.icon,rectX+2,rectY+2)--L'icone
    love.graphics.setColor(0,0,0,0.7)--Puis la touche associée
    local key=love.keyboard.getKeyFromScancode(skillKeys[i])
    love.graphics.print(key,rectX+2,rectY+1,0,0.2,0.2)
    love.graphics.setLineWidth(1)    
    
    love.graphics.setColor(0.1,0.1,0.1,0.6)
    local cdRectHeight=height*(skill.currentcd/skill.cd)
    if cdRectHeight>height then cdRectHeight=height end
    if cdRectHeight<0 then cdRectHeight=0 end
    love.graphics.rectangle("fill",rectX,rectY+(height-cdRectHeight),width,cdRectHeight)
  end
end