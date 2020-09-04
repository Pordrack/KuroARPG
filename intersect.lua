--source : https://love2d.org/wiki/General_math

function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
		local min,max = math.min, math.max
		if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		   seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
			return false, "The lines don't intersect."
		end
	end
	return x,y
end
--
function segmentVsSegment(x1, y1, x2, y2, x3, y3, x4, y4)
  local dx1, dy1 = x2 - x1, y2 - y1
  local dx2, dy2 = x4 - x3, y4 - y3
  local dx3, dy3 = x1 - x3, y1 - y3
  local d = dx1*dy2 - dy1*dx2
  if d == 0 then
    return false
  end
  local t1 = (dx2*dy3 - dy2*dx3)/d
  if t1 < 0 or t1 > 1 then
    return false
  end
  local t2 = (dx1*dy3 - dy1*dx3)/d
  if t2 < 0 or t2 > 1 then
    return false
  end
  -- point of intersection
  return true, x1 + t1*dx1, y1 + t1*dy1
end