pico-8 cartridge // http://www.pico-8.com
version 17
__lua__

-- remove blocks
function blk_removal()

	-- remove blocks as necessary
	for x in all(del_blks) do
		well1[x["i"]][x["j"]] = 0
	end
end

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

function check_rows()

	local d_b = {}
	local init_block_added = false

	-- check the well vertically
	for i=1,6 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]
			
			-- check for a vertical row
			if(blk_clr ~= 0) then
				if(well1[i][j+1] == blk_clr and well1[i][j+2] == blk_clr) then
					add(d_b, {i=i,j=j})
					init_block_added = true
					add(d_b, {i=i,j=j+1})
					add(d_b, {i=i,j=j+2})
				end
			end
		end
	end

	-- check the well horizontally
	for i=1,4 do
		for j=1,15 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a horizontal row
			if(blk_clr ~= 0) then
				if(well1[i+1][j] == blk_clr and well1[i+2][j] == blk_clr) then
					if not(init_block_added) then
						add(d_b, {i=i,j=j})
						init_block_added = true
					end
					add(d_b, {i=i+1,j=j})
					add(d_b, {i=i+2,j=j})
				end
			end
		end
	end

	-- check the well for upper left to lower right diagonal
	for i=1,4 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a diagonal row
			if(blk_clr ~= 0) then
				if(well1[i+1][j+1] == blk_clr and well1[i+2][j+2] == blk_clr) then
					if not(init_block_added) then
						add(d_b, {i=i,j=j})
						init_block_added = true
					end
					add(d_b, {i=i+1,j=j+1})
					add(d_b, {i=i+2,j=j+2})
				end
			end
		end
	end

	-- check the well for lower left to upper right diagonal
	for i=1,4 do
		for j=3,15 do

			-- the current block we are looking at
			local blk_clr = well1[i][j]

			-- check for a diagonal row
			if(blk_clr ~= 0) then
				if(well1[i+1][j-1] == blk_clr and well1[i+2][j-2] == blk_clr) then
					if not(init_block_added) then
						add(d_b, {i=i,j=j})
						init_block_added = true
					end
					add(d_b, {i=i+1,j=j-1})
					add(d_b, {i=i+2,j=j-2})
				end
			end
		end
	end

	return d_b
end

function clear_rows()

	-- pass blocks to be deleted to function to animate their removal
	animate_blk_removal()

	-- drop blocks that are floating
	drop_blocks()

	if not (rows_cleared) then
		-- create new column
		column.sprites[1] = flr(rnd(4)) + 1
		column.sprites[2] = flr(rnd(4)) + 1
		column.sprites[3] = flr(rnd(4)) + 1

		column.y = 8

		timer = 0
	end
end

function _init()
	globals = {}
	globals.p1 = {}
	globals.p2 = {}

	timer = 0

	rows_cleared = false
	clear_process = false
	del_blks = {}

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
	timer = timer % 32000 + 1
	--printh(timer)

	if not (clear_process) then
		if(timer == 30 or btnp(3)) then
			if(column.y < 32+72 and well1[column.x/8][column.y/8+3] == 0) then
				column.y += 8
				timer = 0
			else

				-- update the well
				well1[column.x/8][column.y/8] = column.sprites[1]
				well1[column.x/8][column.y/8+1] = column.sprites[2]
				well1[column.x/8][column.y/8+2] = column.sprites[3]

				del_blks = check_rows()

				if(#del_blks ~= 0) then
					clear_process = true
					timer = 30
				else
					-- create new column
					column.sprites[1] = flr(rnd(4)) + 1
					column.sprites[2] = flr(rnd(4)) + 1
					column.sprites[3] = flr(rnd(4)) + 1

					clear_process = false
					column.y = 8
					timer = 0
				end
			end
		end

	-- if we are running the block clearing process
	else

		if(timer == 30) then
			for x in all(del_blks) do
				well1[x["i"]][x["j"]] = 5
			end
		end

		if(timer == 35) then
			for x in all(del_blks) do
				well1[x["i"]][x["j"]] = 6
			end
		end

		if(timer == 40) then
			for x in all(del_blks) do
				well1[x["i"]][x["j"]] = 7
			end
		end

		if(timer == 45) then
			for x in all(del_blks) do
				well1[x["i"]][x["j"]] = 8
			end
		end

		if(timer == 50) then
			blk_removal()
			drop_blocks()

			-- check if new blocks can be removed
			del_blks = check_rows()
			if(#del_blks ~= 0) then
				clear_process = true
				timer = 30

			-- otherwise, continue as normal
			else

				-- create new column
				column.sprites[1] = flr(rnd(4)) + 1
				column.sprites[2] = flr(rnd(4)) + 1
				column.sprites[3] = flr(rnd(4)) + 1

				clear_process = false
				column.y = 8
				timer = 0
			end
		end
	end


	--[[if(timer == 60) then
		-- create new column
		column.sprites[1] = flr(rnd(4)) + 1
		column.sprites[2] = flr(rnd(4)) + 1
		column.sprites[3] = flr(rnd(4)) + 1

		column.y = 8

		clear_process = false
		timer = 0
	end]]

	-- move column left or right
	if(timer <= 30) then
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

	if not(clear_process) then
		spr(column.sprites[1], column.x, column.y)
		spr(column.sprites[2], column.x, column.y+8)
		spr(column.sprites[3], column.x, column.y+16)
	end

end
__gfx__
777777777788887777aaaa7777bbbb777711117777000077770000777700107777800b7700000000000000000000000000000000000000000000000000000000
70000007788888877aaaaaa77bbbbbb771111117700000077000000770a00007780000b700000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb11111111000000000000100000000b008000000b00000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb11011011000a10000a000000800000000000000000000000000000000000000000000000000000000000000000000000
7000000788088088aa0aa0aabb0bb0bb11011011000b8000000000800000000a0000000000000000000000000000000000000000000000000000000000000000
7000000788888888aaaaaaaabbbbbbbb111111110000000000070000000008001000000a00000000000000000000000000000000000000000000000000000000
70000007788888877aaaaaa77bbbbbb77111111770000007700000077b000007710000a700000000000000000000000000000000000000000000000000000000
777777777788887777aaaa7777bbbb777711117777000077770000777701007777100a7700000000000000000000000000000000000000000000000000000000
