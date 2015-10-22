require "class"

ListIterator = Class:new({
	current = nil;
	__call = function(self)
		self.current = self.current.next
		if self.current ~= nil then return self.current.value else return nil end	
	end;
})

List = Class:new({
	list = nil;
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
			self.tail = self.tail.next
		end
		self.size = self.size + 1
	end;
	
	last = function(self)
		return self.tail.value
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
	
	pop_first = function(self)
		if self.size == 0 then return nil end
		local out = self.list
		self.list = self.list.next
		self.size = self.size - 1
		return out.value
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
			out:add(current.value)
			current = current.next
		end 
		return out
	end;
	
	each = function(self)
		return ListIterator:new({ current = { next = self:copy().list, value = nil } })
	end;
	
	__tostring = function(self)
		local string = "{"
		local first = true
		local current = self.list
		while current ~= nil do
			if not first then string = string .. ", " end
			string = string .. current.value:__tostring()
			current = current.next
			first = false
		end
		string = string .. "}"
		return string
	end
}); 