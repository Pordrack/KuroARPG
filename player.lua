function newPlayer(joystick,isKeyboard)
  local player={}
  player.joystick = joystick
  if player.joystick~=nil then
    player.axisCount=joystick:getAxisCount( )
  end
  player.name="player"
  player.faction="player"
  player.spd=300
  player.dxSpeed=0 -- Vitesse desirée par le joueur
  player.ySpeed=0
  player.xSpeed=0
  player.txSpeed=0 --Vitesse transmise au joueur par une plateforme, ou autre object se déplacant et le touchant
  player.tySpeed=0 --Vitesse transmise au joueur par une plateforme, ou autre objet se déplacant et le touchant
  player.mapChangecd=0
  player.transportcd=0 --Baissé a chaque seconde, mise au dessus de 0 quand sur une plateforme mouvante. Sert a savoir si la vitesse est encore entrain d'être transmise ou si il faut la reset et l'ajouter a la vitesse du joueur, et si le joueur est transporté
  player.timeMod=1 --Modificateur du dt, modifie l'écoulement du temps pour le perso, par defaut sur 1
  player.look="up"
  player.maxlife=3
  player.life=3
  player.maxwakfu=112
  player.wakfu=112
  player.stamina=100
  player.maxstamina=100
  player.skin=1
  player.color={1,1,1}
  player.spawnx=0
  player.spawny=0
  player.rollcd=0
  player.x=player.spawnx
  player.y=player.spawny

  player.particles=love.graphics.newParticleSystem(particleSprite,320)
  player.particlesx=0
  player.particlesy=0
  player.particles:setLinearAcceleration(-100,-100,100,100)
  player.anims={
    up={love.graphics.newImage("sprites/players/1/up0.png"),love.graphics.newImage("sprites/players/1/up1.png"),love.graphics.newImage("sprites/players/1/up2.png"),love.graphics.newImage("sprites/players/1/up3.png")},
    down={love.graphics.newImage("sprites/players/1/down0.png"),love.graphics.newImage("sprites/players/1/down1.png"),love.graphics.newImage("sprites/players/1/down2.png"),love.graphics.newImage("sprites/players/1/down3.png")},
    left={love.graphics.newImage("sprites/players/1/left0.png"),love.graphics.newImage("sprites/players/1/left1.png"),love.graphics.newImage("sprites/players/1/left2.png"),love.graphics.newImage("sprites/players/1/left3.png")},
    right={love.graphics.newImage("sprites/players/1/right0.png"),love.graphics.newImage("sprites/players/1/right1.png"),love.graphics.newImage("sprites/players/1/right2.png"),love.graphics.newImage("sprites/players/1/right3.png")}
  }
  player.baseAnims=deepcopy(player.anims)
  player.anim=player.anims.up
  player.fps=12
  player.deathcd=1 --S'écoule quand le joueur meurt, une fois passé sous les 0, restart tout
  player.isKeyboard=isKeyboard --Le joueur joue-t-il au clavier ? 
  
  player.lifeIcon=love.graphics.newImage("sprites/players/"..player.skin.."/heart.png")
  player.lifeIcon:setFilter("linear","linear")
  player.frame=1
  player.initialWidth=12
  player.initialHeight=6
  player.width=12--player.anim[1]:getWidth()
  player.height=6--player.anim[1]:getHeight()
  player.attacks={}--{sword,tsphere,tturret}--Les attaques que le joueur connait
  player.skillbar={}--{sword,tsphere,tturret}--Les attaques que le joueur à dans sa skillbar
  player.cattack=1
  player.dAngle=0
  player.attack=player.skillbar[player.cattack]
  --player.attack=tturret--*tsphere
  player.attackcd=0.2
  player.invcd=0
  player.interactcd=0
  --loadPlayer(player)
  return player
end

function killPlayer(player,dt)
  if player.deathcd==1 then --Si vient juste de mourir tout se met en place
    shakingTime=1
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,500)
    particleSystem.particles:setLinearAcceleration(-100,-100,100,100)
    particleSystem.particles:setRadialAcceleration(-10,-5)
    particleSystem.particles:setColors(138/255,255/255,255/255,1,138/255,255/255,255/255,0)
    particleSystem.particles:setParticleLifetime(0.5,1)
    particleSystem.particles:emit(500)
    particleSystem.x=player.x+0.5*player.width
    particleSystem.y=player.y+0.5*player.height
    table.insert(particlesSystems,particleSystem)
  end
  player.deathcd=player.deathcd-dt
  
  if player.deathcd<0 then --Quand bien mort, restart tout
    player.life=player.maxlife --Reinitialisation de la vie du joueur, de sa position et de sa vitesse
    player.anims=deepcopy(player.baseAnims)
    player.anim=player.anims.up
    player.spawnx=spawnx 
    player.spawny=spawny
    player.x=player.spawnx
    player.y=player.spawny
    player.width=player.initialWidth
    player.height=player.initialHeight
    player.angle=nil
    player.xSpeed=0
    player.ySpeed=0
    player.pet=nil
    if player.baseSpd~=nil then player.spd=player.baseSpd end
    world:update(player,player.x,player.y,player.width,player.height)
    if players[1].attack~=nil then
      if players[1].attack.hasEquipFunction then
        players[1].attack:equip(players[1])
      end
    end
  
    --On clear les mobs spawnés, la foudre, les elements ephemeres, les projectiles...
    sparkles:purge()
    spawnedMobsPurge()
    for i,projectile in ipairs(projectiles) do
      if projectile.x~=nil and projectile.width~=nil then
        world:remove(projectile)
      end
    end
    projectiles={}
    
    for i,element in ipairs(spawnedElements) do
      if element.lifetime~=nil then
        element.lifetime=0
      elseif element.isOn==true then --On reeteint les boutons
        element.isOn=false
      end
      
      if element.x1~=nil then --On ramene aussi les trucs qui bouge a leur point de départ
        element.x=element.x1
        if element.path~=nil then element.cPoint=1 end
        world:update(element,element.x,element.y)
      end
    end
    --On spawn les mobsToSpawn
    for i,mobToSpawn in ipairs(mobsToSpawn) do
      for j,mob in ipairs(mobs) do
        if mob.name==mobToSpawn.name then
          local newMob=mob:new(mobToSpawn.x,mobToSpawn.y,mobToSpawn.attack,mobToSpawn.linkid,mobToSpawn.path)
          if mobToSpawn.attackcd~=nil then newMob.maxattackcd=mobToSpawn.attackcd end
          if mobToSpawn.life~=nil then newMob.life=mobToSpawn.life  newMob.maxlife=mobToSpawn.life end
          if mobToSpawn.spd~=nil then newMob.spd=mobToSpawn.spd newMob.baseSpd=mobToSpawn.spd end
          if mobToSpawn.precision~=nil then newMob.precision=mobToSpawn.precision end
        end
      end
    end
    
    --On reset le cooldown des attaques
    for i,attack in ipairs(player.skillbar) do
      attack.currentcd=0
    end
  end
end

function loadPlayer(player)
  world:add(player,player.x,player.y,player.width,player.height)
  for i,skill in ipairs(player.skillbar) do
    skill.currentcd=0
    print("j'ai mis a 0"..skill.name)
  end
end

function updatePlayer(player,dt)
  dt=dt*player.timeMod
  
  -- cooldowns
  player.rollcd=player.rollcd-dt
  player.mapChangecd=player.mapChangecd-dt
  player.attackcd=player.attackcd-dt 
  player.invcd=player.invcd-dt
  player.interactcd=player.interactcd-dt
  player.transportcd=player.transportcd-dt
  player.stamina=player.stamina+10*dt
  if player.stamina>player.maxstamina then player.stamina=player.maxstamina end
  --[[if player.transportcd>0 then
    player.color={1,0,0,1}
  else
    player.color={1,1,1,1}
  end]]
  for i,attack in ipairs(player.skillbar) do
    attack.currentcd=attack.currentcd-dt
  end
  
  if player.dAngle~=nil and player.angle~=nil then
    local newAngle=player.angle  
    --Adaptation de l'angle en fonction de l'angle desiré, sert dans le cas ou le joueur est transformé
    local newAngle1,newAngle2,dif1A,dif1B,dif2A,dif2B,dif1,dif2 
    newAngle1=player.angle+math.pi*dt
    newAngle2=player.angle-math.pi*dt
    
    
    dif1A=math.abs(2*math.pi-newAngle1+player.dAngle) 
    while dif1A>2*math.pi do dif1A=dif1A-2*math.pi end
    dif1B=math.abs(2*math.pi-player.dAngle+newAngle1) 
    while dif1B>2*math.pi do dif1B=dif1B-2*math.pi end
    if dif1B<dif1A then dif1=dif1B else dif1=dif1A end

    dif2A=math.abs(2*math.pi-newAngle2+player.dAngle) 
    while dif2A>2*math.pi do dif2A=dif2A-2*math.pi end
    dif2B=math.abs(2*math.pi-player.dAngle+newAngle2) 
    while dif2B>2*math.pi do dif2B=dif2B-2*math.pi end
    if dif2B<dif2A then dif2=dif2B else dif2=dif2A end
    
    if dif1<dif2 then
      newAngle=newAngle1
      if dif1<math.pi/16 then newAngle=player.dAngle end
      --print("on monte")
    else
      newAngle=newAngle2
      if dif2<math.pi/16 then newAngle=player.dAngle end
      --print("on descend")
    end
  
  --Adaptation de la hitbox en fonction de l'angle, sert dans le cas ou le joueur est tranformé
    if player.baseWidth==nil then player.baseWidth=player.width player.baseHeight=player.height end
    local oldX,oldY,newX,newY
    oldX=player.x+0.5*player.width
    oldY=player.y+0.5*player.height
    local newWidth=math.abs(math.cos(newAngle)*player.baseWidth)+math.abs(math.cos(newAngle-0.5*math.pi)*player.baseHeight)
    local newHeight=math.abs(math.sin(newAngle)*player.baseWidth)+math.abs(math.sin(newAngle-0.5*math.pi)*player.baseHeight)
    newX=oldX-0.5*newWidth
    newY=oldY-0.5*newHeight
    local canTurn=true
    local items,len=world:queryRect(newX,newY,newWidth,newHeight)
    for i,item in ipairs(items) do
      if item.tangibility~=false and item~=player then
        canTurn=false
      end
    end
    if canTurn and player.fixhitbox~=true then
      player.angle=newAngle
      player.x=newX
      player.y=newY
      player.height=newHeight
      player.width=newWidth
      world:update(player,player.x,player.y,player.width,player.height)
    elseif player.fixhitbox==true then
      player.angle=newAngle
    end
  end
  
  if player.isKeyboard and onDialog==false and player.isRolling~=true then --Deplacement/choix de la direction (modification de la vitesse desirée) 
    speedModif=1 --Modificateur de vitesse, permet d'eviter de trop speeder en diagonale
    fpsModif=1 --Modificateur de fps, permet d'eviter de trop speeder l'animation en diagonale
    if player.dySpeed~=0 and player.dxSpeed~=0 then speedModif=0.75 fpsModif=0.5 end
    --Sur l'axe X
    local mouseButton1=leftkey
    if tonumber(mouseButton1)==nil or tonumber(mouseButton1)<=3 then mouseButton1=0 end
    local mouseButton2=rightkey
    if tonumber(mouseButton2)==nil or tonumber(mouseButton2)<=3 then mouseButton2=0 end
    if love.keyboard.isScancodeDown(leftkey) or love.mouse.isDown(mouseButton1) then
      player.look="left"
      if player.anims.left~=nil then
        player.anim=player.anims.left
      else
        player.anim=player.anims.walk
        player.dAngle=-0.5*math.pi
      end
      player.dxSpeed=-player.spd*speedModif
      player.frame=player.frame+dt*player.fps*fpsModif
      local mouseButton=runkey
      if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
      if love.keyboard.isScancodeDown(runkey) or love.mouse.isDown(mouseButton) then
        player.dxSpeed=-3*player.spd*speedModif
        player.fps=18
      else
        player.fps=6
      end
    elseif love.keyboard.isScancodeDown(rightkey) or love.mouse.isDown(mouseButton2) then
      player.look="right"
      if player.anims.up~=nil then
        player.anim=player.anims.right
      else
        player.anim=player.anims.walk
        player.dAngle=0.5*math.pi
      end
      player.dxSpeed=player.spd*speedModif
      player.frame=player.frame+dt*player.fps*fpsModif
      local mouseButton=runkey
      if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
      if love.keyboard.isScancodeDown(runkey) or love.mouse.isDown(mouseButton) then
        player.dxSpeed=3*player.spd*speedModif
        player.fps=18
      else
        player.fps=6
      end
    else --Reduction de la vitesse si le joueur ne souhaite pas se deplacer
      player.dxSpeed=0
      if player.dySpeed==0 then player.frame=1 end
    end
    
    --Sur l'axe Y
    local mouseButton1=upkey
    if tonumber(mouseButton1)==nil or tonumber(mouseButton1)<=3 then mouseButton1=0 end
    local mouseButton2=downkey
    if tonumber(mouseButton2)==nil or tonumber(mouseButton2)<=3 then mouseButton2=0 end
    if love.keyboard.isScancodeDown(upkey) or love.mouse.isDown(mouseButton1) then
      player.look="up"
      if player.anims.up~=nil then
        player.anim=player.anims.up
      else
        player.anim=player.anims.walk
        player.dAngle=0
      end
      player.dySpeed=-player.spd*speedModif
      player.frame=player.frame+dt*player.fps*fpsModif
      local mouseButton=runkey
      if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
      if love.keyboard.isScancodeDown(runkey) or love.mouse.isDown(mouseButton) then
        player.dySpeed=-3*player.spd*speedModif
        player.fps=18
      else
        player.fps=6
      end
    elseif love.keyboard.isScancodeDown(downkey) or love.mouse.isDown(mouseButton2) then
      player.look="down"
      if player.anims.down~=nil then
        player.anim=player.anims.down
      else
        player.anim=player.anims.walk
        player.dAngle=math.pi
      end
      player.dySpeed=player.spd*speedModif
      player.frame=player.frame+dt*player.fps*fpsModif
      local mouseButton=runkey
      if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
      if love.keyboard.isScancodeDown(runkey) or love.mouse.isDown(mouseButton) then
        player.dySpeed=3*player.spd*speedModif
        --player.frame=player.frame-0.5*dt*player.fps
        player.fps=18
      else
        player.fps=6
      end
    else --Reduction de la vitesse si le joueur ne souhaite pas se deplacer
      player.dySpeed=0
      if player.dxSpeed==0 then player.frame=1 end
    end
    
    --Rapproche la vitesse en X de celle desirée
    if player.xSpeed<player.dxSpeed then
      player.xSpeed=player.xSpeed+1000*dt
      --player.xSpeed=player.xSpeed+3*math.abs(player.xSpeed-player.dxSpeed)*dt
      if player.xSpeed>player.dxSpeed then
        player.xSpeed=player.dxSpeed
      end
    elseif player.xSpeed>player.dxSpeed then
      player.xSpeed=player.xSpeed-1000*dt
      --player.xSpeed=player.xSpeed-3*math.abs(player.xSpeed-player.dxSpeed)*dt
      if player.xSpeed<player.dxSpeed then
        player.xSpeed=player.dxSpeed
      end
    end
    
    --Rapproche la vitesse en Y de celle desirée
    if player.ySpeed<player.dySpeed then
      player.ySpeed=player.ySpeed+1000*dt
      --player.xSpeed=player.xSpeed+3*math.abs(player.xSpeed-player.dxSpeed)*dt
      if player.ySpeed>player.dySpeed then
        player.ySpeed=player.dySpeed
      end
    elseif player.ySpeed>player.dySpeed then
      player.ySpeed=player.ySpeed-1000*dt
      --player.xSpeed=player.xSpeed-3*math.abs(player.xSpeed-player.dxSpeed)*dt
      if player.ySpeed<player.dySpeed then
        player.ySpeed=player.dySpeed
      end
    end
  end
  
  --Checking des murs
  hittingWall=false
  
  local x,y,height,width,xBack,yBack
  x=player.x
  y=player.y-1
  width=player.width
  height=1
  xBack=0
  yBack=200
  if player.look=="down" then
    x=player.x
    y=player.y+player.height
    width=player.width
    height=1
    xBack=0
    yBack=-200
  end
    
  if player.look=="left" then
    x=player.x-1
    y=player.y
    width=1
    height=player.height
    xBack=200
    yBack=0
  end
    
  if player.look=="right" then
    x=player.x+player.width
    y=player.y
    width=1
    height=player.height
    xBack=-200
    yBack=0
  end
    
  local items, len = world:queryRect(x,y,width,height)
  for i,cItem in ipairs(items) do
    if cItem.name=="damage" and player.invcd<0 and player.transportcd<0 then
      player.xSpeed=xBack
      player.ySpeed=yBack
      player.invcd=0.2
      world:update(player,player.x,player.y)
      player.life=player.life-1
    end
    
    if cItem.tangibility~=false and cItem.name~="player" then
      hittingWall=true
    end
  end
  
  if hittingWall and player.invcd<0 then 
    if (player.look=="left" and player.xSpeed>0) or (player.look=="right" and player.xSpeed<0)  then
      player.xSpeed=0 
    end
    
    if (player.look=="down" and player.ySpeed>0) or (player.look=="up" and player.ySpeed<0) then
      player.ySpeed=0
    end
  end
  
  --BULLET TIME
  globalTimemod=1
  if player.joystick~=nil then --Au joystick
    if player.joystick:isScancodeDown(5,6,7,8) then
      globalTimemod=10--.01
    end
  elseif player.isKeyboard then--Ou au clavier
    local mouseButton=slowkey
    if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
    if (love.keyboard.isScancodeDown(slowkey) or love.mouse.isDown(mouseButton)) and player.wakfu>dt then
      --player.wakfu=player.wakfu-100*dt
      globalTimemod=1/10--0.1
    end
    --[[if love.keyboard.isScancodeDown("r") then
      globalTimemod=0.01
    end]]
  end
  
  --Application des deplacements automatiques et manuels
  local cols,len
  if onDialog==false and player.life>0 then
    player.x,player.y,cols,len=world:move(player,player.x+player.xSpeed*dt,player.y+player.ySpeed*dt,colcheck)
  else
    cols={}
  end
  
  --[[for i,col in ipairs(cols) do
    if col.other.isMob==true and player.invcd<0 and player.y+player.height>col.other.y+5 then 
      player.life=player.life-1
      player.invcd=0.2
      shakingTime=0.1
      player.y=player.y-2
      if player.x>col.other.x then
        player.xSpeed=600
      else
        player.xSpeed=-600
      end
      player.ySpeed=-200
    end
  end]]
  
   --Animation
  if math.floor(player.frame)>#player.anim then player.frame=1 end
  
  --Particules
  player.particles:update(dt)
  
  --GESTION DE LA VITESSE TRANSMISE
  if player.transportcd<0 and (player.txSpeed~=0 or player.tySpeed~=0) then
    player.xSpeed=player.xSpeed+player.txSpeed
    player.ySpeed=player.ySpeed+player.tySpeed
    player.tySpeed=0
    player.txSpeed=0
  end
  
  --Regarde si il doit mourir
  if player.life<=0 then
    killPlayer(player,dt)
  end
  
  --Capacité à interagir
  if love.keyboard.isScancodeDown(interactkey) and player.interactcd<0 then
    player.interactcd=0.5
    local x,y,width,height --coordonnée tu rectangle d'interaction
    x=player.x
    y=player.y-10
    width=player.width
    height=10
    if player.look=="down" then
      x=player.x
      y=player.y+player.height
      width=player.width
      height=10
    end
    
    if player.look=="left" then
      x=player.x-10
      y=player.y
      width=10
      height=player.height
    end
    
    if player.look=="right" then
      x=player.x+player.width
      y=player.y
      width=10
      height=player.height
    end
    
    local items, len = world:queryRect(x,y,width,height) --Regarde quels hitboxs touche ce rectangle
    for i,item in ipairs(items) do
      if item.interactedWith~=nil and item.interactable~=false then
        item.interactedWith=true
      end
    end
  end
  --Capacité à attaquer 
  if player.attack~=nil and player.attackcd<0 and player.attack.currentcd<0 then
    local canAttack=true
    local mouseX,mouseY=love.mouse.getPosition()
    mouseX=(mouseX)/(zoom*sizeFactor)-translatex
    mouseY=(mouseY)/(zoom*sizeFactor)-translatey
    
    if player.attack.atype=="projectile" then
      love.mouse.setCursor(pvisor)
    elseif player.attack.range~=nil then
      local distance=math.sqrt((mouseX-player.x)^2+(mouseY-player.y)^2)
      if distance>player.attack.range then 
        canAttack=false 
        love.mouse.setCursor(redsvisor)
      else
        love.mouse.setCursor(greensvisor)
      end
    end
    
    if love.mouse.isDown(1) then
      if player.attack.cost~=nil then
        if player.wakfu<player.attack.cost then canAttack=false end
      end
    
      if canAttack then
        love.mouse.setCursor(arrowCursor)
        player.attackcd=0.5--player.attack.cd
        player.attack.currentcd=player.attack.cd
        player.wakfu=player.wakfu-player.attack.cost
        player.attack:new(player,mouseX,mouseY)
      end
    end
  end
  
  --Capacité a faire des roulades / a esquiver
  if love.keyboard.isScancodeDown(rollkey) and player.rollcd<0 and player.stamina>50 then
    player.xSpeed=0
    player.ySpeed=0
    local newX=player.x
    local newY=player.y
    if player.look=="up" then
      --player.ySpeed=-1000
      --player.xSpeed=0
      newY=player.y-100
    elseif player.look=="down" then
      --player.ySpeed=1000
      --player.xSpeed=0
      newY=player.y+100
    elseif player.look=="right" then
      --player.ySpeed=0
      --player.xSpeed=1000
       newX=player.x+100
    else
      --player.ySpeed=0
      --player.xSpeed=-1000
      newX=player.x-100
    end
    
    local isBlocked=false
    local items, len = world:querySegment(player.x,player.y,newX,newY) 
    for i,item in ipairs(items) do
      if item.tangibility~=false and item.damage==nil and item.life==nil then
        isBlocked=true
      end
    end
      
    if isBlocked==false then
      --Laisse des petites particules 
      local particleSystem={}
      particleSystem.particles=love.graphics.newParticleSystem(particleSprite,200)
      particleSystem.particles:setLinearAcceleration(-100,-100,100,100)
      particleSystem.particles:setColors(69/255,255/255,219/255,1,69/255,255/255,219/255,0)
      particleSystem.particles:setParticleLifetime(0.2,1.2)
      particleSystem.particles:emit(200)
      particleSystem.x=player.x+0.5*player.width
      particleSystem.y=player.y+0.5*player.height--0.5*player.anim[1]:getHeight()
      particleSystem.particles:setEmissionArea("uniform",0.5*player.width,0.5*player.height,0,true)
      table.insert(particlesSystems,particleSystem)
    
      player.x=newX
      player.y=newY
      world:update(player,player.x,player.y)
      
      --Laisse des petites particules 
      local particleSystem={}
      particleSystem.particles=love.graphics.newParticleSystem(particleSprite,200)
      particleSystem.particles:setLinearAcceleration(-100,-100,100,100)
      particleSystem.particles:setColors(69/255,255/255,219/255,1,69/255,255/255,219/255,0)
      particleSystem.particles:setParticleLifetime(0.2,1.2)
      particleSystem.particles:emit(200)
      particleSystem.x=player.x+0.5*player.width
      particleSystem.y=player.y+0.5*player.height--0.5*player.anim[1]:getHeight()
      particleSystem.particles:setEmissionArea("uniform",0.5*player.width,0.5*player.height,0,true)
      table.insert(particlesSystems,particleSystem)
      
      player.stamina=player.stamina-50
    end
    
    player.rollcd=0.5
    --player.isRolling=true
  end
  
  --[[if player.rollcd<0.19 and player.isRolling~=false then
    player.isRolling=false
    player.xSpeed=0
    player.ySpeed=0
  end]]
  
  player.timeMod=1
end

function drawPlayer(player,playerPos)
  --EFFET DE SUPER VITESSE SI IL COURS
  if love.keyboard.isDown(runkey) and player.life>0 then
    for i=1,3 do
      local x=(player.x+0.5*player.width)-i*0.008*player.xSpeed-0.5*player.width
      local y=(player.y+0.5*player.height)-i*0.008*player.ySpeed-0.5*player.height
      local frame=player.frame-i
      if frame<1 then frame=#player.anim-(1-frame) end
      
      if frame<1 or math.floor(frame)>#player.anim then frame=1 end
      love.graphics.setColor(1,1,1,1/(i+1))
      if player.angle==nil then
        love.graphics.draw(player.anim[math.floor(player.frame)],x+player.width/2,y,0,1,1,(player.width+(player.anim[math.floor(player.frame)]:getWidth()-player.width))/2,(player.anim[math.floor(player.frame)]:getHeight()-player.height))
      else
        love.graphics.draw(player.anim[math.floor(player.frame)],x+0.5*player.width,y+0.5*player.height,player.angle,player.size,player.size,0.5*player.anim[math.floor(player.frame)]:getWidth(),0.5*player.anim[math.floor(player.frame)]:getHeight())
      end
    end
  end
  love.graphics.setColor(1,1,1,1)

  love.graphics.setColor(player.color)
  if math.floor(player.frame)>#player.anim then player.frame=1 end
  if player.life>0 then
    if player.angle==nil then
      love.graphics.draw(player.anim[math.floor(player.frame)],player.x+player.width/2,player.y,0,1,1,(player.width+(player.anim[math.floor(player.frame)]:getWidth()-player.width))/2,(player.anim[math.floor(player.frame)]:getHeight()-player.height))
    else
      love.graphics.draw(player.anim[math.floor(player.frame)],player.x+0.5*player.width,player.y+0.5*player.height,player.angle,player.size,player.size,0.5*player.anim[math.floor(player.frame)]:getWidth(),0.5*player.anim[math.floor(player.frame)]:getHeight())
    end
  end
  
  love.graphics.draw(player.particles,player.x+player.particlesx,player.y+player.particlesy)
  --love.graphics.rectangle("line",player.x,player.y,player.width,player.height)
end