function loadPlatforms()
  platformRightSprite=love.graphics.newImage("sprites/platform/right.png")
  platformMiddleSprite=love.graphics.newImage("sprites/platform/middle.png")
  platformLeftSprite=love.graphics.newImage("sprites/platform/left.png")
  platformSingleSprite=love.graphics.newImage("sprites/platform/single.png")
  platformCenterSprite=love.graphics.newImage("sprites/platform/center.png")
  platformLeftWallSprite=love.graphics.newImage("sprites/platform/leftwall.png")
  platformRightWallSprite=love.graphics.newImage("sprites/platform/rightwall.png")
  platformDownSprite=love.graphics.newImage("sprites/platform/down.png")
  specialTrioSprite=love.graphics.newImage("sprites/platform/medium.png")
  noSprite=love.graphics.newImage("sprites/platform/noSprite.png")
  pillarSprite=love.graphics.newImage("sprites/platform/pillar.png")
  pillarData=love.image.newImageData("sprites/platform/pillar.png")
end

function newPlatform(x,y,sprite,width,height)
  local platform={
    name="platform",
    sprite=sprite,
    x=x,
    y=y,
    width=sprite:getWidth(),
    height=sprite:getHeight(),
  }
  if width~=nil then platform.width=width end
  if height~=nil then platform.height=height end
  
  world:add(platform,platform.x,platform.y,platform.width,platform.height)
  table.insert(platforms,platform)
end

function platformDraw()
  for i,platform in ipairs(platforms) do
    if platform.x>-translatex-50 and platform.y>-translatey-50 and platform.x<-translatex+love.graphics.getWidth()+50 and platform.y<-translatey+love.graphics.getHeight()+50 then
      love.graphics.draw(platform.sprite,platform.x,platform.y)
    end
  end
end