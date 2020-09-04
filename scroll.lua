function loadScrolls()
  scrollSprite=love.graphics.newImage("sprites/scroll.png")
end

function newScroll(x,y)
  local scroll={
    name="scroll",
    x=x,
    y=y,
    sprite=scrollSprite,
    width=scrollSprite:getWidth(),
    height=scrollSprite:getHeight()
  }
  scroll.particles=love.graphics.newParticleSystem(runeSprite,50)
  scroll.particles:emit(75)
  scroll.particles:setLinearAcceleration(0,25,0,50)
  scroll.particles:setEmissionArea("uniform",(scroll.width/2)-3,0,0,true)
  scroll.particles:setColors(0.5,0.5,0.5,255,0.5,0.5,0.5,0)
  scroll.particles:setSizes(0.8,0.2)
  scroll.particles:setParticleLifetime(0.5,1.5)
  scroll.particlesx=scroll.x+scroll.width*0.5
  scroll.particlesy=scroll.y+scroll.height*0.9
  world:add(scroll,scroll.x,scroll.y,scroll.width,scroll.height)
  table.insert(scrolls,scroll)
end

function updateScroll(scroll,dt)
  scroll.particles:emit(75)
  scroll.particles:update(dt)
  local x,y,cols,len=world:check(scroll,scroll.x,scroll.y,colcheck)
  for i,col in ipairs(cols) do
    if col.other.name=="player" then
      col.other.attackcd=0
      col.other.attack=attacks[love.math.random(1,#attacks)]
      for i,cScroll in ipairs(scrolls) do
        if cScroll==scroll then
          world:remove(scroll)
          table.remove(scrolls,i)
          break;
        end
      end
    end
  end
end

function drawScroll(scroll)
  love.graphics.draw(scroll.particles,scroll.particlesx,scroll.particlesy)
  love.graphics.draw(scrollSprite,scroll.x,scroll.y)
  --love.graphics.rectangle("line",scroll.x,scroll.y,scroll.width,scroll.height)
end