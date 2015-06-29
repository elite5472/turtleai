require "Direction"

function rotate(from, to)
	if to.v == from:left() then
		turtle.turnLeft()
	elseif to.v == from:right() then
		turtle.turnRight()
	elseif to.v == from:opposite() then
		turtle.turnRight()
		turtle.turnRight()
	end
end

local tArgs = {...}

a = Direction:parse(tArgs[1])
b = Direction:parse(tArgs[2])

rotate(a, b)
