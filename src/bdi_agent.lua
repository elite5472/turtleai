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
			agent = nil;
			path = nil;
			target = nil;

			cost = function(a, b)
				local x = agent.knowledge.map:get(b.x, b.y, b.z)
				if x ~= nil then
					return 2
				else
					return x.cost
				end
			end;
	
			estimate = function(a, b)
				local d = b - a
				return math.abs(d.x) + math.abs(d.y) + math.abs(d.z)
			end;
	
			expand = function(a)
				local l = List:new()
				l:add(a + Direction.NORTH_VECTOR)
				l:add(a + Direction.SOUTH_VECTOR)
				l:add(a + Direction.EAST_VECTOR)
				l:add(a + Direction.WEST_VECTOR)
				l:add(a + Vector:new({y = 1}))
				l:add(a + Vector:new({y = -1}))
				return l
			end;			

			execute = function(self, agent, engine)
				self.agent = agent
				local search = AStar:new({
					cost = self.cost;
					estimate = self.estimate;
					expand = self.expand
				})
				
				if agent.knowledge.target ~= nil and self.target ~= agent.knowledge.target then
					self.target = agent.knowledge.target
					self.path = search:find(agent.knowledge.pos.loc, self.target)
				end
				
				if agent.knowledge.pos.loc == self.target then
					agent.knowledge.target = nil
					return "SUCCESS";
				end
				
				if self.path.nodes.size > 0 then
					local current = self.path:get(0) - agent.knowledge.pos.loc
					local fail = false
					if current == Vector:new({y = 1}) then
						fail = not agent:move_up() or not (agent:dig_up() and agent:move_up())
					elseif current == Vector:new({y = -1}) then
						fail = not agent:move_down() or not (agent:dig_down() and agent:move_down())
					else
						local dir = Direction:from_vector(current)
						if dir == nil then 
							fail = true
						else
							fail = not (agent:turn_to(dir) and agent:move_forward())
						end
					end
					if fail then return "FAILURE" else return "CONTINUE" end
				else
					agent.knowledge.target = nil
					return "FAILURE"
				end
			end
		};
		
		find_direction = {
			preconditions = nil;
			goals = "direction_known";
			
			execute = function(self, agent, engine)
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
		local r = Agent.turn_left(self)
		if self.knowledge.pos ~= nil then
			self.knowledge.pos.dir = self.knowledge.pos.dir:left()
		end
		return r
	end;
	
	turn_right = function(self)
		local r = Agent.turn_right(self)
		if self.knowledge.pos ~= nil then
			self.knowledge.pos.dir = self.knowledge.pos.dir:right()
		end
		return r
	end;
	
	turn_around = function(self)
		return self:turn_right() and self:turn_right()
	end;
	
	turn_to = function(self, direction)
		local d = self.knowledge.pos.dir
		if d:right() == direction then
			return self:turn_right()
		elseif d:left() == direction then
			return self:turn_left()
		elseif d:opposite() == direction then
			return self:turn_around()
		end
	end;
	
	update_knowledge = function(self)
		--Step 1: Location
		local gpsx, gpsy, gpsz = gps.locate()
		local gpsv = Vector:new({
			x = gpsx;
			y = gpsy;
			z = gpsz;
		})
		
		if self.knowledge.pos == nil then
			self.knowledge.pos = Position:new({
				loc = gpsv;
			})
		elseif self.knowledge.pos.loc ~= gpsv then
			self.knowledge.prevpos = knowledge.pos
			self.knowledge.pos = Position:new({
				loc = gpsv;
				dir = self.knowledge.prevpos.dir
			})
		end
		
		--Step 2: Orientation
		if self.knowledge.prevpos ~= nil and self.knowledge.prevpos.loc:dist(knowledge.pos.loc) == 1 then
			--Data is there and reliable, calculate orientation.
			local ori = self.knowledge.pos.loc - self.knowledge.prevpos.loc
			if ori == self.NORTH_VECTOR then
				self.knowledge.pos.dir = Direction:parse("north")
			elseif ori == self.SOUTH_VECTOR then
				self.knowledge.pos.dir = Direction:parse("south")
			elseif ori == self.WEST_VECTOR then
				self.knowledge.pos.dir = Direction:parse("west")
			elseif ori == self.EAST_VECTOR then
				self.knowledge.pos.dir = Direction:parse("east")
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
		local entry = nil
		print("Hello")
		print(type(block))
		print(block.name)
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
