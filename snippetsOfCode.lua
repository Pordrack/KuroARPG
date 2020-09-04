  
  --Truc pour tester le coeur partiel, a inseré avant "talkies:draw()" dans game.lua, dans la partie pour HUD
  local x=(5+math.floor(players[1].life)*(players[1].lifeIcon:getWidth()+5))*sizeFactor
  local y=(5+(1-1)*(players[1].lifeIcon:getHeight()+15))*sizeFactor
  local width=(players[1].life-math.floor(players[1].life))*players[1].lifeIcon:getWidth()*sizeFactor+1
  local height=players[1].lifeIcon:getHeight()*sizeFactor+1
  love.graphics.circle("fill",x,y,2)
  love.graphics.setColor(1,0,0,0.5)
  love.graphics.rectangle("fill",x,y,width,height)
  love.graphics.setColor(1,1,1,1)