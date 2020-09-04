local sparkles={
  _DESCRIPTION = 'A lightning bolts/electricity fx library for Love2d',
  
  bolts={},
  boltSystems={} --All the systems, which are "animation" of alternatings bolts
}

function sparkles:newBoltSystem(x1,y1,x2,y2,numberOfBolts,width,colors,lifetime,splitRate,gen,minOffset,maxOffset,fps)
  if splitRate==nil then splitRate=10 end
  if splitRate>10 then splitRate=10 end
  local system={
    x1=x1,
    y1=y1,
    x2=x2,
    y2=y2,
    width=width,
    colors=colors,
    splits={},
    fps=fps,
    bolts={},
    splitRate=splitRate,
    minOffset=minOffset,
    maxOffset=maxOffset,
  }
  
  --Set all unfilled properties with default ones
  if system.fps==nil then system.fps=5 end
  if system.minOffset==nil then system.minOffset=0.1*math.sqrt((system.x2-system.x1)^2+(system.y2-system.y1)^2) end
  if system.maxOffset==nil then system.maxOffset=0.15*math.sqrt((system.x2-system.x1)^2+(system.y2-system.y1)^2) end
  if system.width==nil then system.width=1 end
  if system.colors==nil then system.colors={{1,1,1}} end
  if lifetime~=nil then system.lifetime=lifetime end
  if gen==nil then gen=4 end
  if numberOfBolts==nil then numberOfBolts=2 end
  
  if type(colors[1])=="number" then --If theres only one color, which isnt part of a table, then it create a table with just this one
    system.colors={colors}
  end
  
  --Generates the first bolts of the system, with different lifetimes
  for i=1,numberOfBolts do
    local offset=0.01*math.random(system.minOffset*100,system.maxOffset*100)
    local color=system.colors[math.random(1,#system.colors)]
    local newBolt=sparkles:newBolt(x1,y1,x2,y2,i*(system.width/numberOfBolts),color,system.lifetime,splitRate,gen,offset,nil,system.fps,false)
    table.insert(system.bolts,newBolt)
  end
  
  table.insert(sparkles.boltSystems,system)
  return system
end

function sparkles:newBolt(x1,y1,x2,y2,width,color,lifetime,splitRate,gen,offset,jiggle,fps,isSplit)
  if splitRate==nil then splitRate=10 end
  if splitRate>10 then splitRate=10 end
  local bolt={
    x1=x1,
    y1=y1,
    x2=x2,
    y2=y2,
    xs={x1,x2},
    ys={y1,y2},
    points={x1,y1,x2,y2},
    width=width,
    color=color,
    splits={},
    jiggle=jiggle,
    fps=fps,
    isSplit=isSplit,
    splitRate=splitRate,
    offset=offset,
  }
  
  --The jiggle was buggy, so I "disabled" it
  if bolt.fps==nil then bolt.fps=0.0001 end
  if bolt.jiggle==nil then bolt.jiggle=0 end
  bolt.jiggleTimer=1/bolt.fps
  
  --Set unfilled properties to default ones
  if bolt.offset==nil then bolt.offset=math.random(10,20)*0.01*math.sqrt((bolt.x2-bolt.x1)^2+(bolt.y2-bolt.y1)^2) end
  if bolt.width==nil then bolt.width=1 end
  if bolt.color==nil then bolt.color={1,1,1} end
  if lifetime~=nil then bolt.lifetime=lifetime end
  if gen==nil then gen=4 end
  
  --Will generates "middle" points of next generations
  local xs=bolt.xs
  local ys=bolt.ys
  
  for i=1,gen do
    for j=1,2*#xs-2,2 do
      --Current segment (the one which will get divided) length
      local dist=math.sqrt((xs[j+1]-xs[j])^2+(ys[j+1]-ys[j])^2)
      --And his angle
      local angle=math.atan2(ys[j+1]-ys[j],xs[j+1]-xs[j])
      local offsetDist=bolt.offset--*math.random(80,120)*0.01 --Once randomized the offset, but was just buggy and not interesting
      local offsetAngle=angle-0.5*math.pi --Randomly offset the new point to the "top" or to the "bottom" of the current segment
      if math.random(100)>=50 then
        offsetAngle=angle+0.5*math.pi 
      end
      local newDist=math.random(45,55)*0.01*dist --Distance from the segment start, more or less putted on the middle
      local newX=xs[j]+math.cos(angle)*newDist --New point's x, before offset
      newX=newX+math.cos(offsetAngle)*offsetDist --New point's x, now offsetted
      --print("xs[j+1]"..xs[j+1].."xs[j]"..xs[j])
      --print(x1.." "..math.floor(newX).." "..x2.." offdist ="..offsetDist)
      --print("dist "..dist.." newDist "..newDist.." angle "..angle.." offsetAngle "..offsetAngle.." offsetAngle-angle"..offsetAngle-angle)
      
      --Same with Y
      local newY=ys[j]+math.sin(angle)*newDist
      newY=newY+math.sin(offsetAngle)*offsetDist
      
      --Will, potentially, create a split, a new tiny bolt with less gen, and which follow the "original" angle
      if splitRate>0 and math.random(0,10)>10-splitRate then
        local x2,y2
        local splitDist=newDist*math.random(8,9)/10
        x2=xs[j]+math.cos(angle)*splitDist
        y2=ys[j]+math.sin(angle)*splitDist
        
        --The split is a new bolt, but which isnt inserted in the main array for bolts, 
        local newSplit=sparkles:newBolt(xs[j],ys[j],x2,y2,nil,nil,nil,(splitRate/2)-1,gen-1,bolt.offset,1,12,true)
        table.insert(bolt.splits,newSplit) --instead, it's putted in a special dedicated array
      end
      
      table.insert(xs,j+1,newX) --The new poit is added
      table.insert(ys,j+1,newY)
    end
    bolt.offset=bolt.offset/2 --Each gen has twice as less offset
  end
  
  bolt.points={} --We gather xs and ys in one single array, to render it with the "line" function
  for i=1,#xs do
    table.insert(bolt.points,xs[i])
    table.insert(bolt.points,ys[i])
  end
  
  if isSplit~=true then
    table.insert(sparkles.bolts,bolt)
  end
  
  return bolt
end

function sparkles:update(dt)
  for i,bolt in ipairs(sparkles.bolts) do
    if bolt.lifetime~=nil then 
      --Look if it should destroy the bolt because of it's lifetime
      bolt.lifetime=bolt.lifetime-dt
      if bolt.lifetime<=0 then
        sparkles:remove(bolt)
      end
    end
    
    --Like I said earlier, the jiggling is buggy, so it's not used and shouldn't be, but I left it anyway
    bolt.jiggleTimer=bolt.jiggleTimer-dt
    if bolt.jiggleTimer<0 then
      local jiggle=bolt.jiggle
      --on fait les points de l'éclair principal
      for j=1,#bolt.points-1 do
        bolt.points[j]=bolt.points[j]+math.random(-1,1)*jiggle
      end
      
      --Puis les splits
      jiggle=jiggle*3
      for j,split in ipairs(bolt.splits) do
        for k=1,#split.points do
          bolt.points[k]=bolt.points[k]+math.random(-1,1)*jiggle
        end
      end
      bolt.jiggleTimer=1/bolt.fps
    end
    
  end
  
  for i,system in ipairs(sparkles.boltSystems) do
    if system.lifetime~=nil then 
      --Look if the system should get deleted
      system.lifetime=system.lifetime-dt
      if system.lifetime<=0 then
        sparkles:remove(system)
      end
    end
    for j,bolt in ipairs(system.bolts) do
      --Reduce the width of every bolt of the system, depending of it's fps
      bolt.width=bolt.width-dt*system.fps
      if bolt.width<=0 then
        --Replace the bolts which became too thins with new ones, creating the "succession" effect
        local offset=0.01*math.random(system.minOffset*100,system.maxOffset*100)
        local color=system.colors[math.random(1,#system.colors)]
        local newBolt=sparkles:newBolt(system.x1,system.y1,system.x2,system.y2,system.width,color,system.lifetime,system.splitRate,system.gen,offset,nil,system.fps,false)
        table.insert(system.bolts,newBolt)
        sparkles:remove(bolt)
        table.remove(system.bolts,j)
      end
    end
  end
end

--This function move the x1 and x2 points of a given bolt, but doesn't move the other points
--It looks very ugly and buggy, and shouldnt be used, instead, update the system and let the "succession" effect do their job
--Or create a new bolt alltogether
function sparkles:updateBolt(boltToUpdate,x1,y1,x2,y2,lifetime,width,color)
  for i,bolt in ipairs(sparkles.bolts) do
    if bolt==boltToUpdate then
      if x1~=nil then bolt.x1=x1 end
      if y1~=nil then bolt.y1=y1 end
      if x2~=nil then bolt.x2=x2 end
      if y2~=nil then bolt.y2=y2 end
      bolt.points[1]=bolt.x1
      bolt.points[2]=bolt.y1
      bolt.points[#bolt.points-1]=bolt.x2
      bolt.points[#bolt.points]=bolt.y2
      
      if lifetime~=nil then bolt.lifetime=lifetime end
      if width~=nil then bolt.width=width end
      if color~=nil then bolt.color=color end
    end
  end
end


--Update the properties of a sysem. Changing the x1 and x2 will take effect on all the bolts to be generated, but wont "move" the
--Current ones, so it works better with a system with high fps
function sparkles:updateSystem(systemToUpdate,x1,y1,x2,y2,numberOfBolts,width,colors,lifetime)
  for i,system in ipairs(sparkles.boltSystems) do
    if system==systemToUpdate then
      if x1~=nil then system.x1=x1 end
      if y1~=nil then system.y1=y1 end
      if x2~=nil then system.x2=x2 end
      if y2~=nil then system.y2=y2 end
      if numberOfBolts~=nil then system.numberOfBolts=numberOfBolts end
      if lifetime~=nil then system.lifetime=lifetime end
      if width~=nil then system.width=width end
      if colors~=nil then 
        system.colors=colors 
        if type(colors[1])=="number" then --If theres only one color, which isnt part of a table, then it create a table with just this one
          system.colors={colors}
        end
      end
    end
  end
end

--Delete every system and bolt
function sparkles:purge()
  sparkles.bolts={}
  sparkles.boltSystems={}
end

--Remove either a system or a singular bolt
function sparkles:remove(boltToRemove)
  local removed=false
  for i,bolt in ipairs(sparkles.bolts) do
    if bolt==boltToRemove then
      table.remove(sparkles.bolts,i)
      removed=true
    end
  end
  
  if removed==false then
    for i,system in ipairs(sparkles.boltSystems) do
      if system==boltToRemove then
        for j,bolt in ipairs(system.bolts) do
          sparkles:remove(bolt)
        end
        table.remove(sparkles.boltSystems,i)
      end
    end
  end
end

function sparkles:draw() --Render every system and bolt, pretty straightforward
  for i,bolt in ipairs(sparkles.bolts) do
    love.graphics.setColor(bolt.color)
    if bolt.width>0 then
      love.graphics.setLineWidth(bolt.width)
    
      love.graphics.line(bolt.points)
      love.graphics.setLineWidth(bolt.width*0.5) --The splits are twice as thin as the main bolt, for esthetic reasons
    
      for j,split in ipairs(bolt.splits) do
        love.graphics.line(split.points)
      end
    end
  end
  love.graphics.setColor(1,1,1) --Reset the color to white, to not mess with further render from the main program
end

return sparkles
