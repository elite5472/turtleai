require "class"
require "direction"
require "vector"
require "position"

Agent = Class:new({
	pos = Position:new();
	
	move_ahead = function(self)
		r = turtle.forward()
		if r then
			self.pos.loc = self.pos.loc + self.pos.dir:vector()
		end
		return r
	end;
	
	move_back = function(self)
		r = turtle.back()
		if r then
			self.pos.loc = self.pos.loc + self.pos.dir:opposite():vector()
		end
		return r
	end;
	
	move_up = function(self)
		r = turtle.up()
		if r then
			self.pos.loc = self.pos.loc + Vector:new({z = 1})
		end
		return r
	end;
	
	move_down = function(self)
		r = turtle.down()
		if r then
			self.pos.loc = self.pos.loc + Vector:new({z = -1})
		end
		return r
	end;
	
	dig_ahead = function(self)
		return turtle.dig()
	end;
	
	dig_down = function(self)
		return turtle.digDown()
	end;
	
	dig_up = function(self)
		return turtle.digUp()
	end;
	
	place_ahead = function(self)
		return turtle.place()
	end;
	
	place_up = function(self)
		return turtle.placeUp()
	end;
	
	place_down = function(self)
		return turtle.placeDown()
	end;
	
	detect_ahead = function(self)
		return turtle.detect()
	end;
	
	detect_up = function(self)
		return turtle.detectUp()
	end;
	
	detect_down = function(self)
		return turtle.detectDown()
	end;
	
	select_item = function(self, inventory_id)
		return turtle.select()
	end;
})