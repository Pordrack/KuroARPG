function loadAttacks()
  --ATTAQUE DE BASE
  baseAttack={
    name="base attack",
    width=1,
    height=1,
    sprite=nil,
    cd=0.2,
  }
  
  function baseAttack:new(player)
    player.particles:setParticleLifetime(0.5,1.5)
    player.particles:setColors(0, 191, 255,255,0, 191, 255, 0)
    player.particles:emit(150)
    local xPoint=player.x-5
    if player.side==1 then
      xPoint=player.x+player.width+5
    end
    player.particlesmode="follow"
    player.particlesx=xPoint-player.x
    player.particlesy=0.5*player.height
    
    local items, len = world:queryPoint(xPoint,player.y+0.5*player.height)
    for i=1,len do
      if items[i].name=="player" and items[i]~=player then
        items[i].xSpeed=player.side*300
        items[i].ySpeed=-300
        items[i].y=items[i].y-5
      end
    end
  end
  
  --ATTAQUE ARROW
  arrow={
    name="arrow",
    sprite=love.graphics.newImage("sprites/arrowshot1.png"),
    cd=0.5,
    autoupdate=false
  }
  arrow.width=arrow.sprite:getWidth()
  arrow.height=arrow.sprite:getHeight()
  
  function arrow:new(player)
    local xPoint=player.x-1-arrow.width
    local angle=math.pi 
    local xSpeed=-400
    local ySpeed=0 
    local yPoint=player.y+player.height*0.5
    local width=arrow.width
    local height=arrow.height
    
    if player.side==1 then
      xPoint=player.x+player.width+0.1
      xSpeed=400
      angle=0
    end
    
    if player.look=="up" then
      xSpeed=0
      ySpeed=-400
      xPoint=player.x+0.5*player.width
      yPoint=player.y-2-arrow.height-player.height
      width=arrow.height
      height=arrow.width
      angle=-0.5*math.pi
    end
    
    if player.look=="down" then
      xSpeed=0
      ySpeed=400
      xPoint=player.x+0.5*player.width
      yPoint=player.y+0.1+player.height
      width=arrow.height
      height=arrow.width
      angle=0.5*math.pi
    end
    
    player.particlesmode=nil
    player.particles:setParticleLifetime(0.5,1)
    player.particles:setColors(140,161,163,255,140,161,163, 0)
    player.particles:emit(150)
    player.particlesx=xPoint+0.5*width
    player.particlesy=yPoint
    
    local projectileArrow={
      name="arrow",
      x=xPoint,
      y=yPoint,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
    }
    
    --[[projectileArrow.particles=love.graphics.newParticleSystem(particleSprite,320)
    projectileArrow.particles:setLinearAcceleration(-200,-200,200,200)
    projectileArrow.particles:setColors(133, 133, 173,255,133, 133, 173, 0)
    projectileArrow.particles:setParticleLifetime(0.5,1.5)
    projectileArrow.particlesx=width
    projectileArrow.particlesy=height]]
    
    world:add(projectileArrow,projectileArrow.x,projectileArrow.y,projectileArrow.width,projectileArrow.height)
    table.insert(projectiles,projectileArrow)
  end
  
  function arrow:update(projectile,dt)
    projectile.portalcd=projectile.portalcd-dt
    --projectile.particles:update(dt)
    --projectile.particles:emit(32)
    local cols,len
    if projectile~=nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)
    end

    for i,col in ipairs(cols) do
      
      if col.other.name=="player" then
        killPlayer(col.other)
        for j,cProjectile in ipairs(projectiles) do
          if cProjectile==projectile then
            table.remove(projectiles,j)
            world:remove(projectile)
            break;
          end
        end
      end
      
      if col.other.name=="platform" then
        if projectile.angle==0 then
          col.other.dupeDir="left"
        elseif projectile.angle==math.pi then
          col.other.dupeDir="right"
        elseif projectile.angle==0.5*math.pi then
          col.other.dupeDir="up"
        else 
          col.other.dupeDir="down"
        end
        
        col.other.dupet=0.05
        col.other.dupect=0.05
        col.other.charges=25
        
        for j,cProjectile in ipairs(projectiles) do
          if cProjectile==projectile then
            table.remove(projectiles,j)
            world:remove(projectile)
            break;
          end
        end
      end
      
    end
  end
  
  --ATTAQUE BOMBE
  bomb={
    name="bomb",
    sprite=love.graphics.newImage("sprites/arrowshot1.png"),
    cd=5,
    autoupdate=false
  }
  bomb.width=bomb.sprite:getWidth()
  bomb.height=bomb.sprite:getHeight()
  
  function bomb:new(player)
    local xPoint=player.x-1-bomb.width
    local angle=math.pi 
    local xSpeed=-200
    local ySpeed=-400 
    local yPoint=player.y+player.height*0.5
    local width=bomb.width
    local height=bomb.height
    
    if player.side==1 then
      xPoint=player.x+player.width+0.1
      xSpeed=-xSpeed
      angle=0
    end
    
    local projectileBomb={
      name="bomb",
      player=player,
      radius=150,
      portalcd=0,
      x=xPoint,
      y=yPoint,
      angle=angle,
      width=width,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
    }
    
    world:add(projectileBomb,projectileBomb.x,projectileBomb.y,projectileBomb.width,projectileBomb.height)
    table.insert(projectiles,projectileBomb)
  end
  
  function bomb:update(projectile,dt)
    --projectile.particles:update(dt)
    --projectile.particles:emit(32)
    projectile.portalcd=projectile.portalcd-dt
    local cols,len
    if projectile~=nil then
      projectile.ySpeed=projectile.ySpeed+gravity*60*dt
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)
    end

    if len>0 then
      projectile.player.particles:setLinearAcceleration(-500,-500,500,500)
      projectile.player.particles:setColors(191/255, 27/255, 27/255,255/255,191/255, 27/255, 27/255, 0)
      projectile.player.particles:setParticleLifetime(0.5,1.5)
      projectile.player.particlesx=projectile.x+0.5*projectile.width
      projectile.player.particlesy=projectile.y+0.5*projectile.height
      projectile.player.particles:emit(320)
      for i,player in ipairs(players) do
        if math.sqrt((player.x-projectile.x)*(player.x-projectile.x)+(player.y-projectile.y)*(player.y-projectile.y))<projectile.radius then
          killPlayer(player)
        end
      end
      
      for i,platform in ipairs(platforms) do
        if math.sqrt((platform.x-projectile.x)*(platform.x-projectile.x)+(platform.y-projectile.y)*(platform.y-projectile.y))<projectile.radius then
          local xDif=platform.x-projectile.x
          local yDif=platform.y-projectile.y 
          if (yDif*yDif)<(xDif*xDif) then
            if yDif>0 then
              platform.dupeDir="up"
            else
              platform.dupeDir="up"
            end
          else 
            if xDif>0 then
              platform.dupeDir="left"
            else
              platform.dupeDir="right"
            end
          end
          
          platform.dupet=0.1
          platform.dupect=0.1
          platform.charges=math.floor(math.sqrt((platform.x-projectile.x)*(platform.x-projectile.x)+(platform.y-projectile.y)*(platform.y-projectile.y))/20)+1
        end
      end
      
      for i,cProjectile in ipairs(projectiles) do
        if cProjectile==projectile then
          table.remove(projectiles,i)
          world:remove(projectile)
          break;
        end
      end
    end
  end
  
  --ATTAQUE TSPHERE
  tsphere={
    name="tsphere",
    dName="Sphere de foudre",
    desc="Lancer une sphere de foudre, qui rebondira jusqu'à trouver un ennemi auquel s'accrocher. Une fois accrochée, elle l'electrisera lui et ses alliés à proximiter, leur infligeant des dégats sur la durée.",
    icon=love.graphics.newImage("sprites/icons/tsphereIcon.png"),
    sprite=love.graphics.newImage("sprites/tsphere.png"),
    cd=5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false
  }

  tsphere.width=tsphere.sprite:getWidth()
  tsphere.height=tsphere.sprite:getHeight()
  
  function tsphere:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=600*math.cos(angle)
    local ySpeed=600*math.sin(angle)
    local width=tsphere.width
    local height=tsphere.height
    local xPoint=player.x+0.5*player.width+0.65*(player.width+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(player.width+width)*math.sin(angle)-0.5*height
    
    
    local projectileTsphere={
      name="tsphere",
      x=xPoint,
      y=yPoint,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      player=player,
      life=5,
      mobLinked=nil,
      targets={}, --Une fois lié, il ajoute a ses cibles les mobs voisins
    }
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(236/256,240/256,57/256,1,236/256,240/256,57/256,0)
    particleSystem.particles:setParticleLifetime(0.2,1.2)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    world:add(projectileTsphere,projectileTsphere.x,projectileTsphere.y,projectileTsphere.width,projectileTsphere.height)
    table.insert(projectiles,projectileTsphere)
  end
  
  function tsphere:update(projectile,dt)
    --projectile.particles:update(dt)
    --projectile.particles:emit(32)
    
    local cols,len
    if projectile~=nil and projectile.mobLinked==nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)

      for i,col in ipairs(cols) do
        if col.other.tangibility~=false then
          --Check une ligne allant de droite a gauche de la balle pour savoir si la collision vient horizontalement ou pas
          local items, len = world:querySegment(projectile.x-1,projectile.y+0.5*projectile.height,projectile.x+projectile.width+1,projectile.y+0.5*projectile.height)
          if len>1 then --C'est horizontale, inversion vitesse horizontale
            projectile.xSpeed=-projectile.xSpeed
          else --C'est verticla, inversion vitesse verticale
            projectile.ySpeed=-projectile.ySpeed
          end
          projectile.life=projectile.life-1
          if col.other.life~=nil then
            if col.other.isMob then --Se Link au premier mob touché
              projectile.mobLinked=col.other --Et devient invisible et intangible
              --col.other.color={236,240,57}
              --sparkles:newBoltSystem(x1,y1,x2,y2,numberOfBolts,width,color,lifetime,splitRate,gen,minOffset,maxOffset,fps)
              col.other.bolt=sparkles:newBoltSystem(col.other.x,col.other.y+0.5*col.other.height,col.other.x+col.other.width,col.other.y+0.5*col.other.height,2,0.5,{236/256,240/256,57/256},3)
              projectile.color={1,1,1,0} 
              projectile.tangibility=false
              if projectile.player.faction~=col.other.faction then
                col.other.target=projectile.player
              end
              if projectile.life>3 then projectile.life=3 end
            else
              col.other.life=col.other.life-1
              col.other.invcd=0.2
            end
          end    
      
          --Laisse des petites particules 
          local particleSysem={}
          particleSysem.particles=love.graphics.newParticleSystem(particleSprite,50)
          particleSysem.particles:setLinearAcceleration(-50,-50,50,50)
          particleSysem.particles:setColors(236/256,240/256,57/256,1,236/256,240/256,57/256,0)
          particleSysem.particles:setParticleLifetime(0.2,1.2)
          particleSysem.particles:emit(50)
          particleSysem.x=col.touch.x
          particleSysem.y=col.touch.y
          table.insert(particlesSystems,particleSysem)
      
          --Un peu de screenshake aussi
          shakingTime=0.05
    
          break --On sort de la boucle
        end
      end
    elseif projectile.mobLinked~=nil then --Si le projectile est deja lié on s'occupe du mob et de ses proches
      --On commence par chercher et ajouter de nouvelles cibles
      local mobLinked=projectile.mobLinked
      local x1,y1,x2,y2,distance
      x1=mobLinked.x+0.5*mobLinked.width
      y1=mobLinked.y+0.5*mobLinked.height
      for i,mob in ipairs(spawnedMobs) do
        x2=mob.x+0.5*mob.width
        y2=mob.y+0.5*mob.height
        distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
        if distance<100 and mob~=mobLinked and mob.faction~="player" then --Si l'autre mob est assez pres, ça devient une Target
          local alreadyTarget=false --On verifie qu'il est pas déja enregistré
          for j,target in ipairs(projectile.targets) do
            if target==mob then
              alreadyTarget=true
            end
          end
          
          if alreadyTarget==false then 
            table.insert(projectile.targets,mob) 
            --mob.bolt=sparkles:newBolt(x1,y1,x2,y2,0.5,{236/256,240/256,57/256},3)
            mob.bolt=sparkles:newBoltSystem(x1,y1,x2,y2,2,1,{236/256,240/256,57/256},3)
          end
        end
      end
      --Puis on regarde les targets actuels, verifie qu'ils sont assez pret, puis update leurs éclairs,inflige des dommages
      
      for i,target in ipairs(projectile.targets) do
        x2=target.x+0.5*target.width
        y2=target.y+0.5*target.height
        distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
        if distance>100 or target.faction=="player" then
          sparkles:remove(target.bolt)
          table.remove(projectile.targets,i)
        else
          target.life=target.life-1.2*dt
          if target.life<0 then
            sparkles:remove(target.bolt)
          else
            sparkles:updateSystem(target.bolt,x1,y1,x2,y2)
          end
        end
      end
      
      if mobLinked.faction=="player" then
        projectile.life=0
      end
      
      --Et enfin, on blesse le projectile et son monstre lié
      sparkles:updateSystem(mobLinked.bolt,mobLinked.x,mobLinked.y+0.5*mobLinked.height,mobLinked.x+mobLinked.width,mobLinked.y+0.5*mobLinked.height)
      mobLinked.life=mobLinked.life-dt
      projectile.life=projectile.life-dt
    end
    local condition=false
    if projectile.mobLinked~=nil then condition=projectile.mobLinked.life<=0 end
    if projectile.life<=0 or condition then
      for i,target in ipairs(projectile.targets) do
        sparkles:remove(target.bolt)
      end
      
      if projectile.mobLinked~=nil then
        sparkles:remove(projectile.mobLinked.bolt)
      end
      
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(projectile)
    end
  end
  
  
  
  --ATTAQUE TTURRET
  tturret={
    name="tturret",
    dName="Tourelle de la foudre",
    desc="Batissez une tourelle qui invoque le pouvoir de la foudre pour infliger des dégats sur la durée à vos adversaires.",
    icon=love.graphics.newImage("sprites/icons/tturretIcon.png"),
    sprite=love.graphics.newImage("sprites/tturret.png"),
    cd=40,
    currentcd=0,
    cost=0,--60,
    range=100,
    atype="summon",
    autoupdate=false, 
    --hasDrawFunction=true,
  }

  tturret.width=tturret.sprite:getWidth()
  tturret.height=tturret.sprite:getHeight()
  
  function tturret:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local width=tturret.width
    local height=tturret.height
    local xPoint=mouseX-0.5*width
    local yPoint=mouseY-0.5*height
    
    
    local summonedTturret={
      name="tturret",
      faction="player",
      x=xPoint,
      y=yPoint,
      width=width,
      height=height,
      life=60,
      targets={}, --Une fois lié, il ajoute a ses cibles les mobs voisins
      foreground=true,
      canInteract=true, --Ne peut interagir qu'avec un bouton, de toute sa vie
      tangibility=false,
      boltAngle=0,
      boltRotation=0,
      sprite=tturret.sprite
    }
    summonedTturret.boltAngle=math.random(314)/100
    summonedTturret.boltRotation=0.01*math.random(-157,157)
    local radius=12
    local x1,y1,x2,y2
    x1=mouseX+math.cos(summonedTturret.boltAngle)*radius
    y1=mouseY+math.sin(summonedTturret.boltAngle)*radius
    x2=mouseX+math.cos(summonedTturret.boltAngle+math.pi)*radius
    y2=mouseY+math.sin(summonedTturret.boltAngle+math.pi)*radius
    summonedTturret.bolt=sparkles:newBoltSystem(x1,y1,x2,y2,3,0.6,{236/256,240/256,57/256},60)
      
    world:add(summonedTturret,summonedTturret.x,summonedTturret.y,summonedTturret.width,summonedTturret.height)
    table.insert(projectiles,summonedTturret)
    
    return summonedTturret
  end
  
  function tturret:update(summoned,dt) 
    local pos=summoned.sprite

    --On commence par mettre a jour l'éclair visuel au milieu de la tourelle
    local radius=12
    local x1,y1,x2,y2
    summoned.boltAngle=summoned.boltAngle+summoned.boltRotation*dt
    x1=summoned.x+0.5*summoned.width+math.cos(summoned.boltAngle)*radius
    y1=summoned.y+0.5*summoned.height+math.sin(summoned.boltAngle)*radius
    x2=summoned.x+0.5*summoned.width+math.cos(summoned.boltAngle+math.pi)*radius
    y2=summoned.y+0.5*summoned.height+math.sin(summoned.boltAngle+math.pi)*radius
    sparkles:updateSystem(summoned.bolt,x1,y1,x2,y2)
    
    --On commence par chercher et ajouter de nouvelles cibles
    local x1,y1,x2,y2,distance
    x1=summoned.x+0.5*summoned.width
    y1=summoned.y+0.5*summoned.height
    for i,element in ipairs(spawnedElements) do
      if element.x~=nil then
        distance=math.sqrt((x1-element.x)^2+(y1-element.y)^2)
      else
        distance=1000
      end
      if distance<150 and summoned.canInteract and element.attack~=nil and element.isOn~=nil then --On cherche aussi les boutons
        if element.attack=="tturret" then
          sparkles:newBoltSystem(x1,y1,element.x+0.5*element.width,element.y+0.5*element.height,2,1,{236/256,240/256,57/256},2)
          if element.isOn then 
            element.isOn=false
          else
            element.isOn=true
          end
          summoned.canInteract=false
        end
      end
    end
    
    for i,mob in ipairs(spawnedMobs) do
      x2=mob.x+0.5*mob.width
      y2=mob.y+0.5*mob.height
      distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
      if distance<100 and mob~=summoned and mob.faction~="player" then --Si l'autre mob est assez pres, ça devient une Target
        local alreadyTarget=false --On verifie qu'il est pas déja enregistré
        for j,target in ipairs(summoned.targets) do
          if target==mob then
            alreadyTarget=true
          end
        end
          
        if alreadyTarget==false then 
          table.insert(summoned.targets,mob) 
          if mob.bolt==nil then mob.bolt={} end
          mob.bolt[pos]=sparkles:newBoltSystem(x1,y1,x2,y2,2,1,{236/256,240/256,57/256},1)
        end
      end
    end
    --Puis on regarde les targets actuels, verifie qu'ils sont assez pret, puis update leurs éclairs,inflige des dommages
      
    for i,target in ipairs(summoned.targets) do
      x2=target.x+0.5*target.width
      y2=target.y+0.5*target.height
      distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
      if distance>100 or target.faction=="player" then
        sparkles:remove(target.bolt[pos])
        table.remove(summoned.targets,i)
      else
        target.life=target.life-1.2*dt
        if target.life<0 then
          sparkles:remove(target.bolt[pos])
        else
          --print("x2 ="..x2)
          sparkles:updateSystem(target.bolt[pos],x1,y1,x2,y2,nil,nil,nil,1)
        end
      end
    end
    
    --On baisse la vie de la tourelle
    summoned.life=summoned.life-2*dt

    if summoned.life<=0 then
      sparkles:remove(summoned.bolt)
      for i,target in ipairs(summoned.targets) do
        sparkles:remove(target.bolt[pos])
      end
      for i,cProjectile in ipairs(projectiles) do
        if summoned==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(summoned)
    end
  end
  
  --ATTAQUE SWORD
  sword={
    name="sword",
    dName="Joyau de la foudre",
    desc="Invoquer sur ce plan la légendaire épée du prince de la foudre, et donnez un puissant coup d'estoque aux ennemis qui s'approchent trop pres.",
    icon=love.graphics.newImage("sprites/icons/swordIcon.png"),
    anim={love.graphics.newImage("sprites/sword/00.png"),love.graphics.newImage("sprites/sword/01.png"),love.graphics.newImage("sprites/sword/02.png"),love.graphics.newImage("sprites/sword/03.png"),love.graphics.newImage("sprites/sword/04.png"),love.graphics.newImage("sprites/sword/05.png"),love.graphics.newImage("sprites/sword/06.png"),love.graphics.newImage("sprites/sword/07.png"),love.graphics.newImage("sprites/sword/08.png"),love.graphics.newImage("sprites/sword/09.png"),love.graphics.newImage("sprites/sword/10.png"),love.graphics.newImage("sprites/sword/11.png")},
    fps=24,
    lengths={3,5,6,9,13,18,19,20,20,20,20,20},
    height=14,
    width=14,
    cd=1,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false,
    hasDrawFunction=true,
  }

  --sword.width=sword.sprite:getWidth()
  --sword.height=sword.sprite:getHeight()
  
  function sword:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xPoint=player.x+0.5*player.width+0.65*(player.width+5)*math.cos(angle)
    local yPoint=player.y+0.5*player.height+0.65*(player.width+5)*math.sin(angle)
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(236/256,240/256,57/256,1,236/256,240/256,57/256,0)
    particleSystem.particles:setParticleLifetime(0,0.8)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    local spawnedSword={
      name="sword",
      x=xPoint,
      y=yPoint,
      x1=xPoint,
      y1=yPoint,
      x2=xPoint,
      y2=yPoint,
      brutframe=1,
      frame=1,
      length=0,
      life=0.8,
      angle=angle,
      player=player,
      hasDrawFunction=true,
    }

    table.insert(projectiles,spawnedSword)
  end
  
  function sword:update(projectile,dt)
    local mouseX,mouseY=love.mouse.getPosition()
    mouseX=(mouseX)/(zoom*sizeFactor)-translatex
    mouseY=(mouseY)/(zoom*sizeFactor)-translatey
    local player=projectile.player
    
    projectile.angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    
    projectile.brutframe=projectile.brutframe+sword.fps*dt
    projectile.frame=math.floor(projectile.brutframe)
    if projectile.frame>12 then projectile.frame=12 end
    projectile.length=sword.lengths[projectile.frame]
    
    projectile.x1=player.x+0.5*player.width+0.65*(player.width+5)*math.cos(projectile.angle)
    projectile.y1=player.y+0.5*player.height+0.65*(player.width+5)*math.sin(projectile.angle)
    projectile.x2=projectile.x1+projectile.length*math.cos(projectile.angle)
    projectile.y2=projectile.y1+projectile.length*math.sin(projectile.angle)
    
    local items, len = world:querySegment(projectile.x1,projectile.y1,projectile.x2,projectile.y2) --Regarde quels hitboxs touche la ligne de l'épée
    for i,item in ipairs(items) do
      if item.invcd~=nil then
        if item.invcd<0 then
          item.invcd=0.8
          item.life=item.life-1
          item.xSpeed=math.cos(projectile.angle)*300
          item.ySpeed=math.sin(projectile.angle)*300
        end
      end
    end
    
    projectile.life=projectile.life-dt
    if projectile.life<=0 then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
    end
  end
  
  function sword:draw(projectile)
    love.graphics.draw(sword.anim[projectile.frame],projectile.x1,projectile.y1,projectile.angle+math.pi/4,1,1,0,sword.height)
    --[[love.graphics.setColor(1,0,0)
    love.graphics.line(projectile.x1,projectile.y1,projectile.x2,projectile.y2)
    love.graphics.setColor(1,1,1)]]
  end
  
  --ATTAQUE SPEAR
  spear={
    name="spear",
    dName="Lance de Rhonas",
    desc="Invoquez au combat la lance de Rhonas, dont vous êtes désormais le gardien, et repoussez vos adversaires !",
    icon=love.graphics.newImage("sprites/icons/spearIcon.png"),
    anim={love.graphics.newImage("sprites/spear/00.png"),love.graphics.newImage("sprites/spear/01.png"),love.graphics.newImage("sprites/spear/02.png"),love.graphics.newImage("sprites/spear/03.png"),love.graphics.newImage("sprites/spear/04.png"),love.graphics.newImage("sprites/spear/05.png"),love.graphics.newImage("sprites/spear/06.png"),love.graphics.newImage("sprites/spear/07.png"),love.graphics.newImage("sprites/spear/08.png"),love.graphics.newImage("sprites/spear/09.png"),love.graphics.newImage("sprites/spear/10.png"),love.graphics.newImage("sprites/spear/11.png")},
    fps=24,
    lengths={3,5,6,9,13,18,19,20,20,20,20,20},
    height=14,
    width=14,
    cd=1,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false,
    hasDrawFunction=true,
  }

  --spear.width=spear.sprite:getWidth()
  --spear.height=spear.sprite:getHeight()
  
  function spear:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xPoint=player.x+0.5*player.width+0.65*(player.width+5)*math.cos(angle)
    local yPoint=player.y+0.5*player.height+0.65*(player.width+5)*math.sin(angle)
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(54/256,140/256,221/256,1,45/256,87/256,128/256,0)
    particleSystem.particles:setParticleLifetime(0,0.8)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    local spawnedSpear={
      name="spear",
      x=xPoint,
      y=yPoint,
      x1=xPoint,
      y1=yPoint,
      x2=xPoint,
      y2=yPoint,
      brutframe=1,
      frame=1,
      length=0,
      life=0.8,
      angle=angle,
      player=player,
      hasDrawFunction=true,
    }

    table.insert(projectiles,spawnedSpear)
  end
  
  function spear:update(projectile,dt)
    local mouseX,mouseY=love.mouse.getPosition()
    mouseX=(mouseX)/(zoom*sizeFactor)-translatex
    mouseY=(mouseY)/(zoom*sizeFactor)-translatey
    local player=projectile.player
    
    projectile.angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    
    projectile.brutframe=projectile.brutframe+spear.fps*dt
    projectile.frame=math.floor(projectile.brutframe)
    if projectile.frame>12 then projectile.frame=12 end
    projectile.length=spear.lengths[projectile.frame]
    
    projectile.x1=player.x+0.5*player.width+0.65*(player.width+5)*math.cos(projectile.angle)
    projectile.y1=player.y+0.5*player.height+0.65*(player.width+5)*math.sin(projectile.angle)
    projectile.x2=projectile.x1+projectile.length*math.cos(projectile.angle)
    projectile.y2=projectile.y1+projectile.length*math.sin(projectile.angle)
    
    local items, len = world:querySegment(projectile.x1,projectile.y1,projectile.x2,projectile.y2) --Regarde quels hitboxs touche la ligne de l'épée
    for i,item in ipairs(items) do
      if item.invcd~=nil then
        if item.invcd<0 then
          item.invcd=0.8
          item.life=item.life-1
          item.xSpeed=math.cos(projectile.angle)*300
          item.ySpeed=math.sin(projectile.angle)*300
        end
      end
    end
    
    projectile.life=projectile.life-dt
    if projectile.life<=0 then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
    end
  end
  
  function spear:draw(projectile)
    love.graphics.draw(spear.anim[projectile.frame],projectile.x1,projectile.y1,projectile.angle+math.pi/4,1,1,0,spear.height)
    --[[love.graphics.setColor(1,0,0)
    love.graphics.line(projectile.x1,projectile.y1,projectile.x2,projectile.y2)
    love.graphics.setColor(1,1,1)]]
  end
  
  --ATTAQUE ISPHERE
  isphere={
    name="isphere",
    dName="Sphere de glace",
    desc="Lancer une sphere de glace, qui rebondira jusqu'à trouver un ennemi auquel s'accrocher. Une fois accrochée, elle le ralentira considerablement.",
    icon=love.graphics.newImage("sprites/icons/isphereIcon.png"),
    sprite=love.graphics.newImage("sprites/isphere.png"),
    cd=5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false
  }

  isphere.width=isphere.sprite:getWidth()
  isphere.height=isphere.sprite:getHeight()
  
  function isphere:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=400*math.cos(angle)
    local ySpeed=400*math.sin(angle)
    local width=isphere.width
    local height=isphere.height
    local xPoint=player.x+0.5*player.width+0.65*(player.width+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(player.width+width)*math.sin(angle)-0.5*height
    
    
    local projectileIsphere={
      name="isphere",
      x=xPoint,
      y=yPoint,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      player=player,
      life=8,
      mobLinked=nil,
    }
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(iceParticle,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(236/255,255/256,250/255,1,0,1,1,0)
    particleSystem.particles:setParticleLifetime(0.2,1.2)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    world:add(projectileIsphere,projectileIsphere.x,projectileIsphere.y,projectileIsphere.width,projectileIsphere.height)
    table.insert(projectiles,projectileIsphere)
  end
  
  function isphere:update(projectile,dt)
    local cols,len
    if projectile~=nil and projectile.mobLinked==nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)

      for i,col in ipairs(cols) do
        if col.other.tangibility~=false then
          --Check une ligne allant de droite a gauche de la balle pour savoir si la collision vient horizontalement ou pas
          local items, len = world:querySegment(projectile.x-1,projectile.y+0.5*projectile.height,projectile.x+projectile.width+1,projectile.y+0.5*projectile.height)
          if len>1 then --C'est horizontale, inversion vitesse horizontale
            projectile.xSpeed=-projectile.xSpeed
          else --C'est vertical, inversion vitesse verticale
            projectile.ySpeed=-projectile.ySpeed
          end
          projectile.life=projectile.life-1
          if col.other.life~=nil and col.other.frozen~=true then
            if col.other.isMob then --Se Link au premier mob touché
              projectile.mobLinked=col.other --Et devient invisible et intangible
              col.other.spd=col.other.spd*0.5
              --col.other.frozen=true
              --Puis fait des particles
              projectile.particles=love.graphics.newParticleSystem(iceParticle,200)
              projectile.particles:setEmissionArea("uniform",0.5*col.other.width,0.5*col.other.height,0,true)
              projectile.particles:setLinearAcceleration(-50,-50,50,50)
              projectile.particles:setColors(236/255,255/256,250/255,1,0,1,1,0)
              projectile.particles:setParticleLifetime(0.2,1.2)
              --projectile.particles:emit(200)
              projectile.particlesx=col.other.x+0.5*col.other.width
              projectile.particlesy=col.other.y+0.5*col.other.height
              
              projectile.color={1,1,1,0} 
              projectile.tangibility=false
              if projectile.player.faction~=col.other.faction then
                col.other.target=projectile.player
              end
              if projectile.life>5 then projectile.life=5 end
            else
              col.other.life=col.other.life-1
              col.other.invcd=0.2
            end
          end    
        
          --Laisse des petites particules 
          local particleSystem={}
          particleSystem.particles=love.graphics.newParticleSystem(iceParticle,50)
          particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
          --Ancienne couleurs : (236/255,255/256,250/255,1,192/255,217/256,211/255,1,122/255,139/255,134/256,0)
          particleSystem.particles:setColors(236/255,255/256,250/255,1,0,1,1,0)
          particleSystem.particles:setParticleLifetime(0.2,1.2)
          particleSystem.particles:emit(50)
          particleSystem.x=col.touch.x
          particleSystem.y=col.touch.y
          table.insert(particlesSystems,particleSystem)
      
          --Un peu de screenshake aussi
          shakingTime=0.05
    
          break --On sort de la boucle
        end
      end
    elseif projectile.mobLinked~=nil then --Si le projectile est deja lié on baisse la vie du projectile
      --On fait les particles
      --projectile.mobLinked.iceParticles:emit(200)
      if projectile.particles~=nil then
        projectile.particles:emit(100*dt)
        projectile.particles:update(dt)
        projectile.x=projectile.mobLinked.x+0.5*projectile.mobLinked.width
        projectile.y=projectile.mobLinked.y+0.5*projectile.mobLinked.height
        projectile.particlesx=0
        projectile.particlesy=0
      end
      
      if projectile.mobLinked.faction=="player" then
        projectile.life=0
      end
      
      --Et enfin, on blesse le projectile 
      projectile.life=projectile.life-dt
    end
    
    local condition=false
    if projectile.mobLinked~=nil then condition=projectile.mobLinked.life<=0 end
    if projectile.life<=0 or condition then
      if projectile.mobLinked~=nil then
        projectile.mobLinked.spd=projectile.mobLinked.spd/0.5
        projectile.mobLinked.frozen=false
      end
      
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(projectile)
    end
  end
  
   --ATTAQUE ITURRET
  iturret={
    name="iturret",
    dName="Tourelle de glace",
    desc="Batissez une tourelle qui invoque le pouvoir de la glace pour ralentir vos adversaires.",
    icon=love.graphics.newImage("sprites/icons/iturretIcon.png"),
    sprite=love.graphics.newImage("sprites/iturret.png"),
    cd=40,
    currentcd=0,
    cost=0,--60,
    range=100,
    atype="summon",
    autoupdate=false, 
    hasDrawFunction=true,
    --hasDrawFunction=true,
  }

  iturret.width=iturret.sprite:getWidth()
  iturret.height=iturret.sprite:getHeight()
  
  function iturret:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local width=iturret.width
    local height=iturret.height
    local xPoint=mouseX-0.5*width
    local yPoint=mouseY-0.5*height
    
    
    local summonedIturret={
      name="iturret",
      x=xPoint,
      y=yPoint,
      width=width,
      height=height,
      faction="player",
      life=60,
      range=200,
      targets={}, --Une fois lié, il ajoute a ses cibles les mobs voisins
      foreground=true,
      canInteract=true, --Ne peut interagir qu'avec un bouton, de toute sa vie
      tangibility=false,
      hasDrawFunction=true,
      sprite=iturret.sprite,
    }
    local angle=math.random(314)/100
    local radius=12
    local x1,y1,x2,y2
    x1=mouseX+math.cos(angle)*radius
    y1=mouseY+math.sin(angle)*radius
    x2=mouseX+math.cos(angle+math.pi)*radius
    y2=mouseY+math.sin(angle+math.pi)*radius
    
    summonedIturret.coreParticles=love.graphics.newParticleSystem(iceParticle,50)
    summonedIturret.coreParticles:setEmissionArea("ellipse",0.3*summonedIturret.width,0.3*summonedIturret.height,0,true)
    summonedIturret.coreParticles:setLinearAcceleration(0,0,0,0)
    summonedIturret.coreParticles:setColors(236/255,255/256,250/255,1,192/255,217/256,211/255,1,122/255,139/255,134/256,1)
    summonedIturret.coreParticles:setParticleLifetime(0.2,1.2)
    summonedIturret.coreParticles:setTangentialAcceleration(-20,20)
    summonedIturret.coreParticles:setSpinVariation(1)
      
    world:add(summonedIturret,summonedIturret.x,summonedIturret.y,summonedIturret.width,summonedIturret.height)
    table.insert(projectiles,summonedIturret)
    
    return summonedIturret
  end
  
  function iturret:update(summoned,dt) 
    local pos=summoned.sprite

    --On update les core particles
    summoned.coreParticles:emit(80*dt)
    summoned.coreParticles:update(dt)
    --On commence par chercher et ajouter de nouvelles cibles
    local x1,y1,x2,y2,distance
    x1=summoned.x+0.5*summoned.width
    y1=summoned.y+0.5*summoned.height
    for i,element in ipairs(spawnedElements) do
      if element.x~=nil then
        distance=math.sqrt((x1-element.x)^2+(y1-element.y)^2)
      else
        distance=1000
      end
      if distance<summoned.range and summoned.canInteract and element.attack~=nil and element.isOn~=nil then --On cherche aussi les boutons
        if element.attack=="iturret" then
          --AJOUTER UN RAYON ICI
          if element.isOn then 
            element.isOn=false
          else
            element.isOn=true
          end
          summoned.canInteract=false
        end
      end
    end
    
    for i,mob in ipairs(spawnedMobs) do
      x2=mob.x+0.5*mob.width
      y2=mob.y+0.5*mob.height
      distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
      if distance<summoned.range and mob~=summoned and mob.faction~="player" then --Si l'autre mob est assez pres, ça devient une Target
        local alreadyTarget=false --On verifie qu'il est pas déja enregistré
        for j,target in ipairs(summoned.targets) do
          if target==mob then
            alreadyTarget=true
          end
        end
          
        if alreadyTarget==false then 
          table.insert(summoned.targets,mob) 
          mob.spd=0.5*mob.spd
          --mob.frozen=true
          mob.iceParticles=love.graphics.newParticleSystem(iceParticle,200)
          mob.iceParticles:setEmissionArea("uniform",0.5*mob.width,0.5*mob.height,0,true)
          mob.iceParticles:setLinearAcceleration(-50,-50,50,50)
          mob.iceParticles:setColors(236/255,255/256,250/255,1,0,1,1,0)
          mob.iceParticles:setParticleLifetime(0.2,1.2)
          --mob.iceParticlesx=0.5*mob.width
         -- mob.iceParticlesy=0.5*mob.height
         if mob.rayParticles==nil then 
            mob.rayParticles={} 
            mob.rayLength={}
            mob.rayAngle={}
            mob.rayCenterX={}
            mob.rayCenterY={}
          end
          mob.rayParticles[pos]=love.graphics.newParticleSystem(iceParticle,200)
          mob.rayLength[pos]=math.sqrt((x1-x2)^2+(y1-y2)^2)
          mob.rayAngle[pos]=math.atan2(y2-y1,x2-x1)
          mob.rayParticles[pos]:setEmissionArea("uniform",0.5*mob.rayLength[pos],2,0,true)
          mob.rayParticles[pos]:setLinearAcceleration(50,-5,100,5)
          mob.rayParticles[pos]:setColors(236/255,255/256,250/255,1,0,1,1,0)
          mob.rayParticles[pos]:setParticleLifetime(0.5,1.5)
          --RAYON ICI
        end
      end
    end
    --Puis on regarde les targets actuels, verifie qu'ils sont assez pret, puis update leurs particules, 
      
    for i,target in ipairs(summoned.targets) do
      x2=target.x+0.5*target.width
      y2=target.y+0.5*target.height
      distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
      if distance>summoned.range or target.faction=="player" then
        target.spd=target.spd/0.5
        target.frozen=false
        table.remove(summoned.targets,i)
      else
        if target.life<0 then
          table.remove(summoned.targets,i)
          break;
        else
          --On update les particules
          target.iceParticles:emit(100*dt)
          target.iceParticles:update(dt)
          
          target.rayLength[pos]=math.sqrt((x1-x2)^2+(y1-y2)^2)
          target.rayAngle[pos]=math.atan2(y2-y1,x2-x1)
          target.rayCenterX[pos]=0.5*(x1+x2)
          target.rayCenterY[pos]=0.5*(y1+y2)
          target.rayParticles[pos]:setEmissionArea("uniform",0.5*target.rayLength[pos],2,0,true)
          target.rayParticles[pos]:emit(100*dt)
          target.rayParticles[pos]:update(dt)
          --RAYON ICI
        end
      end
    end
    
    --On baisse la vie de la tourelle
    summoned.life=summoned.life-2*dt

    if summoned.life<=0 then
      --RAYONS ICI
      for i,target in ipairs(summoned.targets) do
        target.spd=target.spd/0.5
        target.frozen=false
      end
      
      for i,cProjectile in ipairs(projectiles) do
        if summoned==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(summoned)
    end
  end
  
  function iturret:draw(summoned) 
    --On dessine d'abord les coreParticles
    love.graphics.draw(summoned.coreParticles,summoned.x+0.5*summoned.width,summoned.y+0.5*summoned.height)
    love.graphics.draw(summoned.sprite,summoned.x,summoned.y)
    
    local pos=summoned.sprite
    
    --Puis les particules de chaque target
    for i,target in ipairs(summoned.targets) do
      if target.life>0 then
        love.graphics.draw(target.iceParticles,target.x+0.5*target.width,target.y+0.5*target.height)
        
        love.graphics.draw(target.rayParticles[pos],target.rayCenterX[pos],target.rayCenterY[pos],target.rayAngle[pos])
      end
    end
    
  end
  
  --ATTAQUE GRAPLING GREEN FIRE
  grapling={
    name="grapling",
    dName="Liane de flammes vertes du Roi Citrouille",
    desc="Déployez les lianes de feu vert du Roi Citrouille, Dieu païen de Kalahroch, saisissez un ennemi et projetez vous vers lui, survolant précicipice, feux de camps et flaques d'acides pour lui foutre votre pied dans sa tronche.",
    icon=love.graphics.newImage("sprites/icons/graplingIcon.png"),
    --sprite=love.graphics.newImage("sprites/ssphere.png"),
    cd=2.5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false
  }

  grapling.width=10--grapling.sprite:getWidth()
  grapling.height=10--grapling.sprite:getHeight()
  
  function grapling:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=300*math.cos(angle)
    local ySpeed=300*math.sin(angle)
    local width=grapling.width
    local height=grapling.height
    local xPoint=player.x+0.5*player.width+0.65*(player.width+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(player.width+width)*math.sin(angle)-0.5*height
    
    
    local projectileGrapling={
      name="grapling",
      x=xPoint,
      y=yPoint,
      x2=xPoint,
      y2=yPoint,
      pullingAngle=0,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      player=player,
      life=1,
      linked=nil,
    }
    
    projectileGrapling.bolt=sparkles:newBoltSystem(xPoint,yPoint,xPoint,yPoint,4,2,{{15/255,60/255,11/255},{59/255,222/255,45/255}},20,0,nil,5,10,10)
    
    world:add(projectileGrapling,projectileGrapling.x,projectileGrapling.y,projectileGrapling.width,projectileGrapling.height)
    table.insert(projectiles,projectileGrapling)
  end
  
  function grapling:update(projectile,dt)
    shakingTime=0.2
    local cols,len
    if projectile~=nil and projectile.linked==nil then
      --On descend un peu la vie, qu'il aille pas partout non plus
      projectile.life=projectile.life-0.3*dt
      --On update le boltSystem
      local x1,y1,x2,y2
      x2=projectile.x+0.5*projectile.width
      y2=projectile.y+0.5*projectile.height
      x1=projectile.player.x+0.5*projectile.player.width+0.65*(projectile.player.width+projectile.width)*math.cos(projectile.angle)-0.5*projectile.width
      y1=projectile.player.y+0.5*projectile.player.height+0.65*(projectile.player.width+projectile.width)*math.sin(projectile.angle)-0.5*projectile.height
      sparkles:updateSystem(projectile.bolt,x1,y1,x2,y2)
      
      --On regarde les collisions
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)

      for i,col in ipairs(cols) do
        if col.other.life~=nil and col.other.width~=nil and col.other.faction~=projectile.player.faction then --Se link au premier enemi touché
          projectile.x1=col.other.x+0.5*col.other.width
          projectile.y1=col.other.y+0.5*col.other.height
          projectile.linked=col.other --Et devient invisible et intangible
          projectile.color={1,1,1,0} 
          projectile.tangibility=false
          if projectile.player.faction~=col.other.faction then
            col.other.target=projectile.player
          end
          projectile.life=2
        end
        
        if col.other.tangibility~=false then
          --Check une ligne allant de droite a gauche de la balle pour savoir si la collision vient horizontalement ou pas
          local items, len = world:querySegment(projectile.x-1,projectile.y+0.5*projectile.height,projectile.x+projectile.width+1,projectile.y+0.5*projectile.height)
          if len>1 then --C'est horizontale, inversion vitesse horizontale
            projectile.xSpeed=-projectile.xSpeed
          else --C'est vertical, inversion vitesse verticale
            projectile.ySpeed=-projectile.ySpeed
          end
      
          projectile.life=projectile.life-1
      
          --Un peu de screenshake aussi
          shakingTime=0.05
    
          break --On sort de la boucle
        end
      end
    elseif projectile.linked~=nil then --Si le projectile est deja lié on se tire vers le mob linké
      local angle=math.atan2(projectile.linked.x-projectile.player.x,projectile.linked.y-projectile.player.y)
      --local angle=math.atan2(projectile.x2-projectile.x1,projectile.y2-projectile.y1)
      local xSpeed=math.sin(angle)*500
      local ySpeed=math.cos(angle)*500
      local distBefore=math.sqrt((projectile.linked.x-projectile.player.x)^2+(projectile.linked.y-projectile.player.y)^2)
      
      projectile.player.transportcd=0.1
      local cols,len
      if projectile.linked.life>0 then
        projectile.player.x,projectile.player.y,cols,len=world:move(projectile.player,projectile.player.x+xSpeed*dt,projectile.player.y+ySpeed*dt,colcheck)
        for j,col in ipairs(cols) do
          if col.other==projectile.linked then 
            projectile.life=0
            projectile.linked.life=projectile.linked.life-1
            projectile.linked.invcd=0.5
          end
        end
      end
      
      
      --On update le boltSystem
      local x1,y1,x2,y2
      x2=projectile.linked.x+0.5*projectile.linked.width
      y2=projectile.linked.y+0.5*projectile.linked.height
      x1=projectile.player.x+0.5*projectile.player.width+0.65*(projectile.player.width+projectile.linked.width)*math.cos(projectile.angle)-0.5*projectile.linked.width
      y1=projectile.player.y+0.5*projectile.player.height+0.65*(projectile.player.width+projectile.linked.width)*math.sin(projectile.angle)-0.5*projectile.linked.height
      sparkles:updateSystem(projectile.bolt,x1,y1,x2,y2)
      
      --Et enfin, on blesse le projectile 
      projectile.life=projectile.life-dt
    end
    
    local condition=false
    if projectile.linked~=nil then condition=projectile.linked.life<=0 end
    if projectile.life<=0 or condition then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      sparkles:remove(projectile.bolt)
      world:remove(projectile)
    end
  end
  
  --ATTAQUE PULLSPHERE ATTRACTION TELEKINESIE
  pullsphere={
    name="pullsphere",
    dName="Attraction telekinetique",
    desc="Attirez a vous les chaises, tourelles, monstres, bébés congelés et autres objets en tout genre !",
    icon=love.graphics.newImage("sprites/icons/pullsphereIcon.png"),
    sprite=love.graphics.newImage("sprites/ssphere.png"),
    cd=2.5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false
  }

  pullsphere.width=pullsphere.sprite:getWidth()
  pullsphere.height=pullsphere.sprite:getHeight()
  
  function pullsphere:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=800*math.cos(angle)
    local ySpeed=800*math.sin(angle)
    local width=pullsphere.width
    local height=pullsphere.height
    local xPoint=player.x+0.5*player.width+0.65*(player.width+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(player.width+width)*math.sin(angle)-0.5*height
    
    
    local projectileIsphere={
      name="pullsphere",
      x=xPoint,
      y=yPoint,
      x2=xPoint,
      y2=yPoint,
      pullingAngle=0,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      player=player,
      life=1,
      linked=nil,
    }
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(0,1,1,1,236/255,255/256,250/255,0)
    particleSystem.particles:setParticleLifetime(0.2,1.2)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    world:add(projectileIsphere,projectileIsphere.x,projectileIsphere.y,projectileIsphere.width,projectileIsphere.height)
    table.insert(projectiles,projectileIsphere)
  end
  
  function pullsphere:update(projectile,dt)
    local cols,len
    if projectile~=nil and projectile.linked==nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)

      for i,col in ipairs(cols) do
        if col.other.life~=nil and col.other.width~=nil then --Se link au premier truc touché
          projectile.x1=col.other.x+0.5*col.other.width
          projectile.y1=col.other.y+0.5*col.other.height
          projectile.linked=col.other --Et devient invisible et intangible
          projectile.color={1,1,1,0} 
          projectile.tangibility=false
          if projectile.player.faction~=col.other.faction then
            col.other.target=projectile.player
          end
          projectile.life=2
        end
        
        if col.other.tangibility~=false then
          --Check une ligne allant de droite a gauche de la balle pour savoir si la collision vient horizontalement ou pas
          local items, len = world:querySegment(projectile.x-1,projectile.y+0.5*projectile.height,projectile.x+projectile.width+1,projectile.y+0.5*projectile.height)
          if len>1 then --C'est horizontale, inversion vitesse horizontale
            projectile.xSpeed=-projectile.xSpeed
          else --C'est vertical, inversion vitesse verticale
            projectile.ySpeed=-projectile.ySpeed
          end
      
          projectile.life=projectile.life-1
        
          --Laisse des petites particules 
          local particleSystem={}
          particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
          particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
          --Ancienne couleurs : (236/255,255/256,250/255,1,192/255,217/256,211/255,1,122/255,139/255,134/256,0)
          particleSystem.particles:setColors(0,1,1,1,236/255,255/256,250/255,0)
          particleSystem.particles:setParticleLifetime(0.2,1.2)
          particleSystem.particles:emit(50)
          particleSystem.x=col.touch.x
          particleSystem.y=col.touch.y
          table.insert(particlesSystems,particleSystem)
      
          --Un peu de screenshake aussi
          shakingTime=0.05
    
          break --On sort de la boucle
        end
      end
    elseif projectile.linked~=nil then --Si le projectile est deja lié on attire le projectile
      local angle=math.atan2(projectile.player.x-projectile.linked.x,projectile.player.y-projectile.linked.y)
      --local angle=math.atan2(projectile.x2-projectile.x1,projectile.y2-projectile.y1)
      local xSpeed=math.sin(angle)*500
      local ySpeed=math.cos(angle)*500
      local distBefore=math.sqrt((projectile.linked.x-projectile.player.x)^2+(projectile.linked.y-projectile.player.y)^2)
      
      local cols,len
      if projectile.linked.life>0 then
        projectile.linked.x,projectile.linked.y,cols,len=world:move(projectile.linked,projectile.linked.x+xSpeed*dt,projectile.linked.y+ySpeed*dt,colcheck)
        for j,col in ipairs(cols) do
          if col.other==projectile.player then 
            projectile.life=0
          end
        end
      end
      
      --Et enfin, on blesse le projectile 
      projectile.life=projectile.life-dt
    end
    
    local condition=false
    if projectile.linked~=nil then condition=projectile.linked.life<=0 end
    if projectile.life<=0 or condition then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(projectile)
    end
  end
  
    --ATTAQUE PUSHSPHERE REPULSION TELEKINESIE
  pushsphere={
    name="pushsphere",
    dName="Repulsion telekinetique",
    desc="Les gens s'approchent trop pres de vous, vous en avez marre de ne pas rendre vos adversaires tetraplegique à la balle au prisonnier ? Alors j'ai LA solution pour vous ! Avec la repulsion telekinetique, vous pouvez repousser loins tout ce que vous voulez ! Et avec la vitesse d'une balle de fusil ! Qu'est-ce qu'une balle de fusil ? Mais je n'en ai pas la moindre idée ! Disons plutot un carreau d'arbalete alors, c'est plus raccord avec le theme Heroic Fantasy.",
    icon=love.graphics.newImage("sprites/icons/pushsphereIcon.png"),
    sprite=love.graphics.newImage("sprites/ssphere.png"),
    cd=5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false
  }

  pushsphere.width=pushsphere.sprite:getWidth()
  pushsphere.height=pushsphere.sprite:getHeight()
  
  function pushsphere:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=400*math.cos(angle)
    local ySpeed=400*math.sin(angle)
    local width=pushsphere.width
    local height=pushsphere.height
    local xPoint=player.x+0.5*player.width+0.65*(player.width+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(player.width+width)*math.sin(angle)-0.5*height
    
    
    local projectilePushSphere={
      name="pushsphere",
      x=xPoint,
      y=yPoint,
      x2=xPoint,
      y2=yPoint,
      pullingAngle=0,
      angle=angle,
      width=width,
      portalcd=0,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      player=player,
      life=1,
    }
    
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
    particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
    particleSystem.particles:setColors(0,1,1,1,236/255,255/256,250/255,0)
    particleSystem.particles:setParticleLifetime(0.2,1.2)
    particleSystem.particles:emit(50)
    particleSystem.x=xPoint
    particleSystem.y=yPoint
    table.insert(particlesSystems,particleSystem)
    
    world:add(projectilePushSphere,projectilePushSphere.x,projectilePushSphere.y,projectilePushSphere.width,projectilePushSphere.height)
    table.insert(projectiles,projectilePushSphere)
  end
  
  function pushsphere:update(projectile,dt)
    local cols,len
    if projectile~=nil and projectile.linked==nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)
      for i,col in ipairs(cols) do
        if col.other.life~=nil and col.other.width~=nil then --Se Link au premier truc
          projectile.x1=col.other.x+0.5*col.other.width
          projectile.y1=col.other.y+0.5*col.other.height
          projectile.linked=col.other --Et devient invisible et intangible
          projectile.color={1,1,1,0} 
          projectile.tangibility=false
          if projectile.player.faction~=col.other.faction then
            col.other.target=projectile.player
          end
          projectile.life=0.4 
        end    
          
        if col.other.tangibility~=false and projectile.linked==nil then
          --Check une ligne allant de droite a gauche de la balle pour savoir si la collision vient horizontalement ou pas
          local items, len = world:querySegment(projectile.x-1,projectile.y+0.5*projectile.height,projectile.x+projectile.width+1,projectile.y+0.5*projectile.height)
          if len>1 then --C'est horizontale, inversion vitesse horizontale
            projectile.xSpeed=-projectile.xSpeed
          else --C'est vertical, inversion vitesse verticale
            projectile.ySpeed=-projectile.ySpeed
          end
      
          projectile.life=projectile.life-1
        
          --Laisse des petites particules 
          local particleSystem={}
          particleSystem.particles=love.graphics.newParticleSystem(particleSprite,50)
          particleSystem.particles:setLinearAcceleration(-50,-50,50,50)
          --Ancienne couleurs : (236/255,255/256,250/255,1,192/255,217/256,211/255,1,122/255,139/255,134/256,0)
          particleSystem.particles:setColors(0,1,1,1,236/255,255/256,250/255,0)
          particleSystem.particles:setParticleLifetime(0.2,1.2)
          particleSystem.particles:emit(50)
          particleSystem.x=col.touch.x
          particleSystem.y=col.touch.y
          table.insert(particlesSystems,particleSystem)
      
          --Un peu de screenshake aussi
          shakingTime=0.05
    
          break --On sort de la boucle
        end
      end
    elseif projectile.linked~=nil then --Si le projectile est deja lié on attire le projectile
      local angle=projectile.angle
      --local angle=math.atan2(projectile.x2-projectile.x1,projectile.y2-projectile.y1)
      local xSpeed=math.cos(angle)*800
      local ySpeed=math.sin(angle)*800
      local distBefore=math.sqrt((projectile.linked.x-projectile.player.x)^2+(projectile.linked.y-projectile.player.y)^2)
      
      local cols,len
      projectile.linked.x,projectile.linked.y,cols,len=world:move(projectile.linked,projectile.linked.x+xSpeed*dt,projectile.linked.y+ySpeed*dt,colcheck)
      
      --Et enfin, on blesse le projectile 
      projectile.life=projectile.life-dt
    end
    
    local condition=false
    if projectile.linked~=nil then condition=projectile.linked.life<=0 end
    if projectile.life<=0 or condition then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(projectile)
    end
  end
  
  --ATTAQUE HTURRET
  hturret={
    name="hturret",
    dName="Tourelle de soin",
    desc="Batissez une tourelle qui invoque le pouvoir guérisseur de Pordrack pour vous guérir vous, vos alliés, et votre équipement",
    icon=love.graphics.newImage("sprites/icons/hturretIcon.png"),
    sprite=love.graphics.newImage("sprites/hturret.png"),
    cd=45,
    currentcd=0,
    cost=0,--60,
    range=100,
    atype="summon",
    autoupdate=false, 
    hasDrawFunction=true,
    --hasDrawFunction=true,
  }

  hturret.width=hturret.sprite:getWidth()
  hturret.height=hturret.sprite:getHeight()
  
  function hturret:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local width=hturret.width
    local height=hturret.height
    local xPoint=mouseX-0.5*width
    local yPoint=mouseY-0.5*height
    
    
    local summonedHturret={
      name="hturret",
      x=xPoint,
      y=yPoint,
      width=width,
      height=height,
      faction="player",
      life=5000,--Tkt frer c pour test 50,
      range=100,
      targets={}, --Une fois lié, il ajoute a ses cibles les mobs voisins
      foreground=true,
      canInteract=true, --Ne peut interagir qu'avec un bouton, de toute sa vie
      tangibility=false,
      hasDrawFunction=true,
      sprite=hturret.sprite,
    }
    local angle=math.random(314)/100
    local radius=12
    local x1,y1,x2,y2
    x1=mouseX+math.cos(angle)*radius
    y1=mouseY+math.sin(angle)*radius
    x2=mouseX+math.cos(angle+math.pi)*radius
    y2=mouseY+math.sin(angle+math.pi)*radius
    
    summonedHturret.coreParticles=love.graphics.newParticleSystem(heartParticle,50)
    summonedHturret.coreParticles:setEmissionArea("ellipse",0.3*summonedHturret.width,0.3*summonedHturret.height,0,true)
    summonedHturret.coreParticles:setLinearAcceleration(0,0,0,0)
    summonedHturret.coreParticles:setColors(1,0,0,1,255/255,108/256,108/255,0)
    summonedHturret.coreParticles:setParticleLifetime(0.2,1.2)
    summonedHturret.coreParticles:setTangentialAcceleration(-20,20)
    summonedHturret.coreParticles:setSpinVariation(1)
      
    world:add(summonedHturret,summonedHturret.x,summonedHturret.y,summonedHturret.width,summonedHturret.height)
    table.insert(projectiles,summonedHturret)
    
    return summonedHturret
  end
  
  function hturret:update(summoned,dt) 
    local pos=summoned.sprite
    --On update les core particles
    summoned.coreParticles:emit(80*dt)
    summoned.coreParticles:update(dt)
    --On commence par chercher et ajouter de nouvelles cibles
    local pTargets={}
    local x1,y1,x2,y2,distance
    x1=summoned.x+0.5*summoned.width
    y1=summoned.y+0.5*summoned.height
    for i,element in ipairs(spawnedElements) do
      if element.x~=nil then
        distance=math.sqrt((x1-element.x)^2+(y1-element.y)^2)
      else
        distance=1000
      end
      if distance<summoned.range and summoned.canInteract and element.attack~=nil and element.isOn~=nil then --On cherche aussi les boutons
        if element.attack=="iturret" then
          --AJOUTER UN RAYON ICI
          if element.isOn then 
            element.isOn=false
          else
            element.isOn=true
          end
          summoned.canInteract=false
        end
      end
      
      table.insert(pTargets,element)
    end
    
    for i,player in ipairs(players) do
      table.insert(pTargets,player)
    end
    
    for i,mob in ipairs(spawnedMobs) do
      table.insert(pTargets,mob)
    end
    
    for i,projectile in ipairs(projectiles) do
      table.insert(pTargets,projectile)
      --[[if projectile==summoned then
        pos=i
      end]]
    end
    
    for i,pTarget in ipairs(pTargets) do
      if pTarget.width~=nil then
        x2=pTarget.x+0.5*pTarget.width
        y2=pTarget.y+0.5*pTarget.height
        distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
        if distance<summoned.range and pTarget~=summoned and pTarget.faction==summoned.faction and pTarget.life~=nil then --Si l'autre mob est assez pres, ça devient une Target
          local alreadyTarget=false --On verifie qu'il est pas déja enregistré
          for j,target in ipairs(summoned.targets) do
            if target==pTarget then
              alreadyTarget=true
            end
          end
          
          if alreadyTarget==false then 
            table.insert(summoned.targets,pTarget) 
            pTarget.heartParticles=love.graphics.newParticleSystem(heartParticle,15)
            pTarget.heartParticles:setEmissionArea("uniform",0.5*pTarget.width,0.5*pTarget.height,0,true)
            pTarget.heartParticles:setLinearAcceleration(-50,-50,50,50)
            pTarget.heartParticles:setColors(1,0,0,1,255/255,108/256,108/255,0)
            pTarget.heartParticles:setSpinVariation(1)
            pTarget.heartParticles:setRotation(0,2*math.pi)
            pTarget.heartParticles:setParticleLifetime(0.2,1.2)
            --mob.iceParticlesx=0.5*mob.width
            -- mob.iceParticlesy=0.5*mob.height
            if pTarget.rayParticles==nil then 
              pTarget.rayParticles={} 
              pTarget.rayLength={}
              pTarget.rayAngle={}
              pTarget.rayCenterX={}
              pTarget.rayCenterY={}
            end
            pTarget.rayParticles[pos]=love.graphics.newParticleSystem(heartParticle,15)
            pTarget.rayLength[pos]=math.sqrt((x1-x2)^2+(y1-y2)^2)
            pTarget.rayAngle[pos]=math.atan2(y2-y1,x2-x1)
            pTarget.rayParticles[pos]:setEmissionArea("uniform",0.5*pTarget.rayLength[pos],2,0,true)
            pTarget.rayParticles[pos]:setLinearAcceleration(50,-5,100,5)
            pTarget.rayParticles[pos]:setColors(1,0,0,1,255/255,108/256,108/255,0)
            pTarget.rayParticles[pos]:setSpinVariation(1)
            pTarget.rayParticles[pos]:setRotation(0,2*math.pi)
            pTarget.rayParticles[pos]:setParticleLifetime(0.5,1.5)
          --RAYON ICI
          end
        end
      end
    end
    
    --Puis on regarde les targets actuels, verifie qu'ils sont assez pret, puis update leurs particules, 
      
    for i,target in ipairs(summoned.targets) do
      x2=target.x+0.5*target.width
      y2=target.y+0.5*target.height
      distance=math.sqrt((x1-x2)^2+(y1-y2)^2)
      if distance>summoned.range then
        table.remove(summoned.targets,i)
      else
        if target.life<0 then
          table.remove(summoned.targets,i)
          break;
        else
          --On update les particules
          target.heartParticles:emit(60*dt)
          target.heartParticles:update(dt)
          target.rayLength[pos]=math.sqrt((x1-x2)^2+(y1-y2)^2)
          target.rayAngle[pos]=math.atan2(y2-y1,x2-x1)
          target.rayCenterX[pos]=0.5*(x1+x2)
          target.rayCenterY[pos]=0.5*(y1+y2)
          target.rayParticles[pos]:setEmissionArea("uniform",0.5*target.rayLength[pos],2,0,true)
          target.rayParticles[pos]:emit(60*dt)
          target.rayParticles[pos]:update(dt)
          --ET ON SOIGNE LA CIBLE
          target.life=target.life+0.75*dt
          if target.maxlife~=nil then
            if target.life>target.maxlife then target.life=target.maxlife end
          end
        end
      end
    end
    
    --On baisse la vie de la tourelle
    summoned.life=summoned.life-2*dt

    if summoned.life<=0 then  
      for i,cProjectile in ipairs(projectiles) do
        if summoned==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(summoned)
    end
  end
  
  function hturret:draw(summoned) 
    local pos=summoned.sprite
    --[[for i,projectile in ipairs(projectiles) do
      if projectile==summoned then pos=i end
    end]]
    --On dessine d'abord les coreParticles
    love.graphics.draw(summoned.coreParticles,summoned.x+0.5*summoned.width,summoned.y+0.5*summoned.height)
    love.graphics.draw(summoned.sprite,summoned.x,summoned.y)
    
    --Puis les particules de chaque target
    for i,target in ipairs(summoned.targets) do
      if target.life>0 then
        love.graphics.draw(target.heartParticles,target.x+0.5*target.width,target.y+0.5*target.height)
        
        love.graphics.draw(target.rayParticles[pos],target.rayCenterX[pos],target.rayCenterY[pos],target.rayAngle[pos])
      end
    end
  end
  
  --ATTAQUE MTURRET
  mturret={
    name="mturret",
    dName="Tourelle arcaniquement métamorphe",
    desc="Batissez une tourelle qui, apres avoir scannée son environnement, répliquera la magie d'une voisine, ou, si elle n'en a pas, d'une des 3 autres tourelles de maniere aléatoire",
    icon=love.graphics.newImage("sprites/icons/mturretIcon.png"),
    sprite=love.graphics.newImage("sprites/mturret.png"),
    cd=50,
    currentcd=0,
    cost=0,--60,
    range=100,
    atype="summon",
    autoupdate=false, 
    --hasDrawFunction=true,
  }

  mturret.width=mturret.sprite:getWidth()
  mturret.height=mturret.sprite:getHeight()
  
  function mturret:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local width=mturret.width
    local height=mturret.height
    local xPoint=mouseX-0.5*width
    local yPoint=mouseY-0.5*height
    
    
    local summonedHturret={
      name="mturret",
      x=xPoint,
      y=yPoint,
      width=width,
      height=height,
      faction="player",
      player=player,
      life=nil,
      time=5,
      range=100,
      foreground=true,
      tangibility=false,
      sprite=mturret.sprite,
    }
    
      
    world:add(summonedHturret,summonedHturret.x,summonedHturret.y,summonedHturret.width,summonedHturret.height)
    table.insert(projectiles,summonedHturret)
    
    return summonedHturret
  end
  
  function mturret:update(summoned,dt) 
    local turretToCopy=nil
    for i,projectile in ipairs(projectiles) do
      if projectile.name=="tturret" then turretToCopy=tturret end
      if projectile.name=="iturret" then turretToCopy=iturret end
      if projectile.name=="hturret" then turretToCopy=hturret end
    end
    
    summoned.time=summoned.time-dt
    
    if summoned.time<=0 then
      local rng=math.random(1,3)
      if rng==1 then turretToCopy=tturret end 
      if rng==2 then turretToCopy=iturret end 
      if rng==3 then turretToCopy=hturret end 
    end
    
    if turretToCopy~=nil then  
      local mouseX=summoned.x+0.5*summoned.width
      local mouseY=summoned.y+0.5*summoned.height
      for i,cProjectile in ipairs(projectiles) do
        if summoned==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(summoned)
      
      local newTurret=turretToCopy:new(summoned.player,mouseX,mouseY)
      newTurret.sprite=summoned.sprite
      newTurret.life=newTurret.life-15
    end
  end
  
  --ATTAQUE ACID
  acid={
    name="acid",
    dName="Metamorphose en Moguri crache-acide",
    desc="Devenez un Moguri crache-acide, pour vous infiltrer parmis eux et, vous aussi, avoir une salive au pH avoisinnant les 0.",
    icon=love.graphics.newImage("sprites/icons/acidIcon.png"),
    sprite=love.graphics.newImage("sprites/asphere.png"),
    acidSprite=love.graphics.newImage("sprites/acid.png"),
    cd=5,--0.5,
    currentcd=0,
    cost=0,--20,
    atype="summon",
    range=300,
    autoupdate=false,
    hasEquipFunction=true
  }

  acid.width=acid.sprite:getWidth()
  acid.height=acid.sprite:getHeight()
  
  function acid:equip(player)
    local oldX,oldY,newX,newY
    oldX=player.x+0.5*player.width
    oldY=player.y+player.height-0.5*player.anims.up[1]:getHeight()
    player.anims=acidMoguri.anims 
    player.anim=player.anims.walk
    player.angle=0
    player.width=acidMoguri.width
    player.height=acidMoguri.height
    player.baseWidth=acidMoguri.width
    player.baseHeight=acidMoguri.height
    newX=oldX--0.5*player.width
    newY=oldY--0.5*player.height
    --player.x=newX
   --player.y=newY
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="moguri"
  end
  
  function acid:unequip(player)
    player.anims=player.baseAnims 
    player.anim=player.anims.up
    player.width=player.initialWidth
    player.height=player.initialHeight
    player.angle=nil
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="none"
  end
  
  function acid:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local angle=math.atan2(mouseY-(player.y+0.5*player.height),mouseX-(player.x+0.5*player.width))
    local xSpeed=400*math.cos(angle)
    local ySpeed=400*math.sin(angle)
    local width=acid.width
    local height=acid.height
    local xPoint=player.x+0.5*player.width+0.65*(math.sqrt(player.width^2+player.height^2)+width)*math.cos(angle)-0.5*width
    local yPoint=player.y+0.5*player.height+0.65*(math.sqrt(player.width^2+player.height^2)+width)*math.sin(angle)-0.5*height
    --local distance=math.sqrt((xPoint-mouseX)^2+(yPoint-mouseY)^2)
    
    
    local projectileAcid={
      name="acid",
      player=player,
      x=xPoint,
      y=yPoint,
      dx=mouseX,
      dy=mouseY,
      angle=angle,
      width=width,
      height=height,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      life=1,
    }
    
    world:add(projectileAcid,projectileAcid.x,projectileAcid.y,projectileAcid.width,projectileAcid.height)
    table.insert(projectiles,projectileAcid)
  end
  
  function acid:update(projectile,dt)
    local cols,len
    if projectile~=nil then
      projectile.x,projectile.y,cols,len = world:move(projectile,projectile.x+projectile.xSpeed*dt,projectile.y+projectile.ySpeed*dt,colcheck)

    for i,col in ipairs(cols) do
      if col.other.tangibility~=false and col.other.faction~=projectile.player.faction  then
          if col.other.life~=nil and col.other.invcd~=nil then
            if col.other.invcd<=0 then
              col.other.invcd=0.5
              col.other.life=col.other.life-2
              col.other.target=projectile.player
            end
          end
          projectile.life=projectile.life-1
          break --On sort de la boucle
        end
      end
    end
    
    local condition1, condition2
    condition1=false
    condition2=false
    if projectile.xSpeed<0 then condition1=projectile.x<projectile.dx else condition1=projectile.x>projectile.dx end
    if projectile.ySpeed<0 then condition2=projectile.y<projectile.dy else condition2=projectile.y>projectile.dy end
    
    if condition1 and condition2 then
      projectile.life=0
      damage:new(projectile.dx-16,projectile.dy-16,1,false,acid.acidSprite,nil,nil,20,"acid")
    end
    
    if projectile.life<=0 then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
      world:remove(projectile)
    end
  end
  
  dash={
    name="dash",
    dName="Metamorphose en Moguri Sauteur",
    desc="Devenez un Moguri sauteur, pour vous infiltrer parmis eux et, vous aussi, pouvoir faire de puissants bonds.",
    icon=love.graphics.newImage("sprites/icons/dashIcon.png"),
    sprite=nil,--love.graphics.newImage("sprites/asphere.png"),
    cd=0,--Depend en fonction de la distance, donc gérée par la competence elle meme
    currentcd=0,
    cost=0,--20,
    atype="summon",
    range=400,
    spd=1000,
    autoupdate=false,
    hasEquipFunction=true,
  }
  
  function dash:equip(player)
    local oldX,oldY,newX,newY
    oldX=player.x+0.5*player.width
    oldY=player.y+player.height-0.5*player.anims.up[1]:getHeight()
    player.anims=dashMoguri.anims 
    player.anim=player.anims.walk
    player.angle=0
    player.width=dashMoguri.width
    player.height=dashMoguri.height
    player.baseWidth=dashMoguri.width
    player.baseHeight=dashMoguri.height
    newX=oldX--0.5*player.width
    newY=oldY--0.5*player.height
    --player.x=newX
    --player.y=newY
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="moguri"
  end
  
  function dash:unequip(player)
    player.anims=player.baseAnims 
    player.anim=player.anims.up
    player.width=player.initialWidth
    player.height=player.initialHeight
    player.angle=nil
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="none"
  end
  
  function dash:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY
    local xPoint=player.x+0.5*player.width
    local yPoint=player.y+0.5*player.width
    local angle=math.atan2(mouseY-yPoint,mouseX-xPoint)
    player.angle=angle+0.5*math.pi
    player.dAngle=player.angle
    local distance=math.sqrt((xPoint-mouseX)^2+(yPoint-mouseY)^2)
    local xSpeed=dash.spd*math.cos(angle)
    local ySpeed=dash.spd*math.sin(angle)
    
    local spawnedDash={
      name="dash",
      player=player,
      x=xPoint,
      y=yPoint,
      angle=angle,
      xSpeed=xSpeed,
      ySpeed=ySpeed,
      remainingDash=(distance/dash.spd), --Le temps qu'il reste a "sauter"
      initialCharge=3*(distance/dash.spd),
      remainingCharge=3*(distance/dash.spd), --La charge initiale
      remainingStun=10*(distance/dash.spd), --Le temps qu'il reste a rester immobile
      step="charge", --Si l'on charge, dash, ou stun
      color={256,256,256}
    }
    player.attackcd=spawnedDash.remainingDash+spawnedDash.remainingStun+spawnedDash.remainingCharge
    if player.name=="player" then 
      dash.cd=2*player.attackcd
      dash.currentcd=2*player.attackcd
    end
    player.baseSpd=player.spd 
    player.spd=0
        
    table.insert(projectiles,spawnedDash)
  end
  
  function dash:update(projectile,dt)
    if projectile.player.life<=0 then
      for i,cProjectile in ipairs(projectiles) do
        if projectile==cProjectile then
          table.remove(projectiles,i)
        end
      end
    end
    
    if projectile.step=="charge" then
      projectile.remainingCharge=projectile.remainingCharge-dt
      projectile.player.color={256*(projectile.remainingCharge/projectile.initialCharge),256*(projectile.remainingCharge/projectile.initialCharge),256}
      if projectile.remainingCharge<=0 then
        projectile.step="dash"
        projectile.player.color={256,256,256}
      end
    elseif projectile.step=="dash" and projectile.player.life>0 then
      projectile.remainingDash=projectile.remainingDash-dt
      local cols,len
      projectile.player.x,projectile.player.y,cols,len=world:move(projectile.player,projectile.player.x+projectile.xSpeed*dt,projectile.player.y+projectile.ySpeed*dt,colcheck)
      for i,col in ipairs(cols) do
        if col.other.life~=nil and col.other.invcd~=nil then
          if col.other.invcd<0 then
            col.other.life=col.other.life-2
            col.other.invcd=projectile.remainingDash+0.2
          end
          if col.other.faction~=projectile.player.faction then
            col.other.target=projectile.player
          end
          col.other.xSpeed=projectile.xSpeed/2
          col.other.ySpeed=projectile.ySpeed/2
        end
      end
      if projectile.remainingDash<=0 then
        projectile.player.xSpeed=projectile.xSpeed/4
        projectile.player.ySpeed=projectile.ySpeed/4
        projectile.step="stun"
      end
    elseif projectile.step=="stun" then
      projectile.remainingStun=projectile.remainingStun-dt
      if projectile.remainingStun<=0 then
        projectile.player.spd=projectile.player.baseSpd
        for i,cProjectile in ipairs(projectiles) do
          if projectile==cProjectile then
            table.remove(projectiles,i)
          end
        end
      end
    end
  end
  
  --ATTAQUE PET FAMILIER RASSEMBLEMENT DES HEROS
  pet={
    name="pet",
    dName="Ralliement des héros",
    desc="Rhonas savait se faire des alliés, et maintenant, vous aussi. Utilisez cette attaque pres d'un ennemi, et celui ci deviendra peut-être un nouvel allié. Plus sa vie sera basse, plus l'attaque à de chance réussir. Une fois vous nouvel ami rallié, réutilisez cette attaque pour lui indiquer où aller !",
    icon=love.graphics.newImage("sprites/icons/petIcon.png"),
    sprite=nil,--love.graphics.newImage("sprites/asphere.png"),
    lifeIcon=love.graphics.newImage("sprites/petHeart.png"),
    cd=0,--Depend en fonction de ce qui se passe, donc gérée par la competence elle meme
    currentcd=0,
    followcd=0,
    cost=0,--20,
    atype="summon",
    range=600,
    autoupdate=true,
    foreground=true
  }
  
  function pet:new(player,mouseX,mouseY)
    mouseX=mouseX
    mouseY=mouseY

    if player.pet==nil then --Si pas encore de pet
      for i,mob in ipairs(spawnedMobs) do
        local distance=math.sqrt((player.x+0.5*player.width-mob.x+0.5*mob.width)^2+(player.y+0.5*player.height-mob.y+0.5*mob.height)^2)
        if distance<200 and math.random(1,math.floor(100*mob.life))<100 then
          player.pet=mob
          player.pet.path=nil
          player.pet.dx=player.pet.x
          player.pet.dy=player.pet.y
          mob.life=mob.maxlife
          mob.target=nil
          mob.faction="player"
          break;
        end
      end
      pet.cd=10
      pet.currentcd=10
    elseif player.pet~=nil and player.pet.life>0 then --Si à un pet en vie
      player.pet.dx=mouseX
      player.pet.dy=mouseY
      pet.cd=10
      pet.currentcd=10
      pet.followcd=10
    else --Si a un pet mort
      player.pet=nil
      pet:new(player,mouseX,mouseY)
    end
        
    table.insert(projectiles,spawnedDash)
  end
  
  function pet:update(dt)
    local player=players[1]
    if player.pet~=nil then
      if player.pet.target==nil then
        pet.followcd=pet.followcd-dt
        local distance=math.sqrt((player.pet.x-player.pet.dx)^2+(player.pet.y-player.pet.dy)^2)
        local distanceFromPlayer=math.sqrt((player.x-player.pet.x)^2+(player.y-player.pet.y)^2)
        if (player.xSpeed~=0 or player.ySpeed~=0) and pet.followcd<0 and distanceFromPlayer>80 then
          if player.look=="up" then
            player.pet.dx=player.x+10
            player.pet.dy=player.y+player.height+40
          elseif player.look=="down" then
            player.pet.dx=player.x+20
            player.pet.dy=player.y-40-player.pet.height
          elseif player.look=="left" then
            player.pet.dx=player.x+40
            player.pet.dy=player.y-30
          else
            player.pet.dx=player.x-player.pet.width-40
            player.pet.dy=player.y+10
          end
        elseif distance<10 then
          player.pet.dx=player.pet.x
          player.pet.dy=player.pet.y
          player.pet.dxSpeed=0
          player.pet.dySpeed=0
          player.pet.dAngle=math.atan2(player.y-player.pet.y,player.x-player.pet.x)+0.5*math.pi
        end
      end
      
      if player.pet.life<=0 then
        player.pet=nil
        pet.cd=60
        pet.currentcd=60
      end
    end
  end
  
  function pet:draw()
    if players[1].pet~=nil then
      love.graphics.translate(-translatex,-translatey)
      love.graphics.scale(1/(zoom),1/(zoom))
      
      for k=1,players[1].pet.life do
        love.graphics.draw(pet.lifeIcon,130+(k-1)*(pet.lifeIcon:getWidth()+5),5+(pet.lifeIcon:getHeight()+15))
      end
      
      love.graphics.scale(zoom,zoom)
      love.graphics.translate(translatex,translatey)
    end
  end
  
  --ATTACK SPIKE
  spike={
    name="spike",
    dName="Metamorphose en Stalagmirne",
    desc="Devenez un Stalagmirne, pour vous infiltrer parmis eux et, vous aussi, planter vos pics un peu partout.",
    icon=love.graphics.newImage("sprites/icons/spikeIcon.png"),
    sprite=nil,--love.graphics.newImage("sprites/asphere.png"),
    cd=0.5,
    currentcd=0,
    cost=0,--20,
    atype="projectile",
    autoupdate=false,
    hasEquipFunction=true,
    hasDrawFunction=true,
  }
  
  function spike:equip(player)
    local oldX,oldY,newX,newY
    oldX=player.x+0.5*player.width
    oldY=player.y+player.height-0.5*player.anims.up[1]:getHeight()
    player.anims=stalagmirne.anims 
    player.anim=player.anims.walk
    player.angle=0
    player.width=stalagmirne.width
    player.height=stalagmirne.height
    player.fixhitbox=true
    player.baseWidth=stalagmirne.width
    player.baseHeight=stalagmirne.height
    newX=oldX--0.5*player.width
    newY=oldY--0.5*player.height
    --player.x=newX
    --player.y=newY
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="arnine"
  end
  
  function spike:unequip(player)
    player.anims=player.baseAnims 
    player.anim=player.anims.up
    player.width=player.initialWidth
    player.height=player.initialHeight
    player.angle=nil
    player.fixhitbox=nil
    world:update(player,player.x,player.y,player.width,player.height)
    player.fakeFaction="none"
  end
  
  function spike:new(player,mouseX,mouseY)

    local xPoint=player.x+0.5*player.width
    local yPoint=player.y+0.5*player.height
    
    local spawnedSpike={
      name="spike",
      player=player,
      x=xPoint,
      y=yPoint,
      radius=0,
      radiuses={0,0,0,8,10,20,25;26},
      fps=20,
      frame=1,
      lifetime=1,
      --hasDrawFunction=true,
      foreground=true,
    }
    
    player.attackcd=1.5
    if player.name=="player" then 
      spike.currentcd=1.5
    end
    player.baseSpd=player.spd 
    player.spd=0
    
    player.anim=player.anims.attack
    player.frame=1
    player.spd=0
        
    table.insert(projectiles,spawnedSpike)
  end
  
  function spike:update(projectile,dt)
    projectile.lifetime=projectile.lifetime-dt
    projectile.frame=projectile.frame+dt*projectile.fps
    if projectile.frame>8 then projectile.frame=8 end
    
    projectile.radius=projectile.radiuses[math.floor(projectile.frame)]
    projectile.x=projectile.player.x+0.5*projectile.player.width
    projectile.y=projectile.player.y+0.5*projectile.player.height
    projectile.player.anim=projectile.player.anims.attack
    projectile.player.frame=projectile.frame
    
    local pSpikeds={}
    --On regarde tous les mobs, et tous les joueurs, pour les ajouter en potentiels spikés
    for i,player in ipairs(players) do
      if player~=projectile.player then table.insert(pSpikeds,player) end
    end
    
    for i,mob in ipairs(spawnedMobs) do
      if mob~=projectile.player then table.insert(pSpikeds,mob) end
    end
    
    for i,pSpiked in ipairs(pSpikeds) do
      if pSpiked.life~=nil and pSpiked.width~=nil then
        local dfpSpiked=math.sqrt((projectile.player.x+0.5*projectile.player.width-(pSpiked.x+0.5*pSpiked.width))^2+(projectile.player.y+0.5*projectile.player.height-(pSpiked.y+0.5*pSpiked.height))^2)
        local hitdist=projectile.radius+0.5*math.sqrt(pSpiked.width^2+pSpiked.height^2)
        if dfpSpiked<hitdist and pSpiked.life>0 and pSpiked.invcd<=0 and pSpiked.faction~=projectile.player.faction then
          local angleFromSpiked=math.atan2(pSpiked.y+0.5*pSpiked.height-(projectile.player.y+0.5*projectile.player.height),pSpiked.x+0.5*pSpiked.width-(projectile.player.x+0.5*projectile.player.width))
          pSpiked.life=pSpiked.life-1
          pSpiked.invcd=0.2
          pSpiked.xSpeed=math.cos(angleFromSpiked)*300
          pSpiked.ySpeed=math.sin(angleFromSpiked)*300
          if pSpiked.faction~=projectile.player.faction then
            pSpiked.target=projectile.player
          end
        end
      end
    end
    
    if projectile.lifetime<0 or projectile.player.life<=0 then
      projectile.player.spd=projectile.player.baseSpd
      --if projectile.player.dxSpeed+projectile.player.dySpeed~=0 or projectile.player.life<=0 then
        for i,cProjectile in ipairs(projectiles) do
          projectile.player.anim=projectile.player.anims.walk
          projectile.player.frame=1
          if cProjectile==projectile then
            table.remove(projectiles,i)
          end
        end
      --end
    end
  end
  
  function spike:draw(projectile)
    love.graphics.circle("line",projectile.x,projectile.y,projectile.radius)
  end
  
  attacks={arrow,sword,spear,isphere,iturret,grapling,pullsphere,pushsphere,hturret,mturret,acid,pet,spike,tsphere,tturret,dash,bomb}
  
end

function updateProjectile(projectile,dt)
  for i,attack in ipairs(attacks) do 
    if attack.name==projectile.name then
      attack:update(projectile,dt)
    end
  end
end

function drawProjectile(projectile)
  local sprite=nil
  local cAttack={}
  for i,attack in ipairs(attacks) do
    if attack.name==projectile.name then
      sprite=attack.sprite
      cAttack=attack
    end
  end
  
  if projectile.sprite~=nil then sprite=projectile.sprite end
  
  if cAttack.hasDrawFunction then
    cAttack:draw(projectile)
    sprite=nil
  end
      
  if sprite~=nil then
    if projectile.color~=nil then love.graphics.setColor(projectile.color) end
    love.graphics.draw(sprite,projectile.x+0.5*projectile.width,projectile.y+0.5*projectile.height,projectile.angle,1,1,0.5*sprite:getWidth(),0.5*sprite:getHeight())    
    love.graphics.setColor(1,1,1,1)
  end
  if projectile.particles~=nil then
    love.graphics.draw(projectile.particles,projectile.x+projectile.particlesx,projectile.y+projectile.particlesy)
    --love.graphics.circle("fill",projectile.x+projectile.particlesx,projectile.y+projectile.particlesy,20)
  end
end