function colcheck(item, other)
    if other.name=="scroll" or item.name=="scroll" or item.tangibility==false or other.tangibility==false then
      return 'cross'
    elseif item.swarmleader==other or other.swarmleader==item or (item.swarmleader~=nil and item.swarmleader==other.swarmleader) then
      return 'cross'
    else
      return 'slide'
    end
end  