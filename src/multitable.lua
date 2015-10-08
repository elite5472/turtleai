require "class"

Multitable = Class:new({
	set = function(self, value, ...)
		local previus = nil;
		local index = nil;
		local current = self;
		for i, v in ipairs(arg) do
			if current[v] == nil then current[v] = {} end;
			previous = current;
			index = v;
			current = current[v];
    	end
		
		previous[index] = value;
	end;
	
	get = function(self, ...)
		local previous = nil;
		local index = nil;
		local current = self;
		for i, v in ipairs(arg) do
			if current[v] == nil then 
				return nil;
			end;
			previous = current;
			index = v;
			current = current[v];
		end
		
		return previous[index];
	end
});