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
	
	parse = function(self, string)
		if string == "north" then
			return Direction:new({v = self.north})
		elseif string == "east" then
			return Direction:new({v = self.east})
		elseif string == "south" then
			return Direction:new({v = self.south})
		elseif string == "west" then
			return Direction:new({v = self.west})
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
		if self.v == self.north then return self.NORTH_VECTOR
		elseif self.v == self.east then return self.EAST_VECTOR
		elseif self.v == self.south then return self.SOUTH_VECTOR
		elseif self.v == self.west then return self.WEST_VECTOR
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