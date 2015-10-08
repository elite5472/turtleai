require "class"

List = Class:new({
	list =  nil;
	tail = nil;
	size = 0;
	
	goto = function(self, i)
		if i < 0 then return nil end
		local current = self.list
		local count = 0
		while current ~= nil do
			if i == count then return current end
			count = count + 1
			current = current.next
		end
		return nil
	end;
	
	get = function(self, i)
		return self:goto(i).value
	end;
	
	add = function(self, o)
		if self.size == 0 then
			self.list = {next = nil, value = o}
			self.tail = self.list
		else
			self.tail.next = {next = nil, value = o}
		end
		self.size = self.size + 1
	end;
	
	sort_in = function(self, o, comparator)
		local current = self.list
		local previous = current
		while current ~= nil do
			if comparator(o, current.value) > 0 then
				previous = current
				current = current.next
			elseif previous == current then
				self.list = {next = current, value = o}
				self.size = self.size + 1
				return
			else
				previous.next = {next = current, value = o}
				self.size = self.size + 1
				return
			end
		end
		self:add(o)
	end;
	
	sort_in_list = function(self, l, comparator)
		for o in l:each() do
			self:sort_in(o, comparator)
		end
	end;
	
	contains = function(self, o)
		for x in self:each() do
			if x == o then return true end
		end
		return false
	end;
	
	remove = function(self, o)
		local previous = nil
		local current = self.list
		while current ~= nil do
			if current.value == o then
				if previous == nil then
					self.list = current.next
					self.size = self.size - 1
				else
					previous.next = current.next
					self.size = self.size - 1
				end
			end	
			previous = current
			current = current.next
		end
	end;
	
	copy = function(self)
		local out = List:new()
		local current = self.list
		while current ~= nil do
			List:add(current.value)
		end
		return out
	end;
	
	each = function(self)
		local current = self:copy().list
		return function()
			current = current.next
			if current ~= nil then return current.value else return nil end
		end
	end;
	
	__tostring = function(self)
		local string = "{"
		local first = true
		local current = self.list
		while current ~= nil do
			if not first then string = string .. ", " end
			string = string .. current.value
			current = current.next
			first = false
		end
		string = string .. "}"
		return string
	end
});