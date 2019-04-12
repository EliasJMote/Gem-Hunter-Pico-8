pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	timer = 0

	-- Create the column for player 1
	column = {}
	column.x = 32
	column.y = 8
	column.sprites = {}

	add(column.sprites, flr(rnd(4)) + 1)
	add(column.sprites, flr(rnd(4)) + 1)
	add(column.sprites, flr(rnd(4)) + 1)

	-- 6 x 15
	well1 = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
			}

	well2 = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
			}
end

function _update()
	timer = timer % 30 + 1
	if(timer == 30) then
		if(column.y < 32+72 and well1[column.x/8][column.y/8+3] == 0) then
			column.y += 8
		else
			well1[column.x/8][column.y/8] = column.sprites[1]
			well1[column.x/8][column.y/8+1] = column.sprites[2]
			well1[column.x/8][column.y/8+2] = column.sprites[3]

			column.sprites[1] = flr(rnd(4)) + 1
			column.sprites[2] = flr(rnd(4)) + 1
			column.sprites[3] = flr(rnd(4)) + 1

			column.y = 8
		end
	end

	-- Move column left or right
	if(btnp(0) and column.x > 8) then
		column.x -= 8
	elseif(btnp(1) and column.x < 8+40) then
		column.x += 8
	end

	if(btnp(3) and column.y < 32 + 72 and well1[column.x/8][column.y/8+3] == 0) then
		column.y += 8
	end

	-- Rotate column
	if btnp(4) then
		column.sprites[4] = column.sprites[3]
		column.sprites[3] = column.sprites[2]
		column.sprites[2] = column.sprites[1]
		column.sprites[1] = column.sprites[4]
	end
end

function _draw()
	cls()
	--rectfill(8,8,8+48,32+96,6)
	--rectfill(80,8,80+48,32+96,6)

	-- Draw blocks in the well
	for i=1,6 do
		for j=1,15 do
			spr(well1[i][j], 8+8*(i-1), 8+8*(j-1))
			spr(well2[i][j], 8+72+8*(i-1), 8+8*(j-1))
		end
	end

	spr(column.sprites[1], column.x, column.y)
	spr(column.sprites[2], column.x, column.y+8)
	spr(column.sprites[3], column.x, column.y+16)
end
__gfx__
777777770088880000aaaa0000bbbb00001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007088888800aaaaaa00bbbbbb0011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007088888800aaaaaa00bbbbbb0011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777770088880000aaaa0000bbbb00001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
