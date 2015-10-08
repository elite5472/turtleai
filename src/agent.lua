require "class"
require "direction"
require "vector"
require "position"

Agent = Class:new({
	pos = Position:new();
	
	move_ahead = function(self)
		return turtle.forward()
	end;
	
	move_back = function(self)
		return turtle.back()
	end;
	
	move_up = function(self)
		return = turtle.up()
	end;
	
	move_down = function(self)
		return turtle.down()
	end;
	
	turn_left = function(self)
		return turtle.turnLeft()
	end;
	
	turn_right = function(self)
		return turtle.turnRight()
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
	
	update_knowledge = function(self)
		--detect_ahead, detect_up, detect_down
	end;
})