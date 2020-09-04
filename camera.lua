function cameraUpdate(dt)
  --[[if translatex<-players[1].x+(0.5*love.graphics.getWidth()/(zoom*sizeFactor))-12.5-dt*100 then
    translatex=translatex+dt*100
  elseif translatex>-players[1].x+(0.5*love.graphics.getWidth()/(zoom*sizeFactor))-12.5+dt*100 then
    translatex=translatex-dt*100
  else
    
  end]]
  translatex=-players[1].x+(0.5*love.graphics.getWidth()/(zoom*sizeFactor))-0.5*players[1].width
  translatey=-players[1].y+(0.5*love.graphics.getHeight()/(zoom*sizeFactor))-0.5*players[1].height
  
  if levelwidth>love.graphics.getWidth()/(zoom*sizeFactor) then
    if translatex>0 then translatex=0 end
    if levelwidth+translatex<love.graphics.getWidth()/(zoom*sizeFactor) then 
      translatex=love.graphics.getWidth()/(zoom*sizeFactor)-levelwidth 
    end
  end
  
  if levelheight>600/zoom then
    if translatey>0 then translatey=0 end
    if levelheight+translatey<600/zoom then translatey=600/zoom-levelheight end
  end
end

function cameraDraw()
  love.graphics.translate(translatex,translatey)
end