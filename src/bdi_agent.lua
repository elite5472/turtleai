require "agent"
require "astar"

BDI_Agent = Agent:new({
	
	knowledge = {
		prevpos = nil;
		pos = nil;
		map = Multitable:new();
		direction_known = false;
		target_maint = false;
		target = nil;
	};
	
	desires = {
		--Agent has to determine its current direction in order to function properly.
		get_direction = {
			conditions = "direction_known";
			priority = 150;
		};
		
		--Mainteinance desire to approach any target defined by other plans.
		get_to_target = {
			conditions = "target_maint";
			priority = function(self, agent)
				if agent.knowledge.target ~= nil and agent.knowledge.target ~= agent.knowledge.pos.loc then return 100 else return 0 end
			end;
		};
	};
	
	plans = {
		travel = {
			preconditions = nil;
			goals = "target_maint";
			path = nil;
			target = nil;
			execute = function(self, agent, engine)
				agent:update_knowledge();
				
				if agent.knowledge.pos.loc == agent.knowledge.target then
					agent.knowledge.target = nil
					return "SUCCESS";
				end
			end
		};
		
		find_direction = {
			preconditions = nil;
			goals = "direction_known";
			execute = function(self, agent, engine)
				agent:update_knowledge()
				for i = 1, 4 do
					if agent:move_forward() then
						agent:update_knowledge()
						direction_known = true
						print("Direction calibrated, agent is facing " .. agent.knowledge.pos.dir)
						return "SUCCESS"
					end
					agent:turn_left()
				end
				--Agent cannot determine direction, stop execution.
				return "EXIT"
			end
		}
	};
	
	turn_left = function(self)
		r = Agent.turn_left(self)
		if knowledge.pos ~= nil then
			knowledge.pos.dir = knowledge.pos.dir:left()
		end
		return r
	end;
	
	turn_right = function(self)
		r = Agent.turn_right(self)
		if knowledge.pos ~= nil then
			knowledge.pos.dir = knowledge.pos.dir:right()
		end
		return r
	end;
	
	
	update_knowledge = function(self)
		--Step 1: Location
		local gpsx, gpsy, gpsz = gps.locate()
		local gpsv = Vector:new({
			x = gpsx;
			y = gpsy;
			z = gpsz;
		})
		
		if knowledge.pos == nil then
			knowledge.pos = Position:new({
				loc = gpsv;
			})
		elseif knowledge.pos.loc ~= gpsv then
			knowledge.prevpos = knowledge.pos
			knowledge.pos = Position:new({
				loc = gpsv;
				dir = knowledge.prevpos.dir
			})
		end
		
		--Step 2: Orientation
		if knowledge.prevpos ~= nil and knowledge.prevpos.loc:dist(knowledge.pos.loc) == 1 then
			--Data is there and reliable, calculate orientation.
			local ori = knowledge.pos.loc - knowledge.prevpos.loc
			if ori == self.NORTH_VECTOR then
				knowledge.pos.dir = Direction:parse("north")
			elseif ori == self.SOUTH_VECTOR then
				knowledge.pos.dir = Direction:parse("south")
			elseif ori == self.WEST_VECTOR then
				knowledge.pos.dir = Direction:parse("west")
			elseif ori == self.EAST_VECTOR then
				knowledge.pos.dir = Direction:parse("east")
			end
		end
		
		--Step 3: Detection
		local ds, dx, dv, entry
		ds, dx = self:inspect_forward()
		dv = self.knowledge.pos.loc + self.knowledge.pos.dir:vector()
		self:register_block(dv.x, dv.y, dv.z, dx)
		
		ds, dx = self:inspect_up()
		dv = self.knowledge.pos.loc + self.knowledge.pos.dir:vector()
		self:register_block(dv.x, dv.y, dv.z, dx)
		
		ds, dx = self:inspect_down()
		dv = self.knowledge.pos.loc + self.knowledge.pos.dir:vector()
		self:register_block(dv.x, dv.y, dv.z, dx)
	end;
	
	register_block = function(self, x, y, z, block)
		if block == nil then
			entry = {
				name = "empty";
				cost = 1;
			}
		elseif string.find(block.name, "water") then
			entry = {
				name = block.name;
				cost = 1;
			}
		elseif string.find(block.name, "lava") then
			entry = {
				name = block.name;
				cost = 1;
			}
		else
			entry = {
				name = block.name;
				cost = 2;
			}
		end
		self.knowledge.map:set(entry, x, y, z)
	end;  
})
