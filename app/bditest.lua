agent = {
	
	fuel = 0;
	
	knowledge = {
		fuel = 0;
		full = false;
	};
	
	desires = {
		be_full = {
			conditions = "full";
			priority = function(agent)
			{
				return 100 - agent.fuel
			};
		};
	};
	
	plans = {
		fill = {
			preconditions = nil;
			goals = "full";
			execute = function(agent, engine)
			{
				agent:update_knowledge();
				while not agent.knowledge.full do
					agent:eat();
				end	
				return "SUCCESS";
			};
		};
	}
	
	update_knowledge = function(self)
	{
		self.knowledge.fuel = self.fuel;
		if self.fuel > 50 then 
			self.knowledge.full = true; 
		else 
			self.knowledge.full = false;
		end
	};
	
	eat = function(self)
	{
		self.fuel = self.fuel + 20;
	};
}