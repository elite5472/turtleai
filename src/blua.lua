require "class"

Blua = Class:new{
	
	agent = nil;
	
	step_once = function(self)
	{
		local d = self:check_desires();
		return self:set_intent(d.conditions);
	};
	
	step_through = function(self)
	{
		local result = nil;
		while result != "EXIT" do
			result = self:step_once();
		end
		return "EXIT"
	};
	
	set_intent = function(self, intent)
	{
		for k, v in self.agent.plans do
			if self:evaluate_conditions(intent, self.agent.goals) and self:evaluate_conditions(v.preconditions, self.agent.knowledge) then
				return v.execute(agent, self);
			end
		end
		return "NO_MATCH";		
	};
	
	check_desires = function(self)
	{
		local desire = nil;
		for k, v in self.agent.desires do
			local d = self.check_desire(k);
			if desire == nil or desire.priority < d.priority then
				desire = d;
			end
		end
		return desire;
	};
	
	check_desire = function(self, desire)
	{
		return {
			name = desire;
			conditions = self.agent.desires[desire].conditions;
			priority = self.agent.desires[desire].priority(agent);
		};
	};
	
	parse_condition_string = function(self, string)
	{
		return {
			[string] = true;
		};
	}
	
	evaluate_conditions = function(self, required, current)
	{
		required = self:parse_condition_string(required);
		current = self:parse_condition_string(current);
		for k, v in required do
			if (v != current[k]) and (current[k] != nil or v)
				return false
			end
		end
		return true
	}
}