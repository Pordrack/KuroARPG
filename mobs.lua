function loadMobs()
  
  --TARGET
  target={
    name="target",
    sprite=love.graphics.newImage("sprites/target.png"),
    fps=0,
  }
  target.width=target.sprite:getWidth()
  target.height=target.sprite:getHeight()
  
  function target:new(x,y,attack,linkid,path)
    local spawnedTarget={
      name="target",
      faction="none",
      isMob=true,
      anim={target.sprite},
      frame=1,
      fps=target.fps,
      x=x,
      y=y,
      xSpeed=0,
      ySpeed=0,
      dxSpeed=0,
      dySpeed=0,
      dx=nil, --Le x visé, donc prochain point de la trajectoire/truc en lien avec le joueur
      dy=nil,
      spd=150,
      maxlife=3,
      life=3,
      invcd=0,
      width=target.width,
      height=target.height,
      size=1,
      attack=attack,
      linkid=linkid,
      path=path,
    }
    world:add(spawnedTarget,spawnedTarget.x,spawnedTarget.y,spawnedTarget.width,spawnedTarget.height)
    table.insert(spawnedMobs,spawnedTarget)
    return spawnedTarget
  end
  
  function target:update(mob,dt)
    --Elle fait rien en fait
  end
  
  --ACID MOGURI
  acidMoguri={
    name="acidMoguri",
    sprite=love.graphics.newImage("sprites/acidMoguri.png"),
    anims={
      walk={love.graphics.newImage("sprites/acidMoguri.png")},
    },
    fps=0,
  }
  acidMoguri.width=20
  acidMoguri.height=51
  
  function acidMoguri:new(x,y,attack,linkid,path)
    local spawnedAcidMoguri={
      name="acidMoguri",
      faction="moguri",
      isMob=true,
      anim={acidMoguri.sprite},
      frame=1,
      fps=acidMoguri.fps,
      x=x,
      y=y,
      angle=0,
      xSpeed=0,
      ySpeed=0,
      dxSpeed=0,
      dySpeed=0,
      dx=y, --Le x visé, donc prochain point de la trajectoire/truc en lien avec le joueur
      dy=x,
      spd=150,
      maxlife=3,
      life=3,
      invcd=0,
      maxattackcd=2.5,
      width=20,
      height=51,
      size=1,
      range=200,
      immunedTo={"acid"},
      idealDistance=120,
      target=nil,
      attack=attack,
      linkid=linkid,
      allies={},
      attackcd=0,
      path=path,
    }
    world:add(spawnedAcidMoguri,spawnedAcidMoguri.x,spawnedAcidMoguri.y,spawnedAcidMoguri.width,spawnedAcidMoguri.height)
    table.insert(spawnedMobs,spawnedAcidMoguri)
    return spawnedAcidMoguri
  end
  
  function acidMoguri:update(mob,dt)
    local angleFromDpos=math.atan2(mob.dy-mob.y,mob.dx-mob.x)
    mob.dAngle=angleFromDpos+0.5*math.pi
    
    if mob.target==nil then --On cherche une cible, mob ennemi ou joueur
      mob.attackcd=1.5
      for i,spawnedMob in ipairs(spawnedMobs) do
        local distance=math.sqrt((spawnedMob.x-mob.x)^2+(spawnedMob.y-mob.y)^2)
        if spawnedMob.faction~=mob.faction and spawnedMob.fakeFaction~="moguri" and spawnedMob.name~="target" and distance<mob.range then
          mob.target=spawnedMob
        end
      end
      local distance=math.sqrt((players[1].x-mob.x)^2+(players[1].y-mob.y)^2)
      if distance<mob.range and players[1].fakeFaction~="moguri" and mob.faction~="player" then mob.target=players[1] end
    elseif mob.target~=nil then
      mob.attackcd=mob.attackcd-dt
      local angleFromTarget=math.atan2(mob.target.y-(mob.y+0.5*mob.height),mob.target.x-(mob.x+0.5*mob.width))
      if mob.precision==nil then mob.precision=100 end
      --print("angle from target before scrambling"..angleFromTarget)
      angleFromTarget=angleFromTarget+0.01*math.random(-157+(mob.precision/100)*157,157-(mob.precision/100)*157)
      --print("angle from target after scrambling"..angleFromTarget)
      local dfTarget=math.sqrt((mob.target.x-mob.x)^2+(mob.target.y-mob.y)^2)
      --mob.angle=angleFromTarget+0.5*math.pi
      if mob.attackcd<0 then --On attaque si on peut
        local xPoint,yPoint
        acid:new(mob,mob.x+0.5*mob.width+(dfTarget*1.2)*math.cos(angleFromTarget),mob.y+0.5*mob.height+(dfTarget*1.2)*math.sin(angleFromTarget))
        mob.attackcd=mob.maxattackcd
      else --Sinon on trouve des chemins
        local distanceFromDesired=math.sqrt((mob.x-mob.dx)^2+(mob.y-mob.dy)^2)
        if distanceFromDesired<50 then
          local angle=math.random(0,628)/100 
          local combatRotation=1
          if math.random(100)>50 then combatRotation=-1 end
          if mob.combatRotation==nil then mob.combatRotation=combatRotation else combatRotation=mob.combatRotation end
          if mob.combatAngle==nil then mob.combatAngle=angle else mob.combatAngle=mob.combatAngle+combatRotation*math.pi/6 end
          local pdistance=0.01*(120-math.random(40))*mob.idealDistance
          mob.dx=mob.target.x+math.cos(mob.combatAngle)*pdistance
          mob.dy=mob.target.y+math.sin(mob.combatAngle)*pdistance
        end
      end
      
      --Si la cible est trops loins, on l'abandonne, pareil si elle est mort
        if dfTarget>3*mob.range or mob.target.life<=0 or mob.target.faction==mob.faction then mob.target=nil end   
    end
  end
  
  --DASH MOGURI
  dashMoguri={
    name="dashMoguri",
    sprite=love.graphics.newImage("sprites/dashMoguri.png"),
    anims={
      walk={love.graphics.newImage("sprites/dashMoguri.png")},
    },
    fps=0,
  }
  dashMoguri.width=20
  dashMoguri.height=51
  
  function dashMoguri:new(x,y,attack,linkid,path)
    local spawnedDashMoguri={
      name="dashMoguri",
      faction="moguri",
      isMob=true,
      anim={dashMoguri.sprite},
      frame=1,
      fps=dashMoguri.fps,
      avoidContact=true,
      x=x,
      y=y,
      angle=0,
      xSpeed=0,
      ySpeed=0,
      dxSpeed=0,
      dySpeed=0,
      dx=y, --Le x visé, donc prochain point de la trajectoire/truc en lien avec le joueur
      dy=x,
      baseSpd=400,
      spd=400,
      maxlife=3,
      life=3,
      invcd=0,
      maxattackcd=2.5,
      width=20,
      height=51,
      size=1,
      range=200,
      immunedTo={"acid"},
      idealDistance=80,
      target=nil,
      attack=attack,
      linkid=linkid,
      allies={},
      attackcd=0,
      path=path,
    }
    world:add(spawnedDashMoguri,spawnedDashMoguri.x,spawnedDashMoguri.y,spawnedDashMoguri.width,spawnedDashMoguri.height)
    table.insert(spawnedMobs,spawnedDashMoguri)
    return spawnedDashMoguri
  end
  
  function dashMoguri:update(mob,dt)
    if mob.spd>0 then
      local angleFromDpos=math.atan2(mob.dy-mob.y,mob.dx-mob.x)
      mob.dAngle=angleFromDpos+0.5*math.pi
    end
    if mob.target==nil then --On cherche une cible, mob ennemi ou joueur
      mob.attackcd=1.5
      for i,spawnedMob in ipairs(spawnedMobs) do
        local distance=math.sqrt((spawnedMob.x-mob.x)^2+(spawnedMob.y-mob.y)^2)
        if spawnedMob.faction~=mob.faction and spawnedMob.name~="target" and distance<mob.range then
          mob.target=spawnedMob
        end
      end
      local distance=math.sqrt((players[1].x-mob.x)^2+(players[1].y-mob.y)^2)
      if distance<mob.range and players[1].fakeFaction~="moguri" and mob.faction~="player" then mob.target=players[1] end
    elseif mob.target~=nil then
      mob.attackcd=mob.attackcd-dt
      local angleFromTarget=math.atan2(mob.target.y-(mob.y+0.5*mob.height),mob.target.x-(mob.x+0.5*mob.width))
      if mob.precision==nil then mob.precision=100 end
      angleFromTarget=angleFromTarget+0.01*math.random(-157+(mob.precision/100)*157,157-(mob.precision/100)*157)
      local dfTarget=math.sqrt((mob.target.x-mob.x)^2+(mob.target.y-mob.y)^2)
      if dfTarget<60 then dfTarget=60 end --On augmente artificiellement la distance de dash
      
      if mob.attackcd<0 then --On attaque si on peut
        local xPoint,yPoint
        dash:new(mob,mob.x+0.5*mob.width+(dfTarget*1.2)*math.cos(angleFromTarget),mob.y+0.5*mob.height+(dfTarget*1.2)*math.sin(angleFromTarget))
        mob.dAngle=angleFromTarget+0.5*math.pi
        mob.attackcd=mob.attackcd+mob.maxattackcd
      else --Sinon on trouve des chemins
        local distanceFromDesired=math.sqrt((mob.x-mob.dx)^2+(mob.y-mob.dy)^2)
        if distanceFromDesired<50 then
          local angle=math.random(0,628)/100 
          local combatRotation=1
          if math.random(100)>50 then combatRotation=-1 end
          if mob.combatRotation==nil then mob.combatRotation=combatRotation else combatRotation=mob.combatRotation end
          if mob.combatAngle==nil then mob.combatAngle=angle else mob.combatAngle=mob.combatAngle+combatRotation*math.pi/6 end
          local pdistance=0.01*(120-math.random(40))*mob.idealDistance
          mob.dx=mob.target.x+math.cos(mob.combatAngle)*pdistance
          mob.dy=mob.target.y+math.sin(mob.combatAngle)*pdistance
        end
      end
      
      --Si la cible est trops loins, on l'abandonne, pareil si elle est mort
      if dfTarget>3*mob.range or mob.target.life<=0 or mob.target.faction==mob.faction then mob.target=nil end      
    end
  end
  
  --STALAGMIRNE
  stalagmirne={
    name="stalagmirne",
    sprite=love.graphics.newImage("sprites/stalagmirne/stalagmirne0.png"),
    anims={
      walk={love.graphics.newImage("sprites/stalagmirne/stalagmirne0.png")},
      attack={love.graphics.newImage("sprites/stalagmirne/stalagmirne0.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne1.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne2.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne3.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne4.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne5.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne6.png"),love.graphics.newImage("sprites/stalagmirne/stalagmirne7.png")},
    },
    fps=0,
  }
  stalagmirne.width=15
  stalagmirne.height=15
  
  function stalagmirne:new(x,y,attack,linkid,path)
    local spawnedStalagmirne={
      name="stalagmirne",
      faction="arnine",
      isMob=true,
      anims=stalagmirne.anims,
      anim=stalagmirne.anims.walk,
      frame=1,
      fps=stalagmirne.fps,
      avoidContact=false,
      x=x,
      y=y,
      angle=0,
      xSpeed=0,
      ySpeed=0,
      dxSpeed=0,
      dySpeed=0,
      dx=y, --Le x visé, donc prochain point de la trajectoire/truc en lien avec le joueur
      dy=x,
      baseSpd=400,
      spd=400,
      maxlife=3,
      life=3,
      invcd=0,
      width=15,
      height=15,
      size=1,
      summoncd=0,
      range=200,
      immunedTo={"fire"},
      idealDistance=120,
      fixhitbox=true,
      target=nil,
      attack=attack,
      linkid=linkid,
      swarm={},
      attackcd=0,
      path=path,
    }
    
    spawnedStalagmirne.id=math.random(10000)
    --Laisse des petites particules 
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,100)
    particleSystem.particles:setLinearAcceleration(-25,-25,25,25)
    particleSystem.particles:setColors(62/256,17/256,1/256,1,21/256,11/256,7/256,1)
    particleSystem.particles:setParticleLifetime(0.5,1.5)
    particleSystem.particles:emit(100)
    particleSystem.x=spawnedStalagmirne.x+0.5*stalagmirne.width
    particleSystem.y=spawnedStalagmirne.y+0.5*stalagmirne.height
    particleSystem.particles:setEmissionArea("uniform",0.5*stalagmirne.width,0.5*stalagmirne.height,0,true)
    table.insert(particlesSystems,particleSystem)
    
    world:add(spawnedStalagmirne,spawnedStalagmirne.x,spawnedStalagmirne.y,spawnedStalagmirne.width,spawnedStalagmirne.height)
    table.insert(spawnedMobs,spawnedStalagmirne)
    return spawnedStalagmirne
  end
  
  function stalagmirne:update(mob,dt)
    --GESTION DU SWARM
    if mob.swarmleader~=nil then --Si on fait partie d'un armada
      if mob.swarmleader.life<=0 or mob.swarmleader.faction~=mob.faction then --On verifie qu'il est pas mort, ou traitre
        mob.swarmleader=nil
      else --Ou qu'il n'a pas rejoins une autre armade
        if mob.swarmleader.swarmleader~=nil then
          mob.swarmleader=mob.swarmleader.swarmleader
        end
      end
    else --Sinon on scan les mobs pour s'en constituer une
      for i,omob in ipairs(spawnedMobs) do
        local distanceFromEO=math.sqrt((omob.x-mob.x)^2+(omob.y-mob.y)^2)
        if omob.name==mob.name and distanceFromEO<mob.range and omob~=mob then
          if omob.swarmleader==nil then --On le recrute dans la sienne, si il n'en a pas, ou une plus petite
            if #omob.swarm<#mob.swarm and mob.faction==omob.faction then
              table.insert(mob.swarm,omob)
              omob.swarmleader=mob
              omob.swarm={}
            elseif mob.faction==omob.faction then --sinon, on rejoins la sienne
            elseif mob.faction==omob.faction then --sinon, on rejoins la sienne
              mob.swarmleader=omob
              mob.swarm={}
              table.insert(omob.swarm,mob)
            end
          end
        end
      end
    end
    
    for i,peon in ipairs(mob.swarm) do --On verifie que nos peons on pas quitter le clan, ou son pas mort
      if peon.swarmleader~=mob or peon.life<=0 then
        table.remove(mob.swarm,i)
        break;
      end
    end
    --[[if #mob.swarm>0 then
      print("Moi, "..mob.id.." suis chef d'un swarm de "..#mob.swarm.." membres")
    elseif mob.swarmleader~=nil then
      print("Moi, "..mob.id.." fait partie du swarm de "..mob.swarmleader.id)
    end]]
    
    if mob.spd>0 then
      local angleFromDpos=math.atan2(mob.dy-mob.y,mob.dx-mob.x)
      mob.dAngle=angleFromDpos+0.5*math.pi
    end
    if mob.target==nil then --On cherche une cible, mob ennemi ou joueur
      
      for i,peon in ipairs(mob.swarm) do --On regarde si notre peon en a trouver une
        if peon.target~=nil then
          mob.target=peon.target
        elseif peon.path==nil then
          peon.dx=mob.dx 
          peon.dy=mob.dy
        end
      end
          
      mob.attackcd=1.5
      for i,spawnedMob in ipairs(spawnedMobs) do
        local distance=math.sqrt((spawnedMob.x-mob.x)^2+(spawnedMob.y-mob.y)^2)
        if spawnedMob.faction~=mob.faction and spawnedMob.name~="target" and distance<mob.range then
          mob.target=spawnedMob
        end
      end
      local distance=math.sqrt((players[1].x-mob.x)^2+(players[1].y-mob.y)^2)
      if distance<mob.range and players[1].fakeFaction~="arnine" and mob.faction~="player" then mob.target=players[1] end
    elseif mob.target~=nil then --Si on a une target, on la combat
      mob.attackcd=mob.attackcd-dt
      local dfTarget=math.sqrt((mob.target.x+0.5*mob.target.width-(mob.x+0.5*mob.width))^2+(mob.target.y+0.5*mob.target.height-(mob.y+0.5*mob.height))^2)
      if dfTarget<15+0.5*math.sqrt(mob.target.width^2+mob.target.height^2) and mob.attackcd<0 then-- on attaque si on peut
        mob.attackcd=1.5
        spike:new(mob)
        mob.idealDistance=120
      else --Sinon on trouve des chemins
         --ou on invoque des camarades pour remplir son swarm
        local condition=#mob.swarm<10
        if mob.swarmleader~=nil then condition=#mob.swarmleader.swarm<10 end
        if condition then
          mob.summoncd=mob.summoncd-dt
          if mob.summoncd<0 then
            mob.summoncd=math.random(3,10)
            if mob.maxattackcd~=nil then mob.summoncd=mob.maxattackcd end
            local angle=0.01*math.random(628)
            local newMember=stalagmirne:new(mob.x+math.cos(angle)*60,mob.y+math.sin(angle))
            if mob.swarmleader==nil then
              table.insert(mob.swarm,newMember)
              newMember.swarmleader=mob
            else
              table.insert(mob.swarmleader.swarm,newMember)
              newMember.swarmleader=mob.swarmleader
            end
            newMember.maxattackcd=mob.maxattackcd
            newMember.summoncd=mob.maxattackcd
            if mob.path~=nil then newMember.path=mob.path end
            newMember.faction=mob.faction
            newMember.baseSpd=mob.baseSpd 
            newMember.spd=mob.baseSpd 
            newMember.maxlife=mob.maxlife
            if newMember.life>newMember.maxlife then
              newMember.life=newMember.maxlife
            end
          end
        end
        local distanceFromDesired=math.sqrt((mob.x-mob.dx)^2+(mob.y-mob.dy)^2)
        if distanceFromDesired<50 then
          local angle=math.random(0,628)/100 
          local combatRotation=1
          if math.random(100)>50 then combatRotation=-1 end
          if mob.combatRotation==nil then mob.combatRotation=combatRotation else combatRotation=mob.combatRotation end
          if mob.combatAngle==nil then mob.combatAngle=angle else mob.combatAngle=mob.combatAngle+combatRotation*math.pi/6 end
          --On donne des directions aux membres de son swarm
          for i,peon in ipairs(mob.swarm) do
            peon.combatAngle=mob.combatAngle+(i/(#mob.swarm+1))*2*math.pi
            peon.idealDistance=mob.idealDistance
            peon.target=mob.target
            local pdistance=0.01*(120-math.random(40))*peon.idealDistance
            peon.dx=mob.target.x+math.cos(peon.combatAngle)*pdistance
            peon.dy=mob.target.y+math.sin(peon.combatAngle)*pdistance
          end
          
          local pdistance=0.01*(120-math.random(40))*mob.idealDistance
          if dfTarget<1.5*mob.idealDistance then
            mob.idealDistance=mob.idealDistance-40 
          elseif dfTarget>2*mob.idealDistance and mob.idealDistance<120 then
            mob.idealDistance=mob.idealDistance+40
          end
          
          if mob.idealDistance<0 then mob.idealDistance=0 end
          mob.dx=mob.target.x+math.cos(mob.combatAngle)*pdistance
          mob.dy=mob.target.y+math.sin(mob.combatAngle)*pdistance
        end
      end
      
      --Si la cible est trops loins, on l'abandonne, pareil si elle est mort
      if dfTarget>3*mob.range or mob.target.life<=0 or mob.target.faction==mob.faction then
        mob.target=nil 
        for i,peon in ipairs(mob.swarm) do
          peon.target=nil
        end
      end   
    end
  end
  
  mobs={target,acidMoguri,dashMoguri,stalagmirne}
end

function addPath(mapPath)
  local path={
    xs={},
    ys={},
    cPoint=0,
    linkid=mapPath.properties.linkid
  }
  --On fait un tableau des points du polygon
  if mapPath.shape=="rectangle" then
    table.insert(path.xs,mapPath.x)
    table.insert(path.ys,mapPath.y)
    table.insert(path.xs,mapPath.x+mapPath.width)
    table.insert(path.ys,mapPath.y)
    table.insert(path.xs,mapPath.x+mapPath.width)
    table.insert(path.ys,mapPath.y+mapPath.height)
    table.insert(path.xs,mapPath.x)
    table.insert(path.ys,mapPath.y+mapPath.height)
  end
  --On fait un tableau des points du polygon
  if mapPath.shape=="polygon" then
    for i,point in ipairs(mapPath.polygon) do
      table.insert(path.xs,mapPath.x+point.x)
      table.insert(path.ys,mapPath.y+point.y)
    end
  end
  
  --On cherche un mob avec le meme linkid
  local found=false
  for i,mob in ipairs(spawnedMobs) do
    local linkid=mob.linkid
    if linkid==nil then linkid="rienmdrpasdelinkid" end
    if linkid==mapPath.properties.linkid then
      mob.path=path
      found=true
    end
  end
  
  for i,mob in ipairs(mobsToSpawn) do
    local linkid=mob.linkid
    if linkid==nil then linkid="rienmdrpasdelinkid" end
    if linkid==mapPath.properties.linkid then
      mob.path=path
    end
  end
  
  --On cherche aussi une plateforme potentiellement
  local found=false
  for i,element in ipairs(spawnedElements) do
    local linkid=element.linkid
    if linkid==nil then linkid="rienmdrpasdelinkid" end
    if linkid==mapPath.properties.linkid then
      element.path=path
      found=true
    end
  end
  
  if found==false then
    table.insert(freepaths,path)
  end
end
function updateSpawnedMob(spawnedMob,dt)
  --L'animation
  spawnedMob.frame=spawnedMob.frame+dt*spawnedMob.fps
  if math.floor(spawnedMob.frame)>#spawnedMob.anim then spawnedMob.frame=1 end
  --Les cooldowns 
  spawnedMob.invcd=spawnedMob.invcd-dt
  
  --Mob update
  for i,mob in ipairs(mobs) do 
    if mob.name==spawnedMob.name then
      mob:update(spawnedMob,dt)
    end
  end
  
  --Deplacements 
  --On regarde les points de la potentielle trajectoire pour les prendres en cible, si il n'a pas de cible actuellement
  if spawnedMob.path~=nil and spawnedMob.target==nil then
    if spawnedMob.path.cPoint<1 then spawnedMob.path.cPoint=1 end
    spawnedMob.dx=spawnedMob.path.xs[spawnedMob.path.cPoint] 
    spawnedMob.dy=spawnedMob.path.ys[spawnedMob.path.cPoint] 
    local distance=math.sqrt((spawnedMob.x-spawnedMob.dx)^2+(spawnedMob.y-spawnedMob.dy)^2)
    if distance<10 then
      spawnedMob.path.cPoint=spawnedMob.path.cPoint+1
      if spawnedMob.path.cPoint>#spawnedMob.path.xs then spawnedMob.path.cPoint=1 end
    end
  end

  if spawnedMob.dAngle~=nil and spawnedMob.angle~=nil then
    local newAngle=spawnedMob.angle  
    --Adaptation de l'angle en fonction de l'angle desiré
    local newAngle1,newAngle2,dif1A,dif1B,dif2A,dif2B,dif1,dif2 
    newAngle1=spawnedMob.angle+math.pi*dt
    newAngle2=spawnedMob.angle-math.pi*dt
    
    
    dif1A=math.abs(2*math.pi-newAngle1+spawnedMob.dAngle) 
    while dif1A>2*math.pi do dif1A=dif1A-2*math.pi end
    dif1B=math.abs(2*math.pi-spawnedMob.dAngle+newAngle1) 
    while dif1B>2*math.pi do dif1B=dif1B-2*math.pi end
    if dif1B<dif1A then dif1=dif1B else dif1=dif1A end

    dif2A=math.abs(2*math.pi-newAngle2+spawnedMob.dAngle) 
    while dif2A>2*math.pi do dif2A=dif2A-2*math.pi end
    dif2B=math.abs(2*math.pi-spawnedMob.dAngle+newAngle2) 
    while dif2B>2*math.pi do dif2B=dif2B-2*math.pi end
    if dif2B<dif2A then dif2=dif2B else dif2=dif2A end
    
    if dif1<dif2 then
      newAngle=newAngle1
      if dif1<math.pi/8 then newAngle=spawnedMob.dAngle end
      --print("on monte")
    else
      newAngle=newAngle2
      if dif2<math.pi/8 then newAngle=spawnedMob.dAngle end
      --print("on descend")
    end
  
  --Adaptation de la hitbox en fonction de l'angle, sert dans le cas ou le joueur est tranformé
    if spawnedMob.baseWidth==nil then spawnedMob.baseWidth=spawnedMob.width spawnedMob.baseHeight=spawnedMob.height end
    local oldX,oldY,newX,newY
    oldX=spawnedMob.x+0.5*spawnedMob.width
    oldY=spawnedMob.y+0.5*spawnedMob.height
    local newWidth=math.abs(math.cos(newAngle)*spawnedMob.baseWidth)+math.abs(math.cos(newAngle-0.5*math.pi)*spawnedMob.baseHeight)
    local newHeight=math.abs(math.sin(newAngle)*spawnedMob.baseWidth)+math.abs(math.sin(newAngle-0.5*math.pi)*spawnedMob.baseHeight)
    newX=oldX-0.5*newWidth
    newY=oldY-0.5*newHeight
    local canTurn=true
    local items,len=world:queryRect(newX,newY,newWidth,newHeight)
    for i,item in ipairs(items) do
      if item.tangibility~=false and item~=spawnedMob then
        canTurn=false
      end
    end
    if canTurn and spawnedMob.fixhitbox~=true then
      spawnedMob.angle=newAngle
      spawnedMob.x=newX
      spawnedMob.y=newY
      spawnedMob.height=newHeight
      spawnedMob.width=newWidth
      world:update(spawnedMob,spawnedMob.x,spawnedMob.y,spawnedMob.width,spawnedMob.height)
    elseif spawnedMob.fixhitbox==true then
      spawnedMob.angle=newAngle
    end
  end
  
  --On adapte la vitesse desirée en fonction de la position desiré
  if spawnedMob.dx~=nil then
    
    if spawnedMob.dx~=spawnedMob.x then
      local angle=math.atan2(spawnedMob.dy-spawnedMob.y,spawnedMob.dx-spawnedMob.x)
      spawnedMob.dxSpeed=math.cos(angle)*spawnedMob.spd 
      spawnedMob.dySpeed=math.sin(angle)*spawnedMob.spd
    end
    
    --Regarde si un obstacle bloque la route, si oui, on reset le dx et dy du mob pour pas qu'il se coince comme un abruti
    local items1, len1 = world:querySegment(spawnedMob.x+spawnedMob.width,spawnedMob.y+spawnedMob.height,spawnedMob.dx+spawnedMob.width,spawnedMob.dy+spawnedMob.height) 
    local items2, len2 = world:querySegment(spawnedMob.x,spawnedMob.y,spawnedMob.dx,spawnedMob.dy) 
    for i,item in ipairs(items2) do
      table.insert(items1,item)
    end
    for i,item in ipairs(items1) do
      local condition3=item.name~="player"
      if spawnedMob.avoidContact and spawnedMob.target~=nil then condition3=true end
      local condition4=(item.swarmleader~=spawnedMob and spawnedMob.swarmleader~=item and (item.swarmleader==nil or item.swarmleader~=spawnedMob.swarmleader))
      if (item.tangibility~=false and item~=spawnedMob and condition3 and condition4) then--or (item.damage~=nil and math.random(100)<80) then --and item.lifand item~=spawnedMob then
        if spawnedMob.target~=nil then
          spawnedMob.dx=spawnedMob.x
          spawnedMob.dy=spawnedMob.y--Alors il reset sa dx et dy
        elseif spawnedMob.path~=nil then
          spawnedMob.path.cPoint=spawnedMob.path.cPoint+1
          if spawnedMob.path.cPoint>#spawnedMob.path.xs then spawnedMob.path.cPoint=1 end
        end
        break;
      end
    end
  end
  
  if spawnedMob.xSpeed<spawnedMob.dxSpeed then
    spawnedMob.xSpeed=spawnedMob.xSpeed+1000*dt
    --player.xSpeed=player.xSpeed+3*math.abs(player.xSpeed-player.dxSpeed)*dt
    if spawnedMob.xSpeed>spawnedMob.dxSpeed then
      spawnedMob.xSpeed=spawnedMob.dxSpeed
    end
  elseif spawnedMob.xSpeed>spawnedMob.dxSpeed then
    spawnedMob.xSpeed=spawnedMob.xSpeed-1000*dt
    --player.xSpeed=player.xSpeed-3*math.abs(player.xSpeed-player.dxSpeed)*dt
    if spawnedMob.xSpeed<spawnedMob.dxSpeed then
      spawnedMob.xSpeed=spawnedMob.dxSpeed
    end
  end
  
  if spawnedMob.ySpeed<spawnedMob.dySpeed then
    spawnedMob.ySpeed=spawnedMob.ySpeed+1000*dt
    --player.xSpeed=player.xSpeed+3*math.abs(player.xSpeed-player.dxSpeed)*dt
    if spawnedMob.ySpeed>spawnedMob.dySpeed then
      spawnedMob.ySpeed=spawnedMob.dySpeed
    end
  elseif spawnedMob.ySpeed>spawnedMob.dySpeed then
    spawnedMob.ySpeed=spawnedMob.ySpeed-1000*dt
    --player.xSpeed=player.xSpeed-3*math.abs(player.xSpeed-player.dxSpeed)*dt
    if spawnedMob.ySpeed<spawnedMob.dySpeed then
      spawnedMob.ySpeed=spawnedMob.dySpeed
    end
  end
   
  local cols,len 
  if onDialog==false then 
    spawnedMob.x,spawnedMob.y,cols,len=world:move(spawnedMob,spawnedMob.x+spawnedMob.xSpeed*dt,spawnedMob.y+spawnedMob.ySpeed*dt,colcheck)
  else
    cols={}
    len=0
  end
  
  for i,col in ipairs(cols) do
    if col.other.name=="damage" and spawnedMob.invcd<0 then
      local immunedTo=false
      if spawnedMob.immunedTo~=nil then
        for j,immunity in ipairs(spawnedMob.immunedTo) do
          if immunity==col.other.dName then
            immunedTo=true
          end
        end
      end
      
      if immunedTo==false then
        spawnedMob.life=spawnedMob.life-col.other.damage
        spawnedMob.invcd=0.5
      end
    end
  end
  
  --Regarde si le monstre doit mourir
  if spawnedMob.life<=0 then
    if spawnedMob.bolt~=nil then
      sparkles:remove(spawnedMob.bolt)
    end
    for i,mob in ipairs(mobs) do 
      if mob.name==spawnedMob.name and mob.hasDieFunction then
        mob:die(spawnedMob)
      end
    end
    for i,cMob in ipairs(spawnedMobs) do
        if cMob==spawnedMob then
        table.remove(spawnedMobs,i)
        world:remove(spawnedMob)
        --table.insert(killedMobs,spawnedMob)
        break;
      end
    end
    if spawnedMob.attack~=nil then
      learnAttacks({spawnedMob.attack})
    end
    local particleSystem={}
    particleSystem.particles=love.graphics.newParticleSystem(particleSprite,400)
    particleSystem.particles:setLinearAcceleration(-100,-100,100,100)
    particleSystem.particles:setRadialAcceleration(-10,-5)
    particleSystem.particles:setColors(0.4,0.4,0.4,1,0.4,0.4,0.4,0)
    particleSystem.particles:setParticleLifetime(0.5,1)
    particleSystem.particles:emit(400)
    particleSystem.x=spawnedMob.x+0.5*spawnedMob.width
    particleSystem.y=spawnedMob.y+0.5*spawnedMob.height
    table.insert(particlesSystems,particleSystem)
    players[1].wakfu=players[1].wakfu+math.random(10,30)
    if math.random(1,10)>7 then
      heart:new(particleSystem.x-16,particleSystem.y-16,20)
    end
    if players[1].wakfu>players[1].maxwakfu then players[1].wakfu=players[1].maxwakfu end
  end
  
end

function drawSpawnedMob(spawnedMob)
  if spawnedMob.color~=nil then love.graphics.setColor(spawnedMob.color[1]/255,spawnedMob.color[2]/255,spawnedMob.color[3]/255,1) end
  
  if spawnedMob.invcd>0 then love.graphics.setColor(1,0.2,0.2,0.5) end
  
  local sprite=spawnedMob.anim[math.floor(spawnedMob.frame)]
  if sprite~=nil then
    love.graphics.draw(sprite,spawnedMob.x+0.5*spawnedMob.width,spawnedMob.y+0.5*spawnedMob.height,spawnedMob.angle,spawnedMob.size,spawnedMob.size,0.5*sprite:getWidth(),0.5*sprite:getHeight())    
    --love.graphics.rectangle("line",spawnedMob.x,spawnedMob.y,spawnedMob.width,spawnedMob.height)
  end
  if spawnedMob.particles~=nil then
    love.graphics.draw(spawnedMob.particles,spawnedMob.x+spawnedMob.particlesx,spawnedMob.y+spawnedMob.particlesy)
    --love.graphics.circle("fill",projectile.x+projectile.particlesx,projectile.y+projectile.particlesy,20)
  end
  
  if spawnedMob.dx~=nil then
    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill",spawnedMob.dx,spawnedMob.dy,2)
  end
  
  love.graphics.setColor(1,1,1)
end

function spawnedMobsPurge()
  for i,spawnedMob in ipairs(spawnedMobs) do
    world:remove(spawnedMob)
  end
  spawnedMobs={}
end