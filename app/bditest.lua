require "blua"

agent = {
	
	fuel = 0;
	
	knowledge = {
		fuel = 0;
		full = false;
	};
	
	desires = {
		randomstuff = {
			conditions = "stuff";
			priority = function(agent)
				return 10;
			end;
		};
		
		be_full = {
			conditions = "full";
			priority = function(agent)
				return 100 - agent.fuel
			end;
		};
	};
	
	plans = {
		fill = {
			preconditions = nil;
			goals = "full";
			execute = function(agent, engine)
				agent:update_knowledge();
				agent:eat();
				return "SUCCESS";
			end
		};
	};
	
	update_knowledge = function(self)
		self.knowledge.fuel = self.fuel;
		if self.fuel > 50 then
			print("update_knowledge: agent is full.\n");
			self.knowledge.full = true; 
		else
			print("update_knowledge: agent is not full.\n");
			self.knowledge.full = false;
		end
	end;
	
	eat = function(self)
		print("eating!\n");
		self.fuel = self.fuel + 20;
	end;
	
	__tostring = function(self)
		return "bdiagent";
	end;
}

print(agent);
blua = Blua:new({agent = agent});
while agent.fuel < 50 do
	blua:step_once();
end