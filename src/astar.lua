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
		print("c1")
		while open.size > 0 do
			print("c10")
			local path = open:get(0)
			if shortest == nil or path.cost < shortest.cost then
				local last = path.nodes:last()
				print("c11 " .. last:__tostring())
				local expansion = self.expand(last)
				print("c12 " .. expansion:__tostring())
				for x in expansion:each() do
					print("c9")
					io.read()
					if not path.nodes:contains(x) then
						print("c2")
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
				end
			end
			open:remove(path)
		end
		return shortest
	
	end;
});