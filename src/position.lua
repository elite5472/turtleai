require "class"
require "direction"
require "vector"

Position = Class:new({
	loc = Vector:new();
	dir = Direction:parse("north");
})