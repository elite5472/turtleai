require "class"
require "direction"
require "vector"

Position = Class:new({
	loc = Vector:new();
	dir = Direction:parse("north");
	
	__tostring =  function(self)
		return dir:tochar() .. loc
	end;
})