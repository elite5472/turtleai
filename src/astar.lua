require "class"
require "multitable"
require "list"

AStar = Class:new({
	
	cost = function(a, b)
		return 1
	end;
	
	estimate = function(a, b)
		return 1
	end;
	
	expand = function(a)
		return List:new()
	end;
	
	find = function(self, a, b)
		if a == b then return nil end
		local shortest = nil
		local open = List:new()
		local c = function(a, b)
			if (a.estimate) > (b.estimate) then
				return 1
			elseif (a.estimate) < (b.estimate) then
				return -1
			else
				return 0
			end
		end
		
		local start = {
			nodes = List:new();
			cost = 0;
			estimate = self.estimate(a, b);
		}
		start.nodes:add(a)
		open:add(start)
		while open.size > 0 do
			local path = open:pop_first()
			if shortest == nil or path.cost + path.estimate < shortest.cost then
				local last = path.nodes:last()
				local expansion = self.expand(last)
				for x in expansion:each() do
					if not path.nodes:contains(x) and self.cost(path.nodes:last(), x) ~= -1 then
						new_path = {
							nodes = path.nodes:copy();
							cost = path.cost + self.cost(path.nodes:last(), x);
							estimate = self.estimate(x, b);
						}
						new_path.nodes:add(x)
						if x == b and (shortest == nil or shortest.cost > new_path.cost) then
							shortest = new_path
						else
							open:sort_in(new_path, c)
						end
					end
					if self.cost(path.nodes:last(), x) == -1 and x == b then
						return nil
					end
				end
			end
		end
		return shortest.nodes
	
	end;
});