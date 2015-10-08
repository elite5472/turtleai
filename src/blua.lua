require "class"

Blua = Class:new{
	
	agent = nil;
	
	step_once = function(self)
		print("step_once")
		local d = self:check_desires();
		return self:set_intent(d.conditions);
	end;
	
	step_through = function(self)
		local result = nil;
		while result ~= "EXIT" do
			result = self:step_once();
		end
		return "EXIT"
	end;
	
	set_intent = function(self, intent)
		print("Looking for plans for...")
		print(intent)
		for k, v in pairs(self.agent.plans) do
			print("Evaluating...")
			print(k)
			if self:evaluate_conditions(intent, v.goals) and self:evaluate_conditions(v.preconditions, self.agent.knowledge) then
				return v.execute(agent, self);
			end
		end
		return "NO_MATCH";		
	end;
	
	check_desires = function(self)
		local desire = nil;
		print("Checking desires...");
		for k, v in pairs(self.agent.desires) do
			print(k);
			local d = self:check_desire(k);
			print(d.priority)
			if desire == nil or desire.priority < d.priority then
				desire = d;
			end
		end
		print("Desire picked!");
		print(desire.name);
		return desire;
	end;
	
	check_desire = function(self, desire)
		return {
			name = desire;
			conditions = self.agent.desires[desire].conditions;
			priority = self.agent.desires[desire].priority(self.agent);
		};
	end;
	
	parse_condition_string = function(self, string)
		if type(string) == "table" then return string end;
		return {
			[string] = true;
		};
	end;
	
	evaluate_conditions = function(self, required, current)
		print("Evaluating conditions required/current...")
		print(required)
		print(current)
		if required == nil then
			required = {};
		else
			required = self:parse_condition_string(required);
		end
		
		if current == nil then
			current = {};
		else
			current = self:parse_condition_string(current);
		end
		
		for k, v in pairs(required) do
			if (v ~= current[k]) and (current[k] ~= nil or v) then
				return false
			end
		end
		return true
	end;
}