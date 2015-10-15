require "class"
require "vector"

Direction = Class:new({
	NORTH_VECTOR = Vector:new({z = -1});
	SOUTH_VECTOR = Vector:new({z =  1});
	WEST_VECTOR = Vector:new({x = -1});
	EAST_VECTOR = Vector:new({x = 1});
	
	north = 0;
	east = 1;
	south = 2;
	west = 3;
	
	v = 0;
	
	parse = function(self, s)
		local s = string.lower(s)
		if s == "north" then
			return Direction:new({v = self.north})
		elseif s == "east" then
			return Direction:new({v = self.east})
		elseif s == "south" then
			return Direction:new({v = self.south})
		elseif s == "west" then
			return Direction:new({v = self.west})
		end
	end;
	
	left = function(self)
		local x = self.v - 1
		if x == -1 then x = 3 end
		return Direction:new({v = x})
	end;
	
	right = function(self)
		local x = self.v + 1
		if x == 4 then x = 0 end
		return Direction:new({v = x})
	end;
	
	opposite = function(self)
		return self:right():right()
	end;
	
	vector = function(self)
		if self.v == self.north then return self.NORTH_VECTOR
		elseif self.v == self.east then return self.EAST_VECTOR
		elseif self.v == self.south then return self.SOUTH_VECTOR
		elseif self.v == self.west then return self.WEST_VECTOR
		end
	end;
	
	from_vector = function(self, v)
		if v == self.NORTH_VECTOR then return self:parse("north")
		elseif v == self.SOUTH_VECTOR then return self:parse("south")
		elseif v == self.EAST_VECTOR then return self:parse("east")
		elseif v == self.WEST_VECTOR then return self:parse("west")
		end
	end;
	
	__tostring = function(self)
		if self.v == self.north then
			return "North"
		elseif self.v == self.east then
			return "East"
		elseif self.v == self.south then
			return "South"
		elseif self.v == self.west then
			return "West"
		end
	end;
	
	__eq = function(a, b)
		return a.v == b.v
	end;
	
	tochar = function(self)
		if self.v == self.north then
			return "N"
		elseif self.v == self.east then
			return "E"
		elseif self.v == self.south then
			return "S"
		elseif self.v == self.west then
			return "W"
		end
	end;
})