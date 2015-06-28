Direction = {
	north = 0;
	east = 1;
	south = 2;
	west = 3;
	
	v = 0;
	
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end;
	
	parse = function(self, string)
		if string == "north" then
			return self:new({v = 0})
		elseif string == "east" then
			return self:new({v = 1})
		elseif string == "south" then
			return self:new({v = 2})
		elseif string == "west" then
			return self:new({v = 3})
	end;
	
	left = function(self)
		x = self.v - 1
		if x == -1 then x = 3 end
		return x
	end;
	
	right = function(self)
		x = self.v + 1
		if x == 4 then x = 0 end
		return x
	end;
	
	opposite = function(self)
		return right(right(self.v));	
	end
}

function rotate(from, to)
{
	if to.v == from:left() then
		turtle.turnLeft()
	elseif to.v == from:right() then
		turtle.turnRight()
	elseif to.v == from:opposite() then
		turtle.turnRight()
		turtle.turnRight()
	end
	
}

local tArgs = {...}

a = Direction:parse(tArgs[1])
b = Direction:parse(tArgs[2])

rotate(a, b)
