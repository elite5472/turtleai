require "class"

Blua = Class:new{
	
	agent = nil;
	
	step_once = function(self)
		print("BDI Pass Started")
		if self.agent.update_knowledge ~= nil then self.agent:update_knowledge() end
		local d = self:check_desires();
		if d == nil then return "NO_DESIRE" end
		return self:set_intent(d.conditions);
	end;
	
	step_through = function(self)
		local result = nil;
		while result ~= "EXIT" do
			result = self:step_once();
			print("Step result: " .. result)
		end
		return "EXIT"
	end;
	
	set_intent = function(self, intent)
		print("Looking for plans for " .. intent)
		for k, v in pairs(self.agent.plans) do
			print("Evaluating " .. k)
			if self:evaluate_conditions(intent, v.goals) and self:evaluate_conditions(v.preconditions, self.agent.knowledge) then
				return v:execute(agent, self);
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
			if not evaluate_conditions(d.conditions, self.agent.knowledge) then
				--print(d.name .. " => " .. d.priority)
				if desire == nil or desire.priority < d.priority then
					desire = d;
				end
			end
		end
		
		if desire.priority == 0 then
			return nil
		end
		
		return desire;
	end;
	
	check_desire = function(self, desire)
		local p = nil
		local t = type(desire.priority)
		if t == "function" then
			p = self.agent.desires[desire]:priority(self.agent)
		elseif t == "number" then
			p = self.agent.desires[desire].priority
		else
			error("Desire " .. desire .. "'s priority must be a number or function.")
		end
		
		return {
			name = desire;
			conditions = self.agent.desires[desire].conditions;
			priority = p;
		};
	end;
	
	parse_condition_string = function(self, string)
		if type(string) == "table" then return string end;
		return {
			[string] = true;
		};
	end;
	
	evaluate_conditions = function(self, required, current)
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