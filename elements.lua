function loadElements()
  
  elements={} 
  spawnedElements={}
  
  --ELEMENT SPEED
  speed={
    name="speed",
    --cd=5,
    --autoupdate=false
  }
  
  function speed:new(x,y,radius,width,height)
    local xPoint=x
    local yPoint=y
    
    local speedZone={
      name="speed",
      radius=radius,
      x=xPoint,
      y=yPoint,
      width=width,
      height=height
      --lifeTime=5
    }
    
    speedZone.particles=love.graphics.newParticleSystem(particleSprite,320)
    speedZone.particles:setLinearAcceleration(0,25,0,50)
    if radius~=nil then
      speedZone.particles:setEmissionArea("ellipse",speedZone.radius,speedZone.radius,0,true)
      speedZone.particlesx=0
      speedZone.particlesy=0
    else
      speedZone.particles:setEmissionArea("uniform",speedZone.width/2,speedZone.height/2,0,true)
      speedZone.particlesx=speedZone.width/2
      speedZone.particlesy=speedZone.height/2
    end
    speedZone.particles:setColors(255, 204, 0,255,255, 204, 0, 0)
    speedZone.particles:setParticleLifetime(0.5,1.5)
    table.insert(spawnedElements,speedZone)
  end
  
  function speed:update(spawnedElement,dt)
    spawnedElement.particles:update(dt)
    spawnedElement.particles:emit(32)
    for i,player in ipairs(players) do
      if spawnedElement.radius~=nil then
        if math.sqrt((player.x-spawnedElement.x)*(player.x-spawnedElement.x)+(player.y-spawnedElement.y)*(player.y-spawnedElement.y))<spawnedElement.radius then
          player.timeMod=2
        end
      else
        if player.y+player.height>spawnedElement.y and player.y<spawnedElement.y+spawnedElement.height and player.x<spawnedElement.x+spawnedElement.width and player.x+player.width>spawnedElement.x then
          player.timeMod=2
        end
      end
    end
    --if characterhitbox.downside > hitbox.upside and characterhitbox.upside < hitbox.downside and characterhitbox.leftside < hitbox.rightside and characterhitbox.rightside >   hitbox.leftside then
    --[[element.lifeTime=element.lifeTime-dt
    if element.lifeTime<0 then
      for i=0,love.math.random(0,10) do
        --newPlatform(element.x+20*math.floor(love.math.random(-3,3)),element.y+20*math.floor(love.math.random(-3,3)),"none",0,0,love.math.random(3,6))
      end
      
      for i,cSpawnedElements in ipairs(spawnedElements) do
        if spawnedElement==cSpawnedElements then
          table.remove(spawnedElements,i)
        end
      end
    end]]
  end
  
  --ELEMENT SLOW
  slow={
    name="slow",
    --cd=5,
    --autoupdate=false
  }
  
  function slow:new(x,y,radius)
    local xPoint=x
    local yPoint=y
    
    local slowZone={
      name="slow",
      phrase="michel I love you",
      x=xPoint,
      y=yPoint,
      radius=radius,
      width=width,
      height=height
      --lifeTime=4,
    }
    
    slowZone.particles=love.graphics.newParticleSystem(particleSprite,320)
    slowZone.particles:setLinearAcceleration(0,25,0,50)
    if radius~=nil then
      slowZone.particles:setEmissionArea("ellipse",slowZone.radius,slowZone.radius,0,true)
      slowZone.particlesx=0
      slowZone.particlesy=0
    else
      slowZone.particles:setEmissionArea("uniform",slowZone.width/2,slowZone.height/2,0,true)
      slowZone.particlesx=slowZone.width/2
      slowZone.particlesy=slowZone.height/2
    end
    slowZone.particles:setColors(159/255,226/255,235/255,255/255,159/255,226/255,235/255,0/255)
    slowZone.particles:setParticleLifetime(0.5,1.5)
    slowZone.particlesx=0
    slowZone.particlesy=0
    table.insert(spawnedElements,slowZone)
  end
  
  function slow:update(spawnedElement,dt)
    spawnedElement.particles:update(dt)
    spawnedElement.particles:emit(32)
    for i,player in ipairs(players) do
      if spawnedElement.radius~=nil then
        if math.sqrt((player.x-spawnedElement.x)*(player.x-spawnedElement.x)+(player.y-spawnedElement.y)*(player.y-spawnedElement.y))<spawnedElement.radius then
          player.timeMod=0.5
        end
      else
        if player.y+player.height>spawnedElement.y and player.y<spawnedElement.y+spawnedElement.height and player.x<spawnedElement.x+spawnedElement.width and player.x+player.width>spawnedElement.x then
          player.timeMod=0.5
        end
      end
    end
    
    --[[element.lifeTime=element.lifeTime-dt
    if element.lifeTime<0 then
      for i=0,love.math.random(0,10) do
        newPlatform(element.x+20*math.floor(love.math.random(-3,3)),element.y+20*math.floor(love.math.random(-3,3)),"none",0,0,love.math.random(3,6))
      end
      
      for i,spawnedElement in ipairs(spawnedElements) do
        if spawnedElement==spawnedElement then
          table.remove(spawnedElements,i)
        end
      end
    end]]
  end
  
  --ELEMENT SOURCE DE WAKFU
  source={
    name="source",
    --cd=5,
    --autoupdate=false
  }
  
  function source:new(x,y,width,height)
    if height==nil then height=50 end
    if width==nil then width=32 end
    local wakfuSource={
      name="source",
      x=x,
      y=y,--height,
      width=width,
      height=height,
      foreground=true,
      tangibility=false,
      --lifeTime=4,
    }
    
    wakfuSource.particles=love.graphics.newParticleSystem(particleSprite,100)
    wakfuSource.particles:setLinearAcceleration(-5,-25,5,-50)
    wakfuSource.particles:setEmissionArea("uniform",wakfuSource.width/2,0,0,true)
    wakfuSource.particlesx=wakfuSource.width/2
    wakfuSource.particlesy=wakfuSource.height/2
    wakfuSource.particles:setColors(69/255,255/255,219/255,1,69/255,255/255,219/255,0)
    wakfuSource.particles:setParticleLifetime(1,2)
    wakfuSource.particlesx=0.5*wakfuSource.width
    wakfuSource.particlesy=wakfuSource.height
    
    world:add(wakfuSource,wakfuSource.x,wakfuSource.y,wakfuSource.width,wakfuSource.height)
    table.insert(spawnedElements,wakfuSource)
  end
  
  function source:update(spawnedElement,dt)
    spawnedElement.particles:emit(100*dt)
    local x,y,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.y,colcheck)
    for i,col in ipairs(cols) do
      if col.other.name=="player" then
        col.other.wakfu=col.other.wakfu+50*dt
        if col.other.wakfu>col.other.maxwakfu then
          col.other.wakfu=col.other.maxwakfu
        end
      end
    end
  end
  
--ELEMENT PORTAL
  portal={
    name="portal",
    --cd=5,
    --autoupdate=false
  }
  
  function portal:new(x1,y1,x2,y2,radius)

    local portal1={
      name="portal",
      radius=radius,
      x=x1,
      y=y1,
      destX=x2,
      destY=y2,
    }
    
    local portal2={
      name="portal",
      radius=radius,
      x=x2,
      y=y2,
      destX=x1,
      destY=y1,
    }
    
    portal1.particles=love.graphics.newParticleSystem(particleSprite,320)
    portal1.particles:setLinearAcceleration(0,25,0,50)
    
    portal1.particles:setEmissionArea("ellipse",portal1.radius,portal1.radius,0,true)
    portal1.particlesx=0
    portal1.particlesy=0
    portal1.particles:setColors(116/255,87/255,177/255,1,0,0,0,0)
    portal1.particles:setParticleLifetime(0.5,1.5)
    table.insert(spawnedElements,portal1)
    
    portal2.particles=love.graphics.newParticleSystem(particleSprite,320)
    portal2.particles:setLinearAcceleration(0,25,0,50)
    
    portal2.particles:setEmissionArea("ellipse",portal2.radius,portal2.radius,0,true)
    portal2.particlesx=0
    portal2.particlesy=0
    portal2.particles:setColors(116/255,87/255,177/255,1,0,0,0,0)
    portal2.particles:setParticleLifetime(0.5,1.5)
    table.insert(spawnedElements,portal2)
  end
  
  function portal:update(spawnedElement,dt)
    spawnedElement.particles:update(dt)
    spawnedElement.particles:emit(32)
    for i,player in ipairs(players) do
      if math.sqrt((player.x-spawnedElement.x)*(player.x-spawnedElement.x)+(player.y-spawnedElement.y)*(player.y-spawnedElement.y))<spawnedElement.radius and player.portalcd<0 then
        player.x=spawnedElement.destX-0.5*player.width
        player.y=spawnedElement.destY-0.5*player.height
        world:update(player,player.x,player.y)
        player.portalcd=0.5
      end
    end
    
    for i,projectile in ipairs(projectiles) do
      if math.sqrt((projectile.x-spawnedElement.x)*(projectile.x-spawnedElement.x)+(projectile.y-spawnedElement.y)*(projectile.y-spawnedElement.y))<spawnedElement.radius and projectile.portalcd<0 then
        projectile.x=spawnedElement.destX-0.5*projectile.width
        projectile.y=spawnedElement.destY-0.5*projectile.height
        world:update(projectile,projectile.x,projectile.y)
        projectile.portalcd=0.5
      end
    end
  end
  
   --ELEMENT MOVING PLATFORM
  moving={
    name="moving",
    --cd=5,
    --autoupdate=false
  }
  
  function moving:new(x1,y1,x2,y2,spd,sprite,linkid,width,height,loop,tangibility)
    local movingPlatform={
      name="moving",
      linkid=linkid,
      x=x1,
      y=y1,
      x1=x1, --Point de départ de la plateforme
      y1=y1,
      x2=x2,
      y2=y2,
      spd=spd,
      transferSpd=true,
      angle=math.atan2(y2-y1,x2-x1), --Angle,utilisé pour calculer la vitesse a laquelle la plateforme va voyager
      xSpeed=0,
      ySpeed=0,
      dir=1, --1 si on va du point 1 au point 2, -1 si on va du point 2 au point 1
      sprite=sprite,
      width=sprite:getWidth(),
      height=sprite:getHeight(),
      triggers={},
      loop=loop,
      tangibility=tangibility,
      path=nil,
    }
    --On cherche une potentielle trajectoites
    for i,freepath in ipairs(freepaths) do --On regarde si une trajectoire libre est associée
      if freepath.linkid==movingPlatform.linkid then
        movingPlatform.path=freepath
        table.remove(freepaths,i)
        break;
      end
    end
                  
    for i,spawnedElement in ipairs(spawnedElements) do --Cherche ses triggers dans les objets
      if spawnedElement.linkid==movingPlatform.linkid and spawnedElement.triggers==nil then --Si meme linkid, et n'est pas un recepeteur alors
        table.insert(movingPlatform.triggers,spawnedElement) --Est ajouté aux triggers
      end
    end
    
    if movingPlatform.triggers==nil then
      movingPlatform.triggers={{isOn=true}} 
      movingPlatform.xSpeed=movingPlatform.spd*math.cos(movingPlatform.angle)
      movingPlatform.ySpeed=movingPlatform.spd*math.sin(movingPlatform.angle)
    end
    
    if movingPlatform.loop==nil then movingPlatform.loop=true end
    if width~=nil then movingPlatform.width=width end
    if height~=nil then movingPlatform.height=height end
    
    movingPlatform.xSpeed=movingPlatform.spd*math.cos(movingPlatform.angle)
    movingPlatform.ySpeed=movingPlatform.spd*math.sin(movingPlatform.angle)
    
    world:add(movingPlatform,movingPlatform.x,movingPlatform.y,movingPlatform.width,movingPlatform.height)
    table.insert(spawnedElements,movingPlatform)
  end
  
  function moving:update(spawnedElement,dt)
    local reachedEnd=false 
    
    local triggerisOn=false
    for i,trigger in ipairs(spawnedElement.triggers) do
      if trigger.isOn then triggerisOn=true end
    end
    
    if spawnedElement.xSpeed==0 and spawnedElement.ySpeed==0 and triggerisOn then
      spawnedElement.xSpeed=spawnedElement.dir*spawnedElement.spd*math.cos(spawnedElement.angle)
      spawnedElement.ySpeed=spawnedElement.dir*spawnedElement.spd*math.sin(spawnedElement.angle)
    elseif triggerisOn~=true then
      spawnedElement.xSpeed=0
      spawnedElement.ySpeed=0
    end
    
    local passengers={}
    local cols,len,goalX,goalY 
    goalX,goalY,cols,len=world:check(spawnedElement,spawnedElement.x+spawnedElement.xSpeed*dt,spawnedElement.y+spawnedElement.ySpeed*dt,colcheck)
    for i,col in ipairs(cols) do --Regarde les objets touchés pour voir si il y'a des passagés
      if col.other.xSpeed~=nil then --Ajoute les objets dynamique en passagés
        table.insert(passengers,col.other)
      end
    end
    
    for i,passenger in ipairs(passengers) do --Déplace les passagés
      passenger.transportcd=0.1
      local cols,len 
      passenger.x,passenger.y,cols,len=world:move(passenger,passenger.x+spawnedElement.xSpeed*dt,passenger.y+spawnedElement.ySpeed*dt,colcheck)
      if len>10 then
        reachedEnd=true
      end
      
      if passenger.txSpeed~=nil then --Enregistre la vitesse transmise
        passenger.txSpeed=spawnedElement.xSpeed
        passenger.tySpeed=spawnedElement.ySpeed
      end
    end
    
    if spawnedElement.path==nil then
      --On fait juste des allées retours entre x1 et x2 
      if spawnedElement.dir==1 then
        if spawnedElement.x2>spawnedElement.x1 then--Regarde l'axe X pour savoir si il a atteint la fin
          if spawnedElement.x>spawnedElement.x2 then reachedEnd=true end
        else
          if spawnedElement.x<spawnedElement.x2 then reachedEnd=true end
        end
      
        if spawnedElement.y2>spawnedElement.y1 then--Regarde l'axe Y pour savoir si il a atteint la fin
          if spawnedElement.y>spawnedElement.y2 then reachedEnd=true end
        else
          if spawnedElement.y<spawnedElement.y2 then reachedEnd=true end
        end
      elseif spawnedElement.dir==-1 then
        if spawnedElement.x1>spawnedElement.x2 then--Regarde l'axe X pour savoir si il a atteint la fin
          if spawnedElement.x>spawnedElement.x1 then reachedEnd=true end
        else
          if spawnedElement.x<spawnedElement.x1 then reachedEnd=true end
        end
      
        if spawnedElement.y1>spawnedElement.y2 then--Regarde l'axe Y pour savoir si il a atteint la fin
          if spawnedElement.y>spawnedElement.y1 then reachedEnd=true end
        else
          if spawnedElement.y<spawnedElement.y1 then reachedEnd=true end
        end
      end
    
      if reachedEnd and spawnedElement.loop then --Redemarre pour un tour, ou non
        --Replace bien la plateforme avec de repartir (si un connard s'est amusé a la bloquer pour le fun)
        if spawnedElement.dir==1 then
          spawnedElement.x,spawnedElement.y=world:move(spawnedElement,spawnedElement.x2,spawnedElement.y2,colcheck)
        else
          spawnedElement.x,spawnedElement.y=world:move(spawnedElement,spawnedElement.x1,spawnedElement.y1,colcheck)
        end
      
        spawnedElement.dir=-spawnedElement.dir
        spawnedElement.xSpeed=-spawnedElement.xSpeed
        spawnedElement.ySpeed=-spawnedElement.ySpeed
      elseif reachedEnd then
        spawnedElement.dir=0
        spawnedElement.xSpeed=0
        spawnedElement.ySpeed=0
      end
    elseif triggerisOn then--Sinon, on suit la trajectoire comme un mob le ferait
      if spawnedElement.path.cPoint<1 then spawnedElement.path.cPoint=1 end
      spawnedElement.dx=spawnedElement.path.xs[spawnedElement.path.cPoint] 
      spawnedElement.dy=spawnedElement.path.ys[spawnedElement.path.cPoint] 
      local distance=math.sqrt((spawnedElement.x-spawnedElement.dx)^2+(spawnedElement.y-spawnedElement.dy)^2)
      if distance<10 then
        spawnedElement.path.cPoint=spawnedElement.path.cPoint+1
        if spawnedElement.path.cPoint>#spawnedElement.path.xs then spawnedElement.path.cPoint=1 end
      end
      
      local angle=math.atan2(spawnedElement.dy-spawnedElement.y,spawnedElement.dx-spawnedElement.x)
      spawnedElement.xSpeed=math.cos(angle)*spawnedElement.spd 
      spawnedElement.ySpeed=math.sin(angle)*spawnedElement.spd
      
    end
    
    spawnedElement.x,spawnedElement.y,cols,len=world:move(spawnedElement,spawnedElement.x+spawnedElement.xSpeed*dt,spawnedElement.y+spawnedElement.ySpeed*dt,colcheck) --On deplace la plateforme maintenant
    
    if math.floor(spawnedElement.ySpeed+0.5)>0 and spawnedElement.tangibility then --Si on descend, et qu'on a une collision
      for i,passenger in ipairs(passengers) do -- alors on Replaque bien les passager au dessus de la plateforme
        local cols,len 
        passenger.x,passenger.y,cols,len=world:move(passenger,passenger.x,spawnedElement.y-passenger.height,colcheck)
      end
    end
  end
  
  --ELEMENT TRIGGER BUTTON
  button={
    name="button",
    offsprite=love.graphics.newImage("sprites/buttonoff.png"),
    onsprite=love.graphics.newImage("sprites/buttonon.png"),
  }
  
  function button:new(x,y,linkid,tangibility,interactable,attack)
    local spawnedButton={
      name="button",
      linkid=linkid,
      x=x,
      y=y,
      sprite=button.offsprite,
      width=button.onsprite:getWidth(),
      height=button.onsprite:getHeight(),
      isOn=false,
      tangibility=tangibility,
      interactedWith=false,
      triggercd=0,
      attack=attack,
      interactable=interactable,
    }
    for i,spawnedElement in ipairs(spawnedElements) do --Cherche ses recepteurs
      if spawnedElement.linkid==spawnedButton.linkid and spawnedElement.isOn==nil then --Si meme linkid, et n'est pas un trigger alors
        table.insert(spawnedElement.triggers,spawnedButton) --Est ajouté de l'autre objet
      end
    end
    
    world:add(spawnedButton,spawnedButton.x,spawnedButton.y,spawnedButton.width,spawnedButton.height)
    table.insert(spawnedElements,spawnedButton)
    return spawnedButton
  end
  
  function button:update(spawnedElement,dt)
    local cols,len,goalX,goalY 
    goalX,goalY,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.yt,colcheck)
    spawnedElement.triggercd=spawnedElement.triggercd-dt
    
    for i,col in ipairs(cols) do --Regarde si il est touché par un projectile recherché
      if spawnedElement.attack==nil then spawnedElement.attack="nothing" end
      if col.other.name==spawnedElement.attack then --Bouge les objets dynamique touchés
        col.other.life=0
        if spawnedElement.isOn then
          spawnedElement.isOn=false
        else
          spawnedElement.isOn=true
        end
        spawnedElement.sprite=button.onsprite
      end
    end
    
    if spawnedElement.interactedWith and spawnedElement.triggercd<=0 then
      if spawnedElement.isOn then 
        spawnedElement.isOn=false
      else
        spawnedElement.isOn=true
      end
      spawnedElement.triggercd=0.5
    elseif spawnedElement.interactedWith then
      spawnedElement.interactedWith=false
    end
    
    if spawnedElement.isOn and spawnedElement.sprite==button.offsprite then
      spawnedElement.sprite=button.onsprite
    elseif spawnedElement.isOn==false and spawnedElement.sprite==button.onsprite then
      spawnedElement.sprite=button.offsprite
    end
  end
  
  --ELEMENT TRIGGER MOB DETECTOR
  mobdetector={
    name="detector",
    offsprite=love.graphics.newImage("sprites/buttonoff.png"),
    onsprite=love.graphics.newImage("sprites/buttonon.png"),
    font=dusty,
    fontsize=0.2,
    hasDrawFunction=true,
    color={0,0,0}
  }
  
  function mobdetector:new(x,y,linkid,radius,maxmob,tangibility)
    local spawnedDetector={
      name="detector",
      linkid=linkid,
      x=x,
      y=y,
      radius=radius,
      sprite=mobdetector.offsprite,
      width=mobdetector.onsprite:getWidth(),
      height=mobdetector.onsprite:getHeight(),
      isOn=false,
      numberOfMobs=0,
      maxmob=maxmob,
      hasDrawFunction=true,
      tangibility=tangibility
    }
    for i,spawnedElement in ipairs(spawnedElements) do --Cherche ses recepteurs
      if spawnedDetector.linkid==spawnedElement.linkid and spawnedElement.isOn==nil then --Si meme linkid, et n'est pas un trigger alors
        table.insert(spawnedElement.triggers,spawnedDetector) --Est ajouté de l'autre objet
      end
    end
    
    if spawnedDetector.maxmob==nil then spawnedDetector.maxmob=0 end
    
    table.insert(spawnedElements,spawnedDetector)
    return spawnedDetector
  end
  
  function mobdetector:update(spawnedElement,dt)
    spawnedElement.numberOfMobs=0
    for i,mob in ipairs(spawnedMobs) do
      if math.sqrt((mob.x-spawnedElement.x)^2+(mob.y-spawnedElement.y)^2)<spawnedElement.radius then --Si un mob est present dans le rayon du detecteur
        spawnedElement.numberOfMobs=spawnedElement.numberOfMobs+1 --Il et ajouté au compteur
      end
    end
    
    if spawnedElement.numberOfMobs<=spawnedElement.maxmob then spawnedElement.isOn=true else spawnedElement.isOn=false end
    
    if spawnedElement.isOn and spawnedElement.sprite==mobdetector.offsprite then
      spawnedElement.sprite=mobdetector.onsprite
    elseif spawnedElement.isOn==false and spawnedElement.sprite==mobdetector.onsprite then
      spawnedElement.sprite=mobdetector.offsprite
    end
  end
  
  function mobdetector:draw(spawnedElement)
    love.graphics.setColor(mobdetector.color)
    love.graphics.setFont(mobdetector.font)
    love.graphics.print(spawnedElement.numberOfMobs,spawnedElement.x+0.5*spawnedElement.width,spawnedElement.y+0.5*spawnedElement.height,0,mobdetector.fontsize,mobdetector.fontsize,0.5*mobdetector.font:getWidth(spawnedElement.numberOfMobs),0.5*mobdetector.font:getHeight(spawnedElement.numberOfMobs))
    love.graphics.setColor(1,1,1)
  end
  
  --ELEMENT HEART
  heart={
    name="heart",
    sprite=love.graphics.newImage("sprites/players/1/heart.png"),
  }
  
  function heart:new(x,y,lifetime)
    local spawnedHeart={
      name="heart",
      sprite=heart.sprite,
      x=x,
      y=y,
      life=5,
      width=heart.sprite:getWidth(),
      height=heart.sprite:getHeight(),
      tangibility=false,
      lifetime=lifetime,
    }
    
    world:add(spawnedHeart,spawnedHeart.x,spawnedHeart.y,spawnedHeart.width,spawnedHeart.height)
    table.insert(spawnedElements,spawnedHeart)
    return spawnedHeart
  end
  
  function heart:update(spawnedElement,dt)
    if spawnedElement.lifetime~=nil and spawnedElement~=nil then
      spawnedElement.lifetime=spawnedElement.lifetime-dt
      if spawnedElement.lifetime<=0 then
        for j,element in ipairs(spawnedElements) do
          if spawnedElement==element then
            world:remove(spawnedElement)
            spawnedElement.x=nil
            spawnedElement.sprite=nil
            table.remove(spawnedElements,j)
            break;
          end
        end
      end
    end
    
    if spawnedElement.x~=nil then
      local x,y,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.y,colcheck)
      for i,col in ipairs(cols) do
        if col.other.name=="player" then
          col.other.life=col.other.life+1
          if col.other.life>col.other.maxlife then col.other.life=col.other.maxlife end
          for j,element in ipairs(spawnedElements) do
            if spawnedElement==element then
              world:remove(spawnedElement)
              spawnedElement.x=nil
              spawnedElement.sprite=nil
              table.remove(spawnedElements,j)
              break;
            end
          end
        end
      end
    end
  end
  
  --ELEMENT NPC
  npc={
    name="npc",
    font=dusty,
    fontsize=0.2,
    hasDrawFunction=true,
  }
  
  function npc:new(x,y,sprite,npcname,message,attack,disappear,destmap,linkid)
    local spawnednpc={
      name="npc",
      npcname=npcname,
      messages={message},
      x=x,
      y=y,--sprite:getHeight(),
      sprite=sprite,
      width=sprite:getWidth(),
      height=sprite:getHeight(),
      tangibility=true,
      hasDrawFunction=false,
      interactedWith=false,
      attack=attack,
      disappear=disappear,
      destmap=destmap,
      linkid=linkid,
    }
    
    if spawnednpc.destmap=="" then spawnednpc.destmap=nil end
    
    local disappeared=false
    for i,disappearedNpc in ipairs(disappearedNpcs) do --Verifie que le pnj n'est pas enregistré disparu
      if disappearedNpc==npcname then
        disappeared=true
      end
    end
    
    if disappeared==false then
      world:add(spawnednpc,spawnednpc.x,spawnednpc.y,spawnednpc.width,spawnednpc.height)
      table.insert(spawnedElements,spawnednpc)
    end
    return spawnednpc
  end
  
  function npc:update(spawnedElement,dt)
    --[[local x,y,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.y,colcheck)
    spawnedElement.colWithPlayer=false
    for i,col in ipairs(cols) do
      if col.other.name=="player" then
        if love.keyboard.isScancodeDown(interactkey) then
          talkies.say(spawnedElement.npcname,spawnedElement.messages,{onstart=function() onDialog=true end, oncomplete=function() onDialog=false players[1].spearcd=0.2 end})
        end
        spawnedElement.colWithPlayer=true
      end
    end]]
    if spawnedElement.interactedWith then
      if spawnedElement.disappear==true then --Si il s'agit d'un pnj qui disparait alors
        talkies.say(spawnedElement.npcname,spawnedElement.messages,{onstart=function() onDialog=true end, --Il dit le dialogue, puis se détruit a la fin
            oncomplete=function() 
              onDialog=false 
              if spawnedElement.attack~=nil then  
                learnAttacks({spawnedElement.attack}) 
              end
              
              if spawnedElement.destmap~=nil then
                mapChangerBegin:changeMap(spawnedElement.destmap,spawnedElement.linkid)
              end
              
              for i,element in ipairs(spawnedElements) do --Il se cherche lui meme, pour proprement se retirer
                if element.name=="npc" then
                  if element.npcname==spawnedElement.npcname then     
                    table.insert(disappearedNpcs,spawnedElement.npcname) --Il s'ajoute au registre
                    world:remove(spawnedElement)
                    table.remove(spawnedElements,i)--L'element se supprime, pour que le pnj disparaisse
                    love.graphics.setFont(dusty) 
                  end
                end
              end
            end})
      else 
        talkies.say(spawnedElement.npcname,spawnedElement.messages,{onstart=function() onDialog=true end, oncomplete=
          function() 
            onDialog=false 
            if spawnedElement.attack~=nil then
              learnAttacks({spawnedElement.attack}) 
            end
            
            if spawnedElement.destmap~=nil then
              mapChangerBegin:changeMap(spawnedElement.destmap,spawnedElement.linkid)
            end
              
            love.graphics.setFont(dusty) 
          end})
      end
      spawnedElement.interactedWith=false
    end
  end
  
  function npc:draw(spawnedElement)
    if spawnedElement.colWithPlayer==true then
      --love.graphics.setFont(dusty)
      --love.graphics.print(love.keyboard.getKeyFromScancode(upkey),spawnedElement.x+0.5*spawnedElement.width,spawnedElement.y-10,0,0.2,0.2,0.5*dusty:getWidth(love.keyboard.getKeyFromScancode(upkey)))
    end
  end
  --ELEMENT MAP CHANGER DEBUT BEGIN BEGINNING PORTAIL CHANGER MAP PORTAL
  mapChangerBegin={
    name="mapChangerBegin",
  }
  
  function mapChangerBegin:new(x,y,width,height,destmap,linkid)
    local spawnedBegin={
      name="mapChangerBegin",
      x=x,
      y=y,
      width=width,
      height=height,
      destmap=destmap,
      linkid=linkid,
      tangibility=false
    }
    
    world:add(spawnedBegin,spawnedBegin.x,spawnedBegin.y,spawnedBegin.width,spawnedBegin.height)
    table.insert(spawnedElements,spawnedBegin)
    return spawnedBegin
  end

  function mapChangerBegin:update(spawnedElement,dt)
    local x,y,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.y)
    for i,col in ipairs(cols) do
      if col.other.name=="player" then
        mapChangerBegin:changeMap(spawnedElement.destmap,spawnedElement.linkid)
      end
    end
  end
  
  function mapChangerBegin:changeMap(destmap,linkid)
    if players[1].mapChangecd<0 then
      players[1].mapChangecd=4
      players[1].pet=nil                                      
      loadLevel(nil,destmap)
      for i,element in ipairs(spawnedElements) do
        if element.name=="mapChangerEnd" and element.linkid==linkid then
          spawnx=element.x
          spawny=element.y
          players[1].spawnx=element.x
          players[1].spawny=element.y
          players[1].x=element.x
          players[1].y=element.y+players[1].initialHeight-players[1].height
          world:update(players[1],players[1].x,players[1].y)
        end
      end
    end
  end
  
  --ELEMENT MAP CHANGER FIN END ENDING PORTAIL CHANGER MAP PORTAL
  mapChangerEnd={
    name="mapChangerEnd",
  }
  
  function mapChangerEnd:new(x,y,linkid)
    local spawnedEnd={
      name="mapChangerEnd",
      x=x,
      y=y,
      linkid=linkid,
    }
    
    table.insert(spawnedElements,spawnedEnd)
    return spawnedEnd
  end
  
  function mapChangerEnd:update(spawnedElement,dt)
    --Y'as rien, mais si la fonction existe pas pour chaque element ça plante, et c'est plus rapide de juste faire une fonction vide plutot que de coder un cas special pour les quelques elements sans fonction update
  end
  
  --ELEMENT SAVEPOINT
  savepoint={
    name="savepoint",
    fps=12,
    anim={love.graphics.newImage("sprites/savepoint/savepoint00.png"),love.graphics.newImage("sprites/savepoint/savepoint01.png"),love.graphics.newImage("sprites/savepoint/savepoint02.png"),love.graphics.newImage("sprites/savepoint/savepoint03.png"),love.graphics.newImage("sprites/savepoint/savepoint04.png"),love.graphics.newImage("sprites/savepoint/savepoint05.png"),love.graphics.newImage("sprites/savepoint/savepoint06.png"),love.graphics.newImage("sprites/savepoint/savepoint07.png"),love.graphics.newImage("sprites/savepoint/savepoint08.png"),love.graphics.newImage("sprites/savepoint/savepoint09.png")},
  }
  
  function savepoint:new(x,y)
    local spawnedSavepoint={
      name="savepoint",
      x=x,
      y=y,--phoenix.sprite:getHeight(),
      frame=1,
      sprite=savepoint.anim[1],
      width=savepoint.anim[1]:getWidth(),
      height=savepoint.anim[1]:getHeight(),
      cd=2.1,
      interactedWith=false,
    }
    
    spawnedSavepoint.particles=love.graphics.newParticleSystem(particleSprite,200)
    spawnedSavepoint.particles:setLinearAcceleration(-5,-25,5,-50)
    spawnedSavepoint.particles:setEmissionArea("uniform",spawnedSavepoint.width/2,0,0,true)
    spawnedSavepoint.particlesx=spawnedSavepoint.width/2
    spawnedSavepoint.particlesy=spawnedSavepoint.height/2
    spawnedSavepoint.particles:setColors(255/255,89/255,9/255,1,255/255,89/255,9/255,0)
    spawnedSavepoint.particles:setParticleLifetime(1,2)
    spawnedSavepoint.particlesx=0.5*spawnedSavepoint.width
    spawnedSavepoint.particlesy=spawnedSavepoint.height
    
    world:add(spawnedSavepoint,spawnedSavepoint.x,spawnedSavepoint.y,spawnedSavepoint.width,spawnedSavepoint.height)
    table.insert(spawnedElements,spawnedSavepoint)
    return spawnedSavepoint
  end
  
  function savepoint:update(spawnedElement,dt)
    --Anim
    spawnedElement.frame=spawnedElement.frame+dt*savepoint.fps
    if math.floor(spawnedElement.frame)>#savepoint.anim then spawnedElement.frame=1 end
    spawnedElement.sprite=savepoint.anim[math.floor(spawnedElement.frame)]
    spawnedElement.cd=spawnedElement.cd-dt
    --[[if spawnedElement.cd>0.1 then
      spawnedElement.particles:emit(200*dt)
    end]]
    
    if spawnedElement.interactedWith then
      spawnedElement.interactedWith=false
      spawnedElement.cd=2.1
      spawnx=math.floor(spawnedElement.x+0.5*(spawnedElement.width-players[1].width))
      spawny=math.floor(spawnedElement.y+spawnedElement.height+players[1].height+1)
      players[1].life=players[1].maxlife
      love.filesystem.write("spawnLevel",currentLevel)
      love.filesystem.write("spawnx",spawnx)
      love.filesystem.write("spawny",spawny)
      love.filesystem.write("disappearedNpcs",TSerial.pack(disappearedNpcs)) 
      
      --On prepare un tableau avec le nom des attaques du joueur, et un pour sa skillbar
      local attackNames={}
      local skillbarNames={}
      for i,attack in ipairs(players[1].attacks) do
        table.insert(attackNames,attack.name)
      end
      
      for i,attack in ipairs(players[1].skillbar) do
        table.insert(skillbarNames,attack.name)
      end
      love.filesystem.write("attacks",TSerial.pack(attackNames))
      love.filesystem.write("skillbar",TSerial.pack(skillbarNames))
      
      talkies.say("Sauvegarde","Votre progression à bien été sauvegardée",{onstart=function() onDialog=true end, oncomplete=function() onDialog=false love.graphics.setFont(dusty) end})
    end
  end
  
  --ELEMENT ALTAR
  altar={
    name="altar",
    sprite=love.graphics.newImage("sprites/altar.png"),
    hasDrawFunction=true
  }
  
  function altar:new(x,y)
    local spawnedAltar={
      name="altar",
      x=x,
      y=y,--phoenix.sprite:getHeight(),
      frame=1,
      sprite=altar.sprite,
      width=altar.sprite:getWidth(),
      height=altar.sprite:getHeight(),
      cd=0,
      interactedWith=false,
      foreground=false,
      quitColor={1,1,1,1},
      hasDrawFunction=true
    }
    
    world:add(spawnedAltar,spawnedAltar.x,spawnedAltar.y,spawnedAltar.width,spawnedAltar.height)
    table.insert(spawnedElements,spawnedAltar)
    return spawnedAltar
  end
  
  function altar:update(spawnedElement,dt)
    spawnedElement.cd=spawnedElement.cd-dt
    if spawnedElement.interactedWith and spawnedElement.cd<0 and onDialog==false then
      spawnedElement.interactedWith=true
      spawnedElement.cd=0.5
      players[1].interactcd=0.5
      onDialog=true
      onDialogElement=spawnedElement
      spawnedElement.foreground=true
      if players[1].attack~=nil then
        if players[1].attack.hasEquipFunction then
          players[1].attack:unequip(players[1])
        end
      end
    end
    
    if spawnedElement.interactedWith and onDialog then
      love.mouse.setCursor(arrowCursor)
      local mouseX,mouseY=love.mouse.getPosition()
      mouseX=mouseX/sizeFactor
      mouseY=mouseY/sizeFactor
      local columnsNumber=math.floor((love.graphics.getWidth())/40)
      for i=0,#players[1].attacks-1 do --Parcours les attaques
        local row=math.floor(i/columnsNumber) --La ligne de l'icone
        local column=i%columnsNumber --La colonne
        local x,y,width,height
        x=20+40*column
        y=20+(row)*40
        width=40
        height=40
        
        if mouseX>x and mouseX<x+width and mouseY>y and mouseY<y+height then --Si la souris est sur une attaque, et qu'un slot est libre
          love.mouse.setCursor(hand)
          if love.mouse.isDown(1) and #players[1].skillbar<6 then --Et qu'on clique, et qu'un slot est libre
            local alreadyHere=false
            for j,attack in ipairs(players[1].skillbar) do --On verifie qu'elle n'y est pas deja
              if attack==players[1].attacks[i+1] then
                alreadyHere=true
              end
            end
            if alreadyHere==false then
              table.insert(players[1].skillbar,players[1].attacks[i+1]) --L'attaque est ajoutée
            end
          elseif love.mouse.isDown(2) and clickcd<0 then
            clickcd=0.5
            interactcd=0.5
            escapecd=0.5
            spawnedElement.cd=3600 --Pour etre sur qu'appuyer sur e durant le message quitte pas l'interface
            talkies.say("Informations",players[1].attacks[i+1].dName.."\n\n"..players[1].attacks[i+1].desc,{image=players[1].attacks[i+1].icon,oncomplete=function() love.graphics.setFont(dusty) spawnedElement.cd=0.5 end})
          end
        end
      end
      escapecd=0.5
      --Maintenant, on gere la skillbar, et la possibilité de yeet des attaques
      local x,y,width,height
      x=0.5*(love.graphics.getWidth()/sizeFactor)-0.5*#players[1].skillbar*45
      y=love.graphics.getHeight()/sizeFactor-120
      width=45*#players[1].skillbar
      height=45
      if mouseX>x and mouseX<x+width and mouseY>y and mouseY<y+height then
        love.mouse.setCursor(hand)
        if love.mouse.isDown(1) and clickcd<0 then
          clickcd=0.2
          local attackNumber=math.floor(1+(mouseX-x)/45)
          table.remove(players[1].skillbar,attackNumber)
        end
      end
      
      --Enfin, la possibilité de quitter le menu
      local x,y,width,height
      x=0.5*(love.graphics.getWidth()/sizeFactor)-0.25*dusty:getWidth("Valider")
      y=love.graphics.getHeight()/sizeFactor-50
      width=0.5*dusty:getWidth("Valider")--*sizeFactor
      height=0.5*dusty:getHeight("Valider")--*sizeFactor
      if mouseX>x and mouseX<x+width and mouseY>y and mouseY<y+height then
        love.mouse.setCursor(hand)
        spawnedElement.quitColor={1,0,0,1}
        if love.mouse.isDown(1) and clickcd<0 then
          clickcd=0.2
          players[1].interactd=0.5
          spawnedElement.interactedWith=false
          spawnedElement.cd=2.1
          onDialog=false
          onDialogElement=nil
          spawnedElement.foreground=false
          players[1].attack=players[1].skillbar[players[1].cattack]
          players[1].attackcd=0.5
          if players[1].attack~=nil then
            if players[1].attack.hasEquipFunction then
              players[1].attack:equip(players[1])
            end
          end
        end
      else
        spawnedElement.quitColor={1,1,1,1}
      end
      
      --On peut aussi quitter via des boutons
      if spawnedElement.cd<0 and ((love.keyboard.isDown("escape","e","space","return","delete") or love.keyboard.isScancodeDown(interactkey))) then
        print("je quitte là")
        clickcd=0.2
        players[1].interactd=0.5
        spawnedElement.interactedWith=false
        spawnedElement.cd=2.1
        onDialog=false
        onDialogElement=nil
        spawnedElement.foreground=false
        players[1].attack=players[1].skillbar[players[1].cattack]
        players[1].attackcd=0.5
        if players[1].attack~=nil then
          if players[1].attack.hasEquipFunction then
            players[1].attack:equip(players[1])
          end
        end
      end
    end
  end
  
  function altar:draw(spawnedElement,dt)
    local mouseX,mouseY=love.mouse.getPosition()
    mouseX=mouseX/sizeFactor
    mouseY=mouseY/sizeFactor
    
    if spawnedElement.interactedWith and onDialog then
      love.graphics.translate(-translatex,-translatey)
      love.graphics.scale(1/zoom,1/zoom)
      
      love.graphics.setColor(0.4,0.4,0.4,1) --Dessine le fond en rectangles
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth()/sizeFactor,love.graphics.getHeight()/sizeFactor)
      love.graphics.setColor(0.2,0.2,0.2,1)
      love.graphics.rectangle("fill",20,20,love.graphics.getWidth()/sizeFactor-40,love.graphics.getHeight()/sizeFactor-160)
      love.graphics.setColor(1,1,1,1)
      local columnsNumber=math.floor((love.graphics.getWidth())/40)
      for i=0,#players[1].attacks-1 do --Parcours les attaques
        local row=math.floor(i/columnsNumber) --La ligne de l'icone
        local column=i%columnsNumber --La colonne
        love.graphics.draw(players[1].attacks[i+1].icon,20+40*column,20+(row)*40)
      end
      
      --dessine la skillbar
      skillbarDraw(0.5*(love.graphics.getWidth()/sizeFactor)-0.5*#players[1].skillbar*45,love.graphics.getHeight()/sizeFactor-120)    
      
      --Puis le bouton quitter 
      local x,y,width,height
      x=0.5*(love.graphics.getWidth()/sizeFactor)-0.25*dusty:getWidth("Valider")
      y=love.graphics.getHeight()/sizeFactor-50
      love.graphics.setColor(spawnedElement.quitColor)
      love.graphics.print("Valider",x,y,0,0.5,0.5)
      
      love.graphics.scale(zoom,zoom)
      love.graphics.translate(translatex,translatey)
      love.graphics.setColor(1,1,1,0)
    end
  end
  
  --ELEMENT DECORATION
  deco={
    name="deco",
  }
  
  function deco:new(x,y,sprite,foreground,text,color)
    local spawnedDeco={
      name="deco",
      foreground=foreground,
      x=x,
      y=y,
      sprite=sprite,
    }
    if text~=nil then
      --spawnedDeco.texts={text}
      spawnedDeco.text=text
      spawnedDeco.color=color
      spawnedDeco.hasDrawFunction=true
    end
    
    table.insert(spawnedElements,spawnedDeco)
    return spawnedDeco
  end
  
  function deco:update(spawnedElement,dt)
  
  end

  function deco:draw(spawnedElement)
    --[[for i=1,math.floor(#spawnedElement.texts/3) do
      i=i*3
      love.graphics.print(spawnedElement.texts[i],spawnedElement.texts[i+1],spawnedElement.texts[i+2])
    end]]
    love.graphics.setColor(spawnedElement.color)
    love.graphics.setFont(mobdetector.font)
    love.graphics.print(spawnedElement.text,spawnedElement.x,spawnedElement.y,0,0.2,0.2)
    love.graphics.setColor(1,1,1,1)
  end
  
  --ELEMENT FALLING PLATFORM7
  --/!\ seul element ou il faut donner une imageData au lieu de sprite, à cause de la fonction getPixel
  falling={
    name="falling",
  }
  
  function falling:new(x,y,timer,spriteData,width,height)
    local spawnedFalling={
      name="falling",
      x=x,
      y=y,
      sprite=love.graphics.newImage(spriteData),
      width=spriteData:getWidth(),
      height=spriteData:getHeight(),
      timer=timer,
      tangibility=false,
    }
    if width~=nil then
      spawnedFalling.width=width
      spawnedFalling.height=height
    end
    
    local pixelX,pixelY,r,g,b
    pixelX=math.random(1,spawnedFalling.width-1)
    pixelY=math.random(1,spawnedFalling.height-1)
    r,g,b=spriteData:getPixel(pixelX,pixelY)
    
    spawnedFalling.particles=love.graphics.newParticleSystem(particleSprite,600)
    spawnedFalling.particles:setLinearAcceleration(-10,-10,10,10)
    spawnedFalling.particles:setEmissionArea("uniform",spawnedFalling.width/2,spawnedFalling.height/2,0,true)
    spawnedFalling.particlesx=spawnedFalling.width/2
    spawnedFalling.particlesy=spawnedFalling.height/2
    spawnedFalling.particles:setColors(r,g,b,1,r,g,b,0)
    spawnedFalling.particles:setParticleLifetime(1,5)
    spawnedFalling.particlesx=0.5*spawnedFalling.width
    spawnedFalling.particlesy=0.5*spawnedFalling.height
    
    world:add(spawnedFalling,spawnedFalling.x,spawnedFalling.y,spawnedFalling.width,spawnedFalling.height)
    table.insert(spawnedElements,spawnedFalling)
    return spawnedFalling
  end
  
  function falling:update(spawnedElement,dt)
    --Regarde les objets dessus
    local x,y,cols,len=world:check(spawnedElement,spawnedElement.x,spawnedElement.y)
    for i,col in ipairs(cols) do
      if col.other.life~=nil then
        col.other.transportcd=spawnedElement.timer+dt
        spawnedElement.timer=spawnedElement.timer-dt
        if spawnedElement.timer<=0 then --Si le timer est écoulé, la plateforme disparait et emet des particules
          for j,cElement in ipairs(spawnedElements) do
            if cElement==spawnedElement then
              table.remove(spawnedElements,j)
              world:remove(spawnedElement)
              spawnedElement.particles:emit(600)
              local particleSystem={
                x=spawnedElement.x+0.5*spawnedElement.width,
                y=spawnedElement.y+0.5*spawnedElement.height,
                particles=spawnedElement.particles
              }
              
              table.insert(particlesSystems,particleSystem)
              break;
            end
          end
        end
      end
    end
  end
  
  --ELEMENT DAMAGE (pieges, pic, feu etc.)
  damage={
    name="damage",
  }
  
  function damage:new(x,y,damage,tangibility,sprite,width,height,lifetime,dName)
    local spawnedKill={
      name="damage",
      x=x,
      y=y,
      sprite=sprite,
      width=sprite:getWidth(),
      height=sprite:getHeight(),
      damage=damage,
      tangibility=tangibility,
      lifetime=lifetime,
      dName=dName,
    }
    if spawnedKill.dName==nil then spawnedKill.dName="nule" end
    if width~=nil then
      spawnedKill.width=width
      spawnedKill.height=height
    end
    
    world:add(spawnedKill,spawnedKill.x,spawnedKill.y,spawnedKill.width,spawnedKill.height)
    table.insert(spawnedElements,spawnedKill)
    return spawnedKill
  end
  
  function damage:update(spawnedElement,dt)
    if spawnedElement.lifetime~=nil then
      spawnedElement.lifetime=spawnedElement.lifetime-dt
      if spawnedElement.lifetime<0 then
        for i,cElement in ipairs(spawnedElements) do
          if cElement==spawnedElement then
            table.remove(spawnedElements,i)
          end
        end
        world:remove(spawnedElement)
      end
    end
  end
  
  elements={moving,npc,mapChangerBegin,mapChangerEnd,savepoint,deco,falling,damage,heart,mobdetector,button,speed,portal,source,altar}
end

function updateElement(spawnedElement,dt)
  if spawnedElement.particles~=nil then
    spawnedElement.particles:update(dt)
  end
  
  for i,element in ipairs(elements) do 
    if element.name==spawnedElement.name then
      element:update(spawnedElement,dt)
    end
  end
end

function drawElement(spawnedElement,justParticles)
  if spawnedElement.particles~=nil then
    love.graphics.draw(spawnedElement.particles,spawnedElement.x+spawnedElement.particlesx,spawnedElement.y+spawnedElement.particlesy)
  end
  
  if spawnedElement.sprite~=nil and justParticles~=true then
    love.graphics.draw(spawnedElement.sprite,spawnedElement.x,spawnedElement.y)
    --if spawnedElement.x1~=nil then
      --love.graphics.circle("fill",spawnedElement.x1,spawnedElement.y1,1)
      --love.graphics.circle("fill",spawnedElement.x2,spawnedElement.y2,1)
    --end
  end
  
  if spawnedElement.hasDrawFunction==true and justParticles~=true then
    for i,element in ipairs(elements) do
      if element.name==spawnedElement.name then
        element:draw(spawnedElement)
      end
    end
  end
  
  --love.graphics.rectangle("line",spawnedElement.x,spawnedElement.y,spawnedElement.width,spawnedElement.height)
end