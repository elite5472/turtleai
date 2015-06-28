function size(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

shaft = {
	{0, 0, 0, 0, 0},
	{0, 1, 0, 1, 0},
	{0, 1, 1, 1, 0},
	{0, 1, 0, 1, 0},
	{0, 0, 0, 0, 0}	
};

Direction = {
	north = 0,
	east = 1,
	south = 2,
	west = 3,
	
	v = 0,
	
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end,
	
	left = function(self)
		x = self.v - 1
		if x == -1 then x = 3 end
		return x
	end,
	
	right = function(self)
		x = self.v + 1
		if x == 4 then x = 0 end
		return x
	end,
	
	opposite = function(self)
		return right(right(self.v));	
	end
}

Position = {
	x = 0,
	y = 0,
	z = 0,
	d = Direction.new({v = Direction.north})
	
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end,
	
	delta = function(self, x)
		
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

function move(from, to)
	delta = {
		x = 
	}
end

function carve(from, shape, material_index)
	
end 