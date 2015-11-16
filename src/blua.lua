require "class"
require "string_extensions"

Blua = Class:new{
	
	agent = nil;
	
	step = function(self)
		if self.agent.update_knowledge ~= nil then self.agent:update_knowledge() end
		local d = self:check_desires();
		if d == nil then return "NO_DESIRE" end
		return self:set_intent(d.conditions);
	end;
	
	
	set_intent = function(self, intent)
		local fitness = nil
		local chosen = nil
		for k, v in pairs(self.agent.plans) do
			if self:evaluate_conditions(intent, v.goals) and self:evaluate_conditions(v.preconditions, self.agent.knowledge) then
				local fval
				if v.fitness == nil then
					fval = nil
				elseif type(v.fitness) == "number" then
					fval = v.fitness
				else
					fval = v:fitness(self.agent)
				end
				
				if fval == nil then
					return v:execute(self.agent, self);
				elseif fitness == nil then
					chosen = v.execute
					fitness = fval
				elseif fval > fitness then
					chosen = v.execute
					fitness = fval
				end
			end
		end
		if chosen ~= nil then return chosen(self.agent, self) end
		return "NO_PLAN";		
	end;
	
	check_desires = function(self)
		local desire = nil;
		for k, v in pairs(self.agent.desires) do
			local d = self:check_desire(k);
			if not self:evaluate_conditions(d.conditions, self.agent.knowledge) then
				if desire == nil or desire.priority < d.priority then
					desire = d;
				end
			end
		end
		
		if desire.priority <= 0 then
			return nil
		end
		
		return desire;
	end;
	
	check_desire = function(self, desire)
		local p = nil
		local t = type(self.agent.desires[desire].priority)
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
	
	parse_condition_string = function(self, s)
		if s == nil then return {} end
		if type(s) == "table" then return s end
		if type(s) ~= "string" then error("Unexpected type on parse_condition_string") end
		s = string.gsub(s, " ", "")
		local t = {}
		for i, x in ipairs(string.split(s, "&")) do
			local not_check = string.gsub(x, "!", "")
			if x ~= not_check then
				t[not_check] = false
			else
				t[not_check] = true
			end
		end
		return t
	end;
	
	evaluate_conditions = function(self, required, current)
		required = self:parse_condition_string(required);
		current = self:parse_condition_string(current);
		
		for k, v in pairs(required) do
			if (v ~= current[k]) and (current[k] ~= nil or v) then
				return false
			end
		end
		return true
	end;
}