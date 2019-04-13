pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function drop_blocks()
	-- drop blocks
	for i=6,1,-1 do
		for j=14,1,-1 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- drop all blocks that are floating
			if(blk_clr ~= 0) then
				local d = 1
				while(well1[i][j+d] == 0) do
					well1[i][j+d-1] = 0
					well1[i][j+d] = blk_clr
					d += 1
				end
			end
		end
	end
end

function clear_rows()
	-- delete blocks array
	local del_blks = {}

	-- check the well vertically
	for i=1,6 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a vertical row
			if(well1[i][j+1] == blk_clr and well1[i][j+2] == blk_clr) then
				add(del_blks, {i=i,j=j})
				add(del_blks, {i=i,j=j+1})
				add(del_blks, {i=i,j=j+2})
			end
		end
	end

	-- check the well horizontally
	for i=1,4 do
		for j=1,15 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a horizontal row
			if(well1[i+1][j] == blk_clr and well1[i+2][j] == blk_clr) then
				add(del_blks, {i=i,j=j})
				add(del_blks, {i=i+1,j=j})
				add(del_blks, {i=i+2,j=j})
			end
		end
	end

	-- check the well for upper left to lower right diagonal
	for i=1,4 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a diagonal row
			if(well1[i+1][j+1] == blk_clr and well1[i+2][j+2] == blk_clr) then
				add(del_blks, {i=i,j=j})
				add(del_blks, {i=i+1,j=j+1})
				add(del_blks, {i=i+2,j=j+2})
			end
		end
	end

	-- check the well for lower left to upper right diagonal
	for i=1,4 do
		for j=3,15 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a diagonal row
			if(well1[i+1][j-1] == blk_clr and well1[i+2][j-2] == blk_clr) then
				add(del_blks, {i=i,j=j})
				add(del_blks, {i=i+1,j=j-1})
				add(del_blks, {i=i+2,j=j-2})
			end
		end
	end

	for x=1,#del_blks do
		well1[del_blks[x]["i"]][del_blks[x]["j"]] = 0
	end

	drop_blocks()
end

function _init()
	timer = 0

	-- create the column for player 1
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
	if(timer == 30 or btnp(3)) then
		if(column.y < 32+72 and well1[column.x/8][column.y/8+3] == 0) then
			column.y += 8
		else

			-- update the well
			well1[column.x/8][column.y/8] = column.sprites[1]
			well1[column.x/8][column.y/8+1] = column.sprites[2]
			well1[column.x/8][column.y/8+2] = column.sprites[3]

			for i=1,3 do
				clear_rows()
			end

			-- create new column
			column.sprites[1] = flr(rnd(4)) + 1
			column.sprites[2] = flr(rnd(4)) + 1
			column.sprites[3] = flr(rnd(4)) + 1

			column.y = 8
		end
		timer = 0
	end

	-- move column left or right
	if(btnp(0) and column.x > 8
		and well1[column.x/8-1][column.y/8] == 0
		and well1[column.x/8-1][column.y/8+1] == 0
		and well1[column.x/8-1][column.y/8+2] == 0) then
		column.x -= 8
	elseif(btnp(1) and column.x < 8+40
		and well1[column.x/8+1][column.y/8] == 0
		and well1[column.x/8+1][column.y/8+1] == 0
		and well1[column.x/8+1][column.y/8+2] == 0) then
		column.x += 8
	end

	-- rotate column
	if btnp(4) then
		column.sprites[4] = column.sprites[3]
		column.sprites[3] = column.sprites[2]
		column.sprites[2] = column.sprites[1]
		column.sprites[1] = column.sprites[4]
	end
end

function _draw()
	cls()

	-- draw blocks in the well
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
777777777788887777aaaa7777bbbb77771111770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007788888877aaaaaa77bbbbbb7711111170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007788888877aaaaaa77bbbbbb7711111170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777777777788887777aaaa7777bbbb77771111770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
