require "class"
require "vector"

Direction = Class:new({
	north = 0;
	east = 1;
	south = 2;
	west = 3;
	
	v = 0;
	
	parse = function(self, string)
		if string == "north" then
			return self:new({v = 0})
		elseif string == "east" then
			return self:new({v = 1})
		elseif string == "south" then
			return self:new({v = 2})
		elseif string == "west" then
			return self:new({v = 3})
		end
	end;
	
	left = function(self)
		local x = self.v - 1
		if x == -1 then x = 3 end
		return x
	end;
	
	right = function(self)
		local x = self.v + 1
		if x == 4 then x = 0 end
		return x
	end;
	
	opposite = function(self)
		return self:right(self:right(self.v))
	end;
	
	vector = function(self)
		if self.v == 0 then return Vector:new({x = 0, y = 1})
		elseif self.v == 1 then return Vector:new({x = 1, y = 0})
		elseif self.v == 2 then return Vector:new({x = 0, y = -1})
		elseif self.v == 3 then return Vector:new({x = -1, y = 0})
		end
	end;
	
	__tostring = function(self)
		if self.v == 0 then
			return "north"
		elseif self.v == 1 then
			return "east"
		elseif self.v == 2 then
			return "south"
		elseif self.v == 3 then
			return "west"
		end
	end;
})