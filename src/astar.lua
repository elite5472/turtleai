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
		local shortest = nil
		local open = List:new()
		local c = function(a, b)
			if (a.cost + a.estimate) > (b.cost + b.estimate) then
				return 1
			elseif (a.cost + a.estimate) < (b.cost + b.estimate) then
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
			local path = open:get(0)
			if shortest == nil or path.cost < shortest.cost then
				local last = path.nodes:last()
				local expansion = self.expand(last)
				for x in expansion:each() do
					if not path.nodes:contains(x) then
						new_path = {
							nodes = path.nodes:copy();
							cost = path.cost + self.cost(path.nodes:last(), x);
							estimate = self.estimate(x, b);
						}
						new_path.nodes:add(x)
						print(x:__tostring())
						print(b:__tostring())
						if x == b and (shortest == nil or shortest.cost > new_path.cost) then
							print("Foud path!")
							shortest = new_path
						else
							open:sort_in(new_path, c)
						end
					end
				end
			end
			open:remove(path)
		end
		return shortest
	
	end;
});