function startmenuLoad()
  math.randomseed(love.timer.getTime())
  play={
    x=love.graphics.getWidth()/2-(0.5*dusty:getWidth("Jouer"))/2,
    y=love.graphics.getHeight()/2+love.graphics.getHeight()/30,
    width=0.5*dusty:getWidth("Jouer"),
    height=0.5*dusty:getHeight("Jouer"),
    text="Jouer",
    color={1,1,1}
  }
  
  
  changeControls={
    x=love.graphics.getWidth()/2-(0.5*dusty:getWidth("Controles"))/2,
    y=love.graphics.getHeight()/2+2*(love.graphics.getHeight()/30),
    width=0.5*dusty:getWidth("Controles"),
    height=0.5*dusty:getHeight("Level editor"),
    text="Controles",
    color={1,1,1}
  }
  
  --logo=love.graphics.newImage("logo.png")
  translatex=0
  translatey=0
  sButton=nil
  --buttons={}
  
  --sparkles:newBolt(500,0,500,800,1,{1,1,1},nil)
  --print(math.sqrt(600^2+400^2))
end

function startmenuUpdate(dt)
  if translatex==nil then translatex=0 end
  if translatey==nil then translatey=0 end
  mouseX,mouseY=love.mouse.getPosition()
  mouseX=(mouseX)/(sizeFactor)-0.5*(love.graphics.getWidth()/(sizeFactor)-800)
  mouseY=(mouseY)/(sizeFactor)
  
  if gamestarted then
    play.text="Reprendre"
    play.x=400-(0.5*dusty:getWidth("Reprendre"))/2
    play.width=0.5*dusty:getWidth(play.text)
    changeControls.text="Menu"
    changeControls.x=400-(0.5*dusty:getWidth("Menu"))/2
    changeControls.width=0.5*dusty:getWidth(changeControls.text)
  else
    play.text="Jouer"
    play.x=400-(0.5*dusty:getWidth("Jouer"))/2
    play.width=0.5*dusty:getWidth(play.text)
    changeControls.text="Controles"
    changeControls.x=400-(0.5*dusty:getWidth("Controles"))/2
    changeControls.width=0.5*dusty:getWidth(changeControls.text)
  end
  
  if mouseX>play.x and mouseX<play.x+play.width and mouseY>play.y and mouseY<play.y+play.height then
    love.mouse.setCursor(hand)
    sButton="play"
    play.color={1,0,0}
    changeControls.color={1,1,1}
  elseif mouseX>changeControls.x and mouseX<changeControls.x+changeControls.width and mouseY>changeControls.y and mouseY<changeControls.y+changeControls.height then
    love.mouse.setCursor(hand)
    sButton="controls"
    play.color={1,1,1}
    changeControls.color={1,0,0}
  else
    love.mouse.setCursor(arrowCursor)
    sButton=nil
    play.color={1,1,1}
    changeControls.color={1,1,1}
  end
  
  if love.mouse.isDown(1) and sButton~= nil then
    if sButton=="play" then
      if gamestarted==false then
        gameLoad()
        gamestarted=true
        clickcd=0.2
        love.mouse.setCursor(arrowCursor)
      else
        clickcd=0.2
        gamepaused=false
        love.mouse.setCursor(arrowCursor)
      end
    end
    
    if sButton=="controls" and clickcd<0 then
      clickcd=0.2
      if gamestarted then
        changingControls=false
        gamestarted=false
        gamepaused=false
        gamestarted=false
        love.graphics.setBackgroundColor(0,0,0)
      else
        changingControls=true
        gamepaused=false
        gamestarted=false
        controlsLoad()
      end
      lastMenu=nil
    end
  end
  
end

function startmenuDraw()
  love.graphics.translate(0.5*(love.graphics.getWidth()/(sizeFactor)-800),0)
  local x=400-(0.5*dusty:getWidth("Controles"))/2
  love.graphics.setFont(dusty)
  --love.graphics.setColor(255/255, 153/255, 0/255)
  --love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
  love.graphics.setColor(1,1,1)
  love.graphics.setColor(play.color)
  love.graphics.print(play.text,play.x,play.y,0,0.5,0.5)
  love.graphics.setColor(changeControls.color)
  love.graphics.print(changeControls.text,changeControls.x,changeControls.y,0,0.5,0.5)
  love.graphics.setColor(1,1,1)
  
  sparkles:draw()
  --love.graphics.circle("fill",mouseX,mouseY,10)
end