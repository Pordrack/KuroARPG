function controlsLoad()
  controls={upkey,downkey,leftkey,rightkey,rollkey,interactkey,runkey,slowkey,pausekey,shortcut1,shortcut2,shortcut3,shortcut4,shortcut5,shortcut6}
  names={"Haut","Bas","Gauche","Droite","Esquiver","Interagir","Course","Dilatation temporelle","Pause","Attaque 1","Attaque 2","Attaque 3","Attaque 4","Attaque 5","Attaque 6"}
  saveAndQuitButton={
    x=20,
    y=20,
    text="Menu",
    width=0.5*dusty:getWidth("Menu"),
    height=0.5*dusty:getHeight("Menu"),
  }
  modifiedControlNumber=nil
end

function controlsUpdate(dt)
  love.mouse.setCursor(arrowCursor)
  local mouseX,mouseY=love.mouse.getPosition()
  mouseX=mouseX/sizeFactor-0.5*(love.graphics.getWidth()/(sizeFactor)-800)
  mouseY=mouseY/sizeFactor
  if love.keyboard.isDown("escape") then
    modifiedControlNumber=nil
  end
  for i=1,#controls do
    local string=names[i].." : "..controls[i]
    local width=0.5*dusty:getWidth(string)
    local height=0.5*dusty:getHeight(string)
    local x=400-0.5*width
    local y=10+i*(height+10)
    if mouseX>x and mouseX<x+width and mouseY>y and mouseY<y+height then
      love.mouse.setCursor(hand)
      if love.mouse.isDown(1) and clickcd<0 then
        modifiedControlNumber=i
      end
    end
  end
  
  if mouseX>saveAndQuitButton.x and mouseX<saveAndQuitButton.x+saveAndQuitButton.width and mouseY>saveAndQuitButton.y and mouseY<saveAndQuitButton.y+saveAndQuitButton.height then
    love.mouse.setCursor(hand)
    if love.mouse.isDown(1) then
      changingControls=false
    end
  end
end

function controlsDraw()
  --love.graphics.setColor(255/255, 153/255, 0/255)
  --love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  local mouseX,mouseY=love.mouse.getPosition()
  mouseX=mouseX/sizeFactor-0.5*(love.graphics.getWidth()/(sizeFactor)-800)
  mouseY=mouseY/sizeFactor
  love.graphics.translate(0.5*(love.graphics.getWidth()/(sizeFactor)-800),0)
  if mouseX>saveAndQuitButton.x and mouseX<saveAndQuitButton.x+saveAndQuitButton.width and mouseY>saveAndQuitButton.y and mouseY<saveAndQuitButton.y+saveAndQuitButton.height then
    love.graphics.setColor(1,0,0)
  else
    love.graphics.setColor(1,1,1)
  end
  love.graphics.print(saveAndQuitButton.text,saveAndQuitButton.x,saveAndQuitButton.y,0,0.5,0.5)
  
  for i=1,#controls do
    local string=names[i].." : "..love.keyboard.getKeyFromScancode(controls[i])
    local width=0.5*dusty:getWidth(string)
    local height=0.5*dusty:getHeight(string)
    local x=400-0.5*width
    local y=10+i*(height+10)
    local color={1,1,1}
    if mouseX>x and mouseX<x+width and mouseY>y and mouseY<y+height then
      color={1,0,0}
    end
    if modifiedControlNumber==i then
      color={0.2,0.2,1}
    end
    love.graphics.setColor(color)
    love.graphics.setFont(dusty)
    love.graphics.print(string,x,y,0,0.5,0.5)
    love.graphics.setColor(1,1,1)
  end
  
  love.graphics.print("Zoom : lctrl+molette",400-0.25*dusty:getWidth("Zoom : lctrl+molette"),10+(#controls+1)*(0.5*dusty:getHeight("Z")+10),0,0.5,0.5)
end
