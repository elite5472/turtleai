

Class = {
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end;
}

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
		return right(right(self.v))
	end;
	
	to_string = function(self)
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


Vector = Class:new({
	x = 0;
	y = 0;
	z = 0;
})

function Vector:clone()
	return self:new({x = self.x, y = self.y, z = self.z})
end

function Vector:unpack()
	return self.x, self.y, self.z
end

function Vector:table()
	return {x = self.x, y = self.y, z = self.z}
end

function Vector:__tostring()
	return "("..self.x..","..self.y..","..tonumber(self.z)..")"
end

function Vector:to_string()
	return self:__tostring()
end

function Vector.__unm(a)
	return self:new({x = -a.x, y = -a.y, z = -a.z})
end

function Vector.__add(a,b)
	return Vector:new({x = a.x+b.x, y = a.y+b.y, z = a.z+b.z})
end

function Vector.__sub(a,b)
	return Vector:new({x = a.x-b.x, y = a.y-b.y, z = a.z-b.z})
end

function Vector.__mul(a,b)
	if type(a) == "number" then
		return Vector:new({x = a*b.x, y = a*b.y, z = a*b.z})
	elseif type(b) == "number" then
		return Vector:new({x = b*a.x, y = b*a.y, z = b*a.z})
	else
		return a.x*b.x + a.y*b.y + a.z*b.z
	end
end

function Vector.__div(a,b)
	return Vector:new({x = a.x / b, y = a.y / b, z = a.z / b})
end

function Vector.__eq(a,b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function Vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

function Vector.permul(a,b)
	return Vector:new({x = a.x*b.x, y = a.y*b.y, z = a.z*b.z})
end

function Vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector:len()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function Vector:dist(b)
	local dx = self.x - b.x
	local dy = self.y - b.y
	local dz = self.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Vector:normalize()
	return self / self:len()
end
Position = Class:new({
	loc = Vector:new();
	dir = Direction:parse("north");
})
Agent = Class:new({
	pos = Position:new();
	
	move_forward = function()
		
	end
})