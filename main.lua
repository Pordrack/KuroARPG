require "hsv"
require "bump"
require "TSerial" 
require "game"
require("startmenu")
require("controls")
require "player"
require "attacks"
require "elements"
require "platform"
require "loadLevels"
require "scroll"
require "colcheck"
require "intersect"
require "mobs"
require "camera"
require "skillbar"
require "tableCopier"
sparkles=require "sparkles"
talkies=require 'talkies'
bump = require 'bump'

--gamestarted=true
nextskin=1
maxplayers=1
spawnx=0
spawny=0
zoom=1.5
sizeFactor=1 --Zoom relatif a la taille de la fenetre
baseWidth=800
baseHeight=600
players={}
escapecd=0 --Un cooldown pour la touche échape, pour pas retirer le joueur apres être revenu au menu
clickcd=0
shakingTime=0
winnerNumber=0 --Le skinnumber du vainqueur
dusty=love.graphics.newFont("Dusty.ttf",50)
defaultFont=love.graphics.newFont()

upkey="w"
downkey="s"
leftkey="a"
rightkey="d"
rollkey="space"
interactkey="e"
runkey="lshift"
slowkey="q"
pausekey="escape"
shortcut1="1"
shortcut2="2"
shortcut3='3'
shortcut4="4"
shortcut5="5"
shortcut6="6"
skillKeys={shortcut1,shortcut2,shortcut3,shortcut4,shortcut5,shortcut6}

hand = love.mouse.getSystemCursor("hand")
arrowCursor = love.mouse.getSystemCursor("arrow")
sizeall=love.mouse.getSystemCursor("sizeall")
ibeam = love.mouse.getSystemCursor("ibeam")
pvisorImagedata=love.image.newImageData("sprites/visors/pvisor.png")
pvisor=love.mouse.newCursor(pvisorImagedata,6,6)
greensvisorImagedata=love.image.newImageData("sprites/visors/greensvisor.png")
greensvisor=love.mouse.newCursor(greensvisorImagedata,13,13)
redsvisorImagedata=love.image.newImageData("sprites/visors/redsvisor.png")
redsvisor=love.mouse.newCursor(redsvisorImagedata,13,13)

gamestarted=false
gamepaused=false
onDialog=false
changingControls=false

function love.load()
  love.graphics.setDefaultFilter("nearest","nearest")
  particleSprite=love.graphics.newImage("sprites/particle.png")
  runeSprite=love.graphics.newImage("sprites/runeParticle.png")
  iceParticle=love.graphics.newImage("sprites/iceParticle.png")
  heartParticle=love.graphics.newImage("sprites/heartParticle.png")
  
  
  if love.filesystem.read("controls")~=nil then --Si ils existent, on charge les controls configurés
    controls=TSerial.unpack(love.filesystem.read("controls"))
    upkey=controls[1]
    downkey=controls[2]
    leftkey=controls[3]
    rightkey=controls[4]
    rollkey=controls[5]
    interactkey=controls[6]
    runkey=controls[7]
    slowkey=controls[8]
    pausekey=controls[9]
    shortcut1=controls[10]
    shortcut2=controls[11]
    shortcut3=controls[12]
    shortcut4=controls[13]
    shortcut5=controls[14]
    shortcut6=controls[15]
    skillKeys={shortcut1,shortcut2,shortcut3,shortcut4,shortcut5,shortcut6}
  end
  
  disappearedNpcs={}
  if love.filesystem.read("disappearedNpcs")~=nil then-- Il regarde si le registre des pnj disparut existe
    disappearedNpcs=TSerial.unpack(love.filesystem.read("disappearedNpcs"))
  end
  
  talkies.indicatorCharacter="Appuyez sur "..love.keyboard.getKeyFromScancode(interactkey).." pour continuer"
  
  projectiles={}
  platforms={}
  scrolls={}
  loadAttacks()
  loadElements()
  loadPlatforms()
  loadScrolls()
  startmenuLoad()
  love.graphics.setFont(dusty)
  winnerParticles=love.graphics.newParticleSystem(particleSprite,320)
  winnerParticles:setLinearAcceleration(-10,-400,10,-500)
  winnerParticles:setColors(0.92,0.78,0.00,1,0.92,0.78,0.00,0)
  winnerParticles:setEmissionArea("ellipse",19*4,10,0,true)
  winnerParticles:setParticleLifetime(0.5,1.5)
  winnerParticles:setSizes(8.0)
  table.insert(players,newPlayer(nil,true))
  nextskin=nextskin+1
end

function love.update(dt)
  escapecd=escapecd-dt
  shakingTime=shakingTime-dt
  clickcd=clickcd-dt
  
  talkies.update(dt)

  if gamestarted==false and changingControls==false or gamepaused then
    startmenuUpdate(dt)
  elseif gamestarted and gamepaused==false and onDialog==false then
    gameUpdate(dt)
  elseif gamestarted and gamepaused==false and onDialog==true and onDialogElement~=nil then
    for i,spawnedElement in ipairs(spawnedElements) do
      if spawnedElement==onDialogElement then
        updateElement(spawnedElement,dt)
      end
    end
  elseif changingControls then
    controlsUpdate()
  end
  
  if love.keyboard.isDown(pausekey) and escapecd<0 then
    escapecd=0.2
    if gamestarted and onDialog==false then
      if gamepaused then gamepaused=false else gamepaused=true end
    elseif onDialog then
      talkies.clearMessages()
      onDialogElement=nil
      onDialog=false
    else
      changingControls=false
    end
  end
end

function love.draw()
  sizeFactor=love.graphics.getHeight()/baseHeight 
  love.graphics.scale(sizeFactor,sizeFactor)
  --love.graphics.print(#players,10,10)
    
  if gamestarted then
    gameDraw()
  elseif changingControls then
    controlsDraw()
  end
  
  if (gamestarted==false or gamepaused) and changingControls==false then
    --[[if gamestarted then
      love.graphics.scale(1/zoom,1/zoom) --Annule le zoom du jeu
    end]]
    startmenuDraw()
  end

end

function love.joystickremoved(joystick)
  for i, player in ipairs(players) do
    if players[i].joystick~=nil then
      if players[i].joystick==joystick then
        nextskin=player.skin
        if gamestarted then
          world:remove(player)
        end
        table.remove(players,i)
      end
      break;
    end
  end
end

function love.joystickadded(joystick)
  if #players<maxplayers then
    table.insert(players,newPlayer(joystick))
    nextskin=nextskin+1
  end
end

function love.keypressed(key,scancode) 
  if changingControls and modifiedControlNumber~=nil then
    controls[modifiedControlNumber]=scancode
    modifiedControlNumber=nil
    love.filesystem.write("controls",TSerial.pack(controls))
    upkey=controls[1]
    downkey=controls[2]
    leftkey=controls[3]
    rightkey=controls[4]
    rollkey=controls[5]
    interactkey=controls[6]
    runkey=controls[7]
    slowkey=controls[8]
    pausekey=controls[9]
    shortcut1=controls[10]
    shortcut2=controls[11]
    shortcut3=controls[12]
    shortcut4=controls[13]
    shortcut5=controls[14]
    shortcut6=controls[15]
    skillKeys={shortcut1,shortcut2,shortcut3,shortcut4,shortcut5,shortcut6}
    talkies.indicatorCharacter="Appuyez sur "..love.keyboard.getKeyFromScancode(interactkey).." pour continuer"
  end
  
  if scancode==interactkey or scancode==runkey or scancode==rollkey then
    talkies.onAction()
  end
  
  if scancode==upkey then
    talkies.prevOption()
  end
  
  if scancode==downkey then
    talkies.nextOption()
  end
end

function love.mousepressed( x, y, button, istouch, presses )
  if changingControls and modifiedControlNumber~=nil and tonumber(button)>2 then
    controls[modifiedControlNumber]=button
    modifiedControlNumber=nil
    love.filesystem.write("controls",TSerial.pack(controls))
    upkey=controls[1]
    downkey=controls[2]
    leftkey=controls[3]
    rightkey=controls[4]
    rollkey=controls[5]
    interactkey=controls[6]
    runkey=controls[7]
    slowkey=controls[8]
    pausekey=controls[9]
    shortcut1=controls[10]
    shortcut2=controls[11]
    shortcut3=controls[12]
    shortcut4=controls[13]
    shortcut5=controls[14]
    shortcut6=controls[15]
    skillKeys={shortcut1,shortcut2,shortcut3,shortcut4,shortcut5,shortcut6}
    talkies.indicatorCharacter="Appuyez sur "..love.keyboard.getKeyFromScancode(interactkey).." pour continuer"
  end
  
  local mouseButton=interactkey
  if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
  
  if button==mouseButton then talkies.onAction() end
  
  local mouseButton=rollkey
  if tonumber(mouseButton)==nil or tonumber(mouseButton)<=3 then mouseButton=0 end
  
  if button==mouseButton then talkies.onAction() end
end

function love.wheelmoved(x, y)
  if y>0 and love.keyboard.isDown("lctrl") then
    zoom=zoom+0.1
  elseif y<0 and zoom>1 and love.keyboard.isDown("lctrl") then
    zoom=zoom-0.1
  elseif gamestarted and onDialog==false then
    local condition2=true 
    if players[1].attack~=nil then condition2=(players[1].attack.hasEquipFunction~=true or players[1].attack.currentcd<0) end

    if y<0 and condition2 then
      players[1].cattack=players[1].cattack+1
      if players[1].cattack>#players[1].skillbar then players[1].cattack=1 end
    elseif condition2 then
      players[1].cattack=players[1].cattack-1
      if players[1].cattack<1 then players[1].cattack=#players[1].skillbar end
    end
    
    if condition2 then
      if players[1].attack~=nil then
        if players[1].attack.hasEquipFunction==true then
          players[1].attack:unequip(players[1])
        end
      end
    
      players[1].attack=players[1].skillbar[players[1].cattack]
      
      if players[1].attack~=nil then
        if players[1].attack.hasEquipFunction then
          players[1].attack:equip(players[1])
        end
      end
      love.mouse.setCursor(arrowCursor)
    end
  end
end
