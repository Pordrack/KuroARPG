function loadLevel(levelnumber,levelname)
  --love.graphics.setBackgroundColor(0.00,0.04,0.10)
  sparkles:purge()
  for i,element in ipairs(spawnedElements) do
    if element.width~=nil then world:remove(element) end
    element.x=nil
    element.life=0
    element.width=nil
  end
  spawnedElements={}
  for i,projectile in ipairs(projectiles) do
    if projectile.width~=nil then world:remove(projectile) end
  end
  projectiles={}
  for i,platform in ipairs(platforms) do
    if platform.width~=nil then world:remove(platform) end
  end
  platforms={}
  scrolls={}
  particlesSystems={} --Les systemes de particules "independants" /!\ ne regroupe pas tous les sytemes de particules, juste ceux qui ont une position definie, genre le wakfu d'un mob mort, ou les etincelles d'un pong fu qui a repondit
  for i,mob in ipairs(spawnedMobs) do
    if mob.width~=nil then world:remove(mob) end
  end
  spawnedMobs={} --Les monstres actuellement spawné dans le niveau, avec leurs positions etc...
  mobsToSpawn={} --Pour faire respawn les monstres, montre tous les mobs du niveau a son début
  --killedMobs={} --Les monstres tués, pour les revive au prochain respawn du joueur
  translatex=0
  translatey=0
  shakingTime=0
  freepaths={}
  lavaSprite=love.graphics.newImage("sprites/lava.png")
  local signSprite=love.graphics.newImage("sprites/sign.png")
  
  if levelname~=nil then
    currentLevel=levelname
    local tiledmap=require(levelname)
    --Creer une image et une imagedata pour chaque tile des tileset
    local tilesSprites={}
    local tilesImagedata={}
    for i,tileset in ipairs(tiledmap.tilesets) do
      for j=1,#tileset.tiles do
        local sprite=love.graphics.newImage(tileset.tiles[j].image)
        local data=love.image.newImageData(tileset.tiles[j].image)
        table.insert(tilesSprites,tileset.firstgid+tileset.tiles[j].id,sprite)
        table.insert(tilesImagedata,tileset.firstgid+tileset.tiles[j].id,data)
      end
    end
    --Ajuste la hauteur de niveau 
    levelheight=tiledmap.height*tiledmap.tileheight
    levelwidth=tiledmap.width*tiledmap.tilewidth
    --Place des barrieres/les updates
    if upBorder==nil then
      upBorder={x=0,y=-1,width=tiledmap.width*tiledmap.tilewidth,height=1}
      world:add(upBorder,upBorder.x,upBorder.y,upBorder.width,upBorder.height)
    else
      upBorder.width=tiledmap.width*tiledmap.tilewidth
      world:update(upBorder,upBorder.x,upBorder.y,upBorder.width,upBorder.height)
    end
    
    if downBorder==nil then
      downBorder={x=0,y=levelheight,width=tiledmap.width*tiledmap.tilewidth,height=1}
      world:add(downBorder,downBorder.x,downBorder.y,downBorder.width,downBorder.height)
    else
      downBorder.y=levelheight
      downBorder.width=tiledmap.width*tiledmap.tilewidth
      world:update(downBorder,downBorder.x,downBorder.y,downBorder.width,downBorder.height)
    end
    
    if leftBorder==nil then
      leftBorder={x=-1,y=0,width=1,height=levelheight}
      world:add(leftBorder,leftBorder.x,leftBorder.y,leftBorder.width,leftBorder.height)
    else
      leftBorder.height=levelheight
      world:update(leftBorder,leftBorder.x,leftBorder.y,leftBorder.width,leftBorder.height)
    end
    
    if rightBorder==nil then
      rightBorder={x=levelwidth,y=0,width=1,height=levelheight}
      world:add(rightBorder,rightBorder.x,rightBorder.y,rightBorder.width,rightBorder.height)
    else
      rightBorder.height=levelheight
      rightBorder.x=levelwidth
      world:update(rightBorder,rightBorder.x,rightBorder.y,rightBorder.width,rightBorder.height)
    end
    
    --Parcours les layers
    for i,layer in ipairs(tiledmap.layers) do
      if layer.name=="platforms" then --Charge toutes les tiles plateformes
        for j=1,#layer.data do
          if layer.data[j]>0 then
            local x,y,sprite
            y=math.ceil(j/tiledmap.width)-1
            x=j-y*tiledmap.width-1
            sprite=tilesSprites[layer.data[j]]
            newPlatform(x*tiledmap.tilewidth,y*tiledmap.tileheight,sprite)
          end
        end
      elseif layer.name=="background" then --charge les tiles decos du fond
        for j=1,#layer.data do
          if layer.data[j]>0 then
            local x,y,sprite
            y=math.ceil(j/tiledmap.width)-1
            x=j-y*tiledmap.width-1
            sprite=tilesSprites[layer.data[j]]
            deco:new(x*tiledmap.tilewidth,y*tiledmap.tileheight,sprite,false)
          end
        end
      elseif layer.type=="objectgroup" then --charge les objets
        for j,object in ipairs(layer.objects) do
          if object.type=="mob" then -- CHARGE UN MOB
            local properties=object.properties
            local mobToSpawn={
                name=object.name,
                x=object.x,
                y=object.y,
                attack=properties.attack,
                linkid=properties.linkid,
                precision=properties.precision,
                spd=properties.spd,
                attackcd=properties.attackcd,
                life=properties.life,
              }
            for k,monster in ipairs(mobs) do
              if monster.name==object.name then
                local newMob=monster:new(object.x,object.y,properties.attack,properties.linkid)
                if properties.attackcd~=nil then newMob.maxattackcd=properties.attackcd end
                if properties.life~=nil then newMob.life=properties.life  newMob.maxlife=properties.life end
                if properties.spd~=nil then newMob.spd=properties.spd newMob.baseSpd=properties.spd end
                if properties.precision~=nil then newMob.precision=properties.precision end
                if properties.linkid~=nil then
                  for l,freepath in ipairs(freepaths) do --On regarde si une trajectoire libre est associée
                    if freepath.linkid==properties.linkid then
                      newMob.path=freepath
                      mobToSpawn.path=freepath
                      table.remove(freepaths,l)
                      break;
                    end
                  end
                end
              end
            end
            table.insert(mobsToSpawn,mobToSpawn)
          elseif object.type=="mobPath" then -- CHARGE UNE TRAJECTOIRE
            addPath(object)
          elseif object.type=="element" then --CHARGE UN ELEMENT
            if object.name=="source" then --SOURCE DE WAKFU
              source:new(object.x,object.y,object.width,object.height)
            elseif object.name=="mapChangerBegin" then --CHANGEUR DE MAP DE DEBUT
              local properties=object.properties
              mapChangerBegin:new(object.x,object.y,object.width,object.height,properties.destmap,properties.linkid)
            elseif object.name=="mapChangerEnd" then --CHANGEUR DE MAP DE FIN
              local properties=object.properties
              mapChangerEnd:new(object.x,object.y,properties.linkid)
            elseif object.name=="altar" then --ALTAR POUR CHANGER LES ATTAQUES
              altar:new(object.x,object.y)
            elseif object.name=="moving" then --MOVING PLATFORM (YES I MIX FRENCH AND ANGLAIS)
              --moving:new(x1,y1,x2,y2,spd,sprite,linkid,width,height,loop)
              local properties=object.properties
              moving:new(object.x,object.y,properties.x2,properties.y2,properties.spd,tilesSprites[object.gid],properties.linkid,nil,nil,properties.loop,properties.tangibility)
            elseif object.name=="button" then --TRIGGER BUTTON
              local properties=object.properties
              local buttoner=button:new(object.x,object.y,properties.linkid,properties.tangibility,properties.interactable,properties.attack)
            elseif object.name=="mobdetector" then --TRIGGER MOB DETECTOR
              local properties=object.properties
              mobdetector:new(object.x,object.y,properties.linkid,properties.radius,properties.maxmob,properties.tangibility)
            elseif object.name=="heart" then --ELEMENT COEUR
              heart:new(object.x,object.y)
            elseif object.name=="npc" then --PNJ
              --npc:new(x,y,sprite,npcname,message)
              local properties=object.properties
              npc:new(object.x,object.y,tilesSprites[object.gid],properties.npcname,properties.message,properties.attack,properties.disappear,properties.destmap,properties.linkid)
            elseif object.name=="savepoint" then --PHENIX
              savepoint:new(object.x,object.y)
            elseif object.name=="deco" then --DECORATION
              --deco:new(x,y,sprite,foreground,text,color)
              local properties=object.properties
              if object.shape=="text" then
                local color={object.color[1]/255,object.color[2]/255,object.color[3]/255}
                deco:new(object.x,object.y,nil,properties.foreground,object.text,color)
              else
                deco:new(object.x,object.y,tilesSprites[object.gid],properties.foreground)
              end
            elseif object.name=="falling" then --PLATEFORME QUI TOMBE
              --falling:new(x,y,timer,spriteData,width,height)
              local properties=object.properties
              falling:new(object.x,object.y,properties.timer,tilesImagedata[object.gid])
            elseif object.name=="damage" then --DAMAGE (lave, pic etc...)
              --damage:new(x,y,damage,sprite,width,height)
              local properties=object.properties
              damage:new(object.x,object.y,properties.damage,properties.tangibility,tilesSprites[object.gid])
            elseif object.name=="platform" then --PLATEFORME HORS TILESET
              --newPlatform(x,y,sprite,width,height)
              newPlatform(object.x,object.y,tilesSprites[object.gid])
            end
          elseif object.name=="spawnpoint" then --Charge l'objet spawnpoint
            spawnx=math.floor(object.x)
            spawny=math.floor(object.y)
            print("new spoint point has been set to "..spawnx.." "..spawny)
          end
        end
      end
    end
  elseif levelnumber==1 then
    for y=0,40 do
      newPlatform(-1*20,y*20,platformSingleSprite)
      newPlatform(0,y*20,platformSingleSprite)
      --newPlatform(39*20,y*20)
      --newPlatform(40*20,y*20)
    end
    
    for x=0,40 do
      --newPlatform(x*20,0,platformSingleSprite)
      newPlatform(x*20,40*20,platformSingleSprite)
      newPlatform(x*20,41*20,platformSingleSprite)
      newPlatform(x*20,42*20,platformSingleSprite)
    end
    
    for x=41,200 do
      falling:new(x*20,40*20,0.025,pillarData)
      damage:new(x*20,41*20,1,lavaSprite)
      newPlatform(x*20,42*20,platformSingleSprite)
    end
    
    for x=201,500 do
      --newPlatform(x*20,0,platformSingleSprite)
      newPlatform(x*20,40*20,platformSingleSprite)
      newPlatform(x*20,41*20,platformSingleSprite)
      newPlatform(x*20,42*20,platformSingleSprite)
    end
    
    --PLATEFORMES 
    
    --newPlatform(20*20,20*20,platformSingleSprite)
    
    --SCROLLS
    
    --PORTALS 
    
    --portal:new(150,750,650,750,20);
    npc:new(400,40*20,signSprite,"Une putain de pancarte",{"Bienvenu jeune Eliatrope*, bienvenue sur Incarnam ! Depuis que tout le monde a deserté, il n y a plus personne pour te préparer aux dangers du Monde des Treizes ici. Mais pas d'inquiétude, tu auras à ta disposition d'autres pancartes comme moi pour te guider. Pour commencer pourquoi ne pas essayé de placer des portails afin de rejoindre l'ile à ta droite ? Pour placer ton premier portail, clique avec le clique gauche à l'endroit de ton choix, puis maintient appuyé tout en orientant le portail vers la direction de ton choix. Puis fait la même chose avec le clique droit pour ton deuxieme portail. Traverser un de tes portails de téléportera alors à l'autre, en conservant ta vitesse.\n\n\n*Dans l'eventualité ou vous n'êtes pas un Eliatrope, merci d'ignorer cette pancarte et d'en chercher une correspondant à votre classe. "})
    savepoint:new(600,40*20)
    
    bouftou:new(500,600)
    source:new(40,40*20)
    local button1=button:new(140,750,"bbba")
    moving:new(200,770,600,400,100,specialTrioSprite,"bbba",nil,nil,true)
    for x=0,20 do
      newPlatform(700+x*20,400,platformSingleSprite)
    end
    bouftou:new(700,320)
    bouftou:new(770,320)
    bouftou:new(840,320)
    bouftou:new(910,320)
    bouftou:new(980,320)
    bouftou:new(1050,320)
    
    local detector1=mobdetector:new(900-8,320,"bbbb",400)
    
    moving:new(1150,400,1150,0,100,specialTrioSprite,"bbbb",nil,nil,true)
    
    spawnx=50
    spawny=100
    
    levelheight=43*20
  end
end