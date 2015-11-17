require "agent"
require "astar"

BDI_Agent = Agent:new({
	
	knowledge = {
		prevpos = nil;
		pos = nil;
		map = Multitable:new();
		
		--Calibration desire
		direction_known = false;
		
		--A* Movement desire
		target_maint = false;		--Will always be false, agent always desires to go to its target if there is one.
		target_dig = false;			--When set to false, will not dig the target if occupied.
		target = nil;
		
		--Idle desire
		make_target_maint = false;
		
		--Mining desire
		chest_trigger = true;
		mine_location = nil;
		
		--Chop chop_tree
		chop_tree_maint = false;
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
				if agent.knowledge.target ~= nil then return 100 else return 0 end
			end;
		};
		
		mine_shaft = {
			conditions = "chest_trigger";
			priority = 20;
		};
		
		make_up_target = {
			conditions = "make_target_maint";
			priority = 1;
		};
	};
	
	plans = {
		mine_shaft = {
			preconditions = nil;
			goals = "chest_trigger";
			floor_blocks = nil;
			
			execute = function(self, agent, engine)
				if agent.knowledge.pos.loc.y < 50 then
					agent.knowledge.chest_trigger = true;
					return "mine_shaft: shaft finished"
				end
				
				if self.floor_blocks == nil then
					self.floor_blocks = List:new()
					local anchor =  agent.knowledge.mine_location.loc + 3*agent.knowledge.mine_location.dir:vector() + 3*agent.knowledge.mine_location.dir:right():vector()
					local d = anchor - agent.knowledge.mine_location.loc
					local xs = 1
					local zs = 1
					if d.x < 0 then xs = -1 end
					if d.z < 0 then zs = -1 end

					for posx = agent.knowledge.mine_location.loc.x, anchor.x, xs do
						for posz = agent.knowledge.mine_location.loc.z, anchor.z, zs do
							self.floor_blocks:add(Vector:new({x = posx, y = agent.knowledge.pos.loc.y, z = posz}))
						end
					end
				end
				
				if self.floor_blocks.size > 0 then
					closest = nil
					for x in self.floor_blocks:each() do
						if closest == nil or (x - agent.knowledge.pos.loc):abs():sum() < (closest - agent.knowledge.pos.loc):abs():sum() then
							closest = x
						end
					end
					agent.knowledge.target = closest
					self.floor_blocks:remove(closest)
					return "mine_shaft: target set"
				else
					self.floor_blocks = nil
					if agent:move_down() or (agent:dig_down() and agent:move_down()) then
						return "mine_shaft: moved down successfully"
					else
						return "mine_shaft: failed to move down"
					end
				end
				
			end;
		};
		
		travel = {
			preconditions = nil;
			goals = "target_maint";
			agent = nil;
			path = nil;
			target = nil;

			cost = function(a, b)
				local x = BDI_Agent.knowledge.map:get(b.x, b.y, b.z)
				if x == nil then
					return 1
				else
					return x.cost
				end
			end;
	
			estimate = function(a, b)
				local d = b - a
				local distance = math.abs(d.x) + math.abs(d.y) + math.abs(d.z)
				return distance
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
				
				if agent.knowledge.pos.loc == agent.knowledge.target then
					agent.knowledge.target = nil
					self.target = nil
					return "travel: agent at target.";
				end
				
				if agent.knowledge.target ~= nil and self.target ~= agent.knowledge.target then
					self.target = agent.knowledge.target
					--print("Searching " .. agent.knowledge.pos.loc:__tostring() .. " => " .. self.target:__tostring())
					self.path = search:find(agent.knowledge.pos.loc, self.target)
					--print("Search complete.")
					if self.path == nil then
						agent.knowledge.target = nil
						self.target = nil
						return "travel: path not found."
					end
					self.path:remove(self.path:get(0))
				end
				
				if self.path.size > 0 then
					local current = self.path:get(0) - agent.knowledge.pos.loc
					self.path:remove(self.path:get(0))
					local fail = false
					if current == Vector:new({y = 1}) then
						fail = not agent:move_up() and not (agent:dig_up() and agent:move_up())
					elseif current == Vector:new({y = -1}) then
						fail = not agent:move_down() and not (agent:dig_down() and agent:move_down())
					else
						local dir = Direction:from_vector(current)
						if dir == nil then 
							fail = true
						else
							fail = not (agent:turn_to(dir) and (agent:move_forward() or (agent:dig_forward() and agent:move_forward())))
						end
					end
					if fail then
						self.path = nil
						self.target = nil
						print(current:__tostring())
						return "travel: failed to move."
					else 
						return "travel: move successful."
					end
				else
					agent.knowledge.target = nil
					self.target = nil
					return "travel: unexpected path end."
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
						agent.knowledge.direction_known = true
						print("Direction calibrated, agent is facing " .. agent.knowledge.pos.dir:__tostring())
						return "SUCCESS"
					end
					agent:turn_left()
				end
				--Agent cannot determine direction, stop execution.
				return "EXIT"
			end
		};
		
		make_up_target = {
			preconditions = nil;
			goals = "make_target_maint";
			
			execute = function(self, agent, engine)
				local r = math.random(5)
				if r == 1 then
					agent.knowledge.target = Vector:new({x = 360, z = -450, y = 63})
				elseif r == 2 then
					agent.knowledge.target = Vector:new({x = 359, z = -448, y = 63})
				elseif r == 3  then
					agent.knowledge.target = Vector:new({x = 357, z = -448, y = 63})
				elseif r == 4  then
					agent.knowledge.target = Vector:new({x = 360, z = -446, y = 63})
				elseif r == 5 then
					agent.knowledge.target = Vector:new({x = 353, z = -448, y = 63})
				end
				return "SUCCESS"
			end;
		};
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
	
	check_forward = function(self)
		if self.knowledge.pos == nil then return nil end
		local x = self.knowledge.pos.loc + self.knowledge.pos.dir:vector()
		return self.knowledge.map:get(x.x, x.y, x.z)
	end;
	
	check_up = function(self)
		if self.knowledge.pos == nil then return nil end
		local x = self.knowledge.pos.loc + Vector:new({y = 1})
		return self.knowledge.map:get(x.x, x.y, x.z)
	end;
	
	check_down = function(self)
		if self.knowledge.pos == nil then return nil end
		local x = self.knowledge.pos.loc + Vector:new({y = -1})
		return self.knowledge.map:get(x.x, x.y, x.z)
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
		return true
	end;
	
	update_knowledge = function(self)
		--Step 1: Location
		local gpsx, gpsy, gpsz = gps.locate()
		if gpsx == nil then error("Unable to use gps location.") end
		if math.floor(gpsx) ~= gpsx or math.floor(gpsy) ~= gpsy or math.floor(gpsz) ~= gpsz then
			print("GPS location unreliable, retrying...")
			os.sleep(0.5)
			return self:update_knowledge()
		end
		local gpsv = Vector:new({
			x = gpsx;
			y = gpsy;
			z = gpsz;
		})
		
		--print(gpsv:__tostring())
		
		if self.knowledge.pos == nil then
			self.knowledge.pos = Position:new({
				loc = gpsv;
			})
		elseif self.knowledge.pos.loc ~= gpsv then
			self.knowledge.prevpos = self.knowledge.pos
			self.knowledge.pos = Position:new({
				loc = gpsv;
				dir = self.knowledge.prevpos.dir
			})
		end
		
		--Step 2: Orientation
		if (not self.knowledge.direction_known) and self.knowledge.prevpos ~= nil and self.knowledge.prevpos.loc:dist(self.knowledge.pos.loc) == 1 then
			--Data is there and reliable, calculate orientation.
			local ori = self.knowledge.pos.loc - self.knowledge.prevpos.loc
			self.knowledge.pos.dir = Direction:from_vector(ori)
		end
		
		--Step 3: Detection
		if self.knowledge.direction_known then
			local ds, dx, dv, entry
			ds, dx = self:inspect_forward()
			dv = self.knowledge.pos.loc + self.knowledge.pos.dir:vector()
			self:register_block(dv.x, dv.y, dv.z, dx)
			
			ds, dx = self:inspect_up()
			dv = self.knowledge.pos.loc + Vector:new({y = 1})
			self:register_block(dv.x, dv.y, dv.z, dx)
			
			ds, dx = self:inspect_down()
			dv = self.knowledge.pos.loc + Vector:new({y = -1})
			self:register_block(dv.x, dv.y, dv.z, dx)
		end
		
		
	end;
	
	register_block = function(self, x, y, z, block)
		local entry = nil
		if block == nil or type(block) == "string" then
			entry = {
				name = "empty";
				cost = 1;
			}
		elseif block.name == "minecraft:bedrock" then
			entry = {
				name = block.name;
				cost = -1;
			}
		elseif block.name == "minecraft:chest" then
			self.knowledge.chest_trigger = false
			self.knowledge.mine_location = Position:new({
				dir = self.knowledge.pos.dir:opposite();
				loc = self.knowledge.pos.loc;
			})
			entry = {
				name = block.name;
				cost = -1;
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
