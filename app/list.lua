require "list"

l = List:new()
l:add("a")
l:add("b")
l:add("c")
l:add("d")
l:add("e")

for x in l:each() do
	print(x)
end

print(l)