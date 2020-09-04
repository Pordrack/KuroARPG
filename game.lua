function gameLoad()
  print("gameLoad() lancée")
  spawnedMobs={}
  projectiles={}
  platforms={}
  scrolls={}
  spawnedElements={}
  upBorder=nil
  downBorder=nil
  leftBorder=nil
  rightBorder=nil
  particlesSystems={} --Les systemes de particules "independants" /!\ ne regroupe pas tous les sytemes de particules, juste ceux qui ont une position definie, genre le wakfu d'un mob mort, ou les etincelles d'un pong fu qui a repondit
  world = bump.newWorld(50)
  math.randomseed(love.timer.getTime())
  love.math.setRandomSeed(love.timer.getTime())
  globalTimemod=1 --Comme pour les joueurs, mais global. Multiplicateur du dt, =1 vitesse normal, <1 ralenti et >1 acceleré
  levelheight=0 --Hauteur du niveau, coordonné y ou le sol s'arrête et ou la camera doit pas aller

  sparkles:purge()
  --INITIALISATION DES MONSTRES DISPO

  loadMobs()

  local spawnLevel="level_incarnam"
  if love.filesystem.read("spawnLevel")~=nil then
    spawnLevel=love.filesystem.read("spawnLevel")
  end

  loadLevel(1,spawnLevel)

  players={newPlayer(nil,true)}
  loadPlayer(players[1])

  if love.filesystem.read("spawnx")~=nil then
    spawnx=love.filesystem.read("spawnx")
    spawny=love.filesystem.read("spawny")
    spawnx=tonumber(spawnx)
    spawny=tonumber(spawny)
    if spawnx==nil then spawnx=0 love.filesystem.remove("spawnx") end
    if spawny==nil then spawny=0 love.filesystem.remove("spawny") end
  end

  if love.filesystem.read("attacks")~=nil then
    local skillbar=TSerial.unpack(love.filesystem.read("skillbar"))
    local attacks=TSerial.unpack(love.filesystem.read("attacks"))
    learnAttacks(skillbar,false)
    learnAttacks(attacks,false)
  end

  players[1].spawnx=spawnx
  players[1].spawny=spawny
  players[1].x=players[1].spawnx
  players[1].y=players[1].spawny
  world:update(players[1],players[1].x,players[1].y)

  if players[1].attack~=nil then
    if players[1].attack.hasEquipFunction then
      players[1].attack:equip(players[1])
    end
  end

  --On reset le cooldown des attaques
  for i,attack in ipairs(players[1].skillbar) do
    attack.currentcd=0
  end
end

function gameUpdate(dt)
  dt=dt*globalTimemod

  for i,spawnedElement in ipairs(spawnedElements) do
    updateElement(spawnedElement,dt)
  end

  skillbarUpdate()
  sparkles:update(dt)

  for i,player in ipairs(players) do
    updatePlayer(player,dt)
  end

  for i,projectile in ipairs(projectiles) do
    updateProjectile(projectile,dt)
  end

  for i,attack in ipairs(players[1].skillbar) do
    if attack.autoupdate==true then
      attack:update(dt)
    end
  end

  for i,spawnedMob in ipairs(spawnedMobs) do
    updateSpawnedMob(spawnedMob,dt)
  end

  for i,particlesSystem in ipairs(particlesSystems) do
    particlesSystem.particles:update(dt)
  end

  cameraUpdate(dt)
end

function gameDraw(dt)
  --CAMERA
  --translatex=0.75*(love.graphics.getWidth()-800*sizeFactor
  if shakingTime>0 then
    love.graphics.translate(math.random(-4*sizeFactor,4*sizeFactor),math.random(-4*sizeFactor,4*sizeFactor))
  end
  love.graphics.scale(zoom,zoom)
  cameraDraw()
  local leftB,rightB,upB,downB --Les bordures de l'écran
  leftB=-translatex-50*(zoom*sizeFactor)
  rightB=-translatex+(love.graphics.getWidth())/(zoom*sizeFactor)+100*(zoom*sizeFactor)
  upB=-translatey-50*(zoom*sizeFactor)
  downB=-translatey+(love.graphics.getHeight())/(zoom*sizeFactor)+100*(zoom*sizeFactor)

  for i,spawnedElement in ipairs(spawnedElements) do
    local width=spawnedElement.width
    local height=spawnedElement.height
    if width==nil then width=1 end
    if height==nil then height=1 end
    if (spawnedElement.x+width>leftB and spawnedElement.x<rightB and spawnedElement.y+height>upB and spawnedElement.y<downB) or spawnedElement.hasDrawFunction==true then
      drawElement(spawnedElement)
    end
  end

  platformDraw()

  for i,spawnedMob in ipairs(spawnedMobs) do
    if spawnedMob.x+spawnedMob.width>leftB and spawnedMob.x<rightB and spawnedMob.y+spawnedMob.height>upB and spawnedMob.y<downB then
      drawSpawnedMob(spawnedMob)
    end
  end

  for i,projectile in ipairs(projectiles) do
    if projectile.width~=nil then
      if projectile.x+projectile.width>leftB and projectile.x<rightB and projectile.y+projectile.height>upB and projectile.y<downB then
        drawProjectile(projectile)
      end
    elseif  projectile.hasDrawFunction then
      drawProjectile(projectile)
    end
  end

  for i,particlesSystem in ipairs(particlesSystems) do
    if particlesSystem.angle==nil then particlesSystem.angle=0 end
    love.graphics.draw(particlesSystem.particles,particlesSystem.x,particlesSystem.y,particlesSystem.angle)
  end

  for i,player in ipairs(players) do
    drawPlayer(player)
  end

  sparkles:draw()

  for i,spawnedElement in ipairs(spawnedElements) do
    local width=spawnedElement.width
    local height=spawnedElement.height
    if width==nil then width=1 end
    if height==nil then height=1 end
    if (spawnedElement.x+width>leftB and spawnedElement.x<rightB and spawnedElement.y+height>upB and spawnedElement.y<downB) or spawnedElement.hasDrawFunction==true then
      if spawnedElement.foreground==true then
        drawElement(spawnedElement)
      elseif spawnedElement.particles~=nil then
        drawElement(spawnedElement,true)
      end
    end
  end

  for i,projectile in ipairs(projectiles) do
    if projectile.width~=nil then
      if projectile.x+projectile.width>leftB and projectile.x<rightB and projectile.y+projectile.height>upB and projectile.y<downB then
        if projectile.foreground==true then
          drawProjectile(projectile)
        elseif projectile.particles~=nil then
          drawProjectile(projectile,true)
        end
      end
    end
  end

  for i,attack in ipairs(players[1].skillbar) do
    if attack.autoupdate then
      attack:draw()
    end
  end
  --love.graphics.rectangle("fill",-translatex+50/zoom,-translatey+50/zoom,(love.graphics.getWidth()-100)/zoom,(love.graphics.getHeight()-100)/zoom)
  --HUD
  love.graphics.translate(-translatex,-translatey)
  love.graphics.scale(1/(zoom),1/(zoom))
  if onDialog==false then
    for j,aPlayer in ipairs(players) do
      if aPlayer.life>0 then
        --Les coeurs entier
        for k=1,math.floor(aPlayer.life) do
          love.graphics.draw(aPlayer.lifeIcon,5+(k-1)*(aPlayer.lifeIcon:getWidth()+5),5+(j-1)*(aPlayer.lifeIcon:getHeight()+15))
        end
        --Le coeur partiel putain de sa mere il marche pas et je comprend pas pourquoi
        love.graphics.setScissor((5+math.floor(aPlayer.life)*(aPlayer.lifeIcon:getWidth()+5))*sizeFactor,(5+(j-1)*(aPlayer.lifeIcon:getHeight()+15))*sizeFactor,(aPlayer.life-math.floor(aPlayer.life))*aPlayer.lifeIcon:getWidth()*sizeFactor,aPlayer.lifeIcon:getHeight()*sizeFactor+1)
        love.graphics.draw(aPlayer.lifeIcon,5+(math.floor(aPlayer.life))*(aPlayer.lifeIcon:getWidth()+5),5+(j-1)*(aPlayer.lifeIcon:getHeight()+15))
        love.graphics.setScissor(0,0,love.graphics.getWidth(),love.graphics.getHeight())
        love.graphics.setColor(0.6,0.6,0.6,1)
        love.graphics.rectangle("fill",5,-5+j*(aPlayer.lifeIcon:getHeight()+15),112+2,12)
        love.graphics.setColor(250/255,169/255,18/255,1)
        love.graphics.rectangle("fill",6,-5+j*(aPlayer.lifeIcon:getHeight()+15)+1,(aPlayer.stamina/aPlayer.maxstamina)*112,10)
        love.graphics.setColor(0,0,0,1)
        love.graphics.line(6+0.5*112,-5+j*(aPlayer.lifeIcon:getHeight()+15)+1,6+0.5*112,-5+j*(aPlayer.lifeIcon:getHeight()+15)+11)
      end
    end

    --Skillbar
    skillbarDraw((love.graphics.getWidth()/sizeFactor)-#players[1].skillbar*45-10,10)

    love.graphics.setColor(1,1,1,1)        
    love.graphics.print(tostring(love.timer.getFPS()).." FPS",10,55,0,0.4,0.4)
  end
  love.graphics.setColor(1,1,1,1)
  love.graphics.scale(1/sizeFactor,1/sizeFactor)
  talkies.draw()
  love.graphics.scale(sizeFactor,sizeFactor)

end