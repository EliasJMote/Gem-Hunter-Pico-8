pico-8 cartridge // http://www.pico-8.com
version 17
__lua__

-- remove blocks
function blk_removal(p)

	-- remove blocks as necessary
	for x in all(p.del_blks) do
		p.well[x["i"]][x["j"]] = 0
	end

	return p
end

-- drop floating blocks
function drop_blocks(p)

	for i=6,1,-1 do
		for j=14,1,-1 do

			-- the current block we are looking at
			local blk_clr = p.well[i][j]

			-- drop all blocks that are floating
			if(blk_clr ~= 0) then
				local d = 1
				while(p.well[i][j+d] == 0) do
					p.well[i][j+d-1] = 0
					p.well[i][j+d] = blk_clr
					d += 1
				end
			end
		end
	end

	return p
end

-- check rows for matching pieces
function check_rows(p)

	local d_b = {}
	local init_block_added = false

	-- check the well vertically
	for i=1,6 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = p.well[i][j]
			
			-- check for a vertical row
			if(blk_clr ~= 0 and blk_clr ~= 17) then
				if(p.well[i][j+1] == blk_clr and p.well[i][j+2] == blk_clr) then
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
			local blk_clr = p.well[i][j]

			-- check for a horizontal row
			if(blk_clr ~= 0 and blk_clr ~= 17) then
				if(p.well[i+1][j] == blk_clr and p.well[i+2][j] == blk_clr) then
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
			local blk_clr = p.well[i][j]

			-- check for a diagonal row
			if(blk_clr ~= 0 and blk_clr ~= 17) then
				if(p.well[i+1][j+1] == blk_clr and p.well[i+2][j+2] == blk_clr) then
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
			local blk_clr = p.well[i][j]

			-- check for a diagonal row
			if(blk_clr ~= 0 and blk_clr ~= 17) then
				if(p.well[i+1][j-1] == blk_clr and p.well[i+2][j-2] == blk_clr) then
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

function clear_rows(p)

	-- pass blocks to be deleted to function to animate their removal
	animate_blk_removal()

	-- drop blocks that are floating
	p = drop_blocks(p)

	if not (rows_cleared) then
		-- create new column
		column.sprites[1] = flr(rnd(4)) + 1
		column.sprites[2] = flr(rnd(4)) + 1
		column.sprites[3] = flr(rnd(4)) + 1

		column.y = 8

		timer = 0
	end
end

function add_crush_levels(p,crush_levels)
	-- first, copy blocks up by the number of crush levels
	for i=1,6 do
		for j=1+crush_levels,14 do
			p.well[i][j] = p.well[i][j+crush_levels]
		end
	end

	-- next, setup gray crush bars for each crush level
	for i=1,6 do
		for j=15-p.crush_bar_level, 15-p.crush_bar_level-crush_levels+1, -1 do
			p.well[i][j] = 17
		end
	end

	-- update the number of crush bar levels for the player
	p.crush_bar_level += crush_levels

	-- create a new column for the player
	p = create_new_column(p)

	return p
end

-- initialize the player
function init_player(p, x, player)

	-- setup player values
	p.player = player or 0
	p.timer = 0
	p.clear_process = false
	p.crush_process = false
	p.del_blks = {}
	p.crush_bar_level = 0

	-- create the column
	p.column = {}
	p.column.x = x or 32 
	p.column.y = 8
	p.column.sprites = {}
	add(p.column.sprites, flr(rnd(4)) + 1)
	add(p.column.sprites, flr(rnd(4)) + 1)
	add(p.column.sprites, flr(rnd(4)) + 1)

	-- create the next column that will be used
	-- (display this to the player)
	p.column_next = {}
	add(p.column_next, flr(rnd(4)) + 1)
	add(p.column_next, flr(rnd(4)) + 1)
	add(p.column_next, flr(rnd(4)) + 1)

	-- current score
	p.score = 0

	-- 6 x 15
	p.well = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
			}

	return p
end

-- create a new column and init values
function create_new_column(p)
	p.column.sprites[1] = p.column_next[1]
	p.column.sprites[2] = p.column_next[2]
	p.column.sprites[3] = p.column_next[3]

	p.column_next[1] = flr(rnd(4)) + 1
	p.column_next[2] = flr(rnd(4)) + 1
	p.column_next[3] = flr(rnd(4)) + 1

	p.clear_process = false
	p.column.y = 8
	p.timer = 0

	return p
end

-- update the player
function update_player(p, x)
	p.timer += 1
	--printh(timer)

	-- normal gameplay
	if not (p.clear_process) then
		if(p.timer == 30 or btnp(3, p.player)) then
			if(p.column.y < 32+72 and p.well[(p.column.x-x)/8+1][p.column.y/8+3] == 0) then
				p.column.y += 8
				p.timer = 0
			else

				-- update the well
				p.well[(p.column.x-x)/8+1][p.column.y/8] = p.column.sprites[1]
				p.well[(p.column.x-x)/8+1][p.column.y/8+1] = p.column.sprites[2]
				p.well[(p.column.x-x)/8+1][p.column.y/8+2] = p.column.sprites[3]

				p.del_blks = check_rows(p)

				if(#p.del_blks ~= 0) then
					p.clear_process = true
					p.timer = 30
				else
					-- create a new column
					p = create_new_column(p)
				end
			end
		end

	-- if we are running the block clearing process
	else

		if(p.timer == 30) then
			for x in all(p.del_blks) do
				p.well[x["i"]][x["j"]] = 5
			end
		end

		if(p.timer == 35) then
			for x in all(p.del_blks) do
				p.well[x["i"]][x["j"]] = 6
			end
		end

		if(p.timer == 40) then
			for x in all(p.del_blks) do
				p.well[x["i"]][x["j"]] = 7
			end
		end

		if(p.timer == 45) then
			for x in all(p.del_blks) do
				p.well[x["i"]][x["j"]] = 8
			end
		end

		if(p.timer == 50) then
			p = blk_removal(p)
			p = drop_blocks(p)
			for i in all(p.del_blks) do
				if(p.score < 30) then
					p.score += 1
				else
					p.score = 30
				end
			end

			-- check if new blocks can be removed
			p.del_blks = check_rows(p)
			if(#p.del_blks ~= 0) then
				p.clear_process = true
				p.timer = 30

			-- otherwise, continue as normal
			else

				-- create a new column
				p = create_new_column(p)
			end
		end
	end

	-- move column left or right
	if(p.timer <= 30) then

		if(btnp(0, p.player) and (p.column.x-x)/8+1 > 1
			and p.well[(p.column.x-x)/8][p.column.y/8] == 0
			and p.well[(p.column.x-x)/8][p.column.y/8+1] == 0
			and p.well[(p.column.x-x)/8][p.column.y/8+2] == 0) then
			p.column.x -= 8
		elseif(btnp(1, p.player) and (p.column.x-x)/8+1 < 6
			and p.well[(p.column.x-x)/8+2][p.column.y/8] == 0
			and p.well[(p.column.x-x)/8+2][p.column.y/8+1] == 0
			and p.well[(p.column.x-x)/8+2][p.column.y/8+2] == 0) then
			p.column.x += 8
		end

		-- rotate column
		if btnp(4, p.player) then
			p.column.sprites[4] = p.column.sprites[3]
			p.column.sprites[3] = p.column.sprites[2]
			p.column.sprites[2] = p.column.sprites[1]
			p.column.sprites[1] = p.column.sprites[4]
		end
	end

	-- activate crush
	if(btnp(5, p.player) and p.score >= 10) then
		--p.crush_process = true


		-- first, calculate the number of crush levels
		local crush_levels = flr(p.score / 10)

		-- subtract 10 x number of crush levels from the players score
		p.score -= 10 * crush_levels

		-- add crush levels to the other player
		if(p.player == 0) then
			globals.p2 = add_crush_levels(globals.p2, crush_levels)
		else
			globals.p1 = add_crush_levels(globals.p1, crush_levels)
		end

		--p.crush_process = false
	end

	return p
end

function _init()
	globals = {}
	globals.state = "Title"
end

function _update()
	--for k,v in pairs(globals) do

	if(globals.state == "Title") then
		if(btnp(4)) then 
			globals.state = "2 Player Game"
			globals.p1 = {}
			globals.p2 = {}

			globals.p1 = init_player(globals.p1, 32, 0)
			globals.p2 = init_player(globals.p2, 112, 1)
		end

	elseif(globals.state == "1 Player Game") then
		globals.p1 = update_player(globals.p1, 0)

	elseif(globals.state == "2 Player Game") then
		globals.p1 = update_player(globals.p1, 0)
		globals.p2 = update_player(globals.p2,112-32)
	end
end

function _draw()
	cls()


	if(globals.state == "Title") then
		local margin = 4
		print("gem hunter", 48, margin)
		print("press z to start", 36, 104)
		print("v0.4.5", 105-margin, 123-margin)

	elseif(globals.state == "1 Player Game") then


	elseif(globals.state == "2 Player Game") then

		-- draw blocks in the well
		for i=1,6 do
			for j=1,15 do
				spr(globals.p1.well[i][j], 8*(i-1), 8+8*(j-1))
				spr(globals.p2.well[i][j], 8+72+8*(i-1), 8+8*(j-1))
			end
		end

		if not(globals.p1.clear_process) then
			spr(globals.p1.column.sprites[1], globals.p1.column.x, globals.p1.column.y)
			spr(globals.p1.column.sprites[2], globals.p1.column.x, globals.p1.column.y+8)
			spr(globals.p1.column.sprites[3], globals.p1.column.x, globals.p1.column.y+16)
		end

		if not(globals.p2.clear_process) then
			spr(globals.p2.column.sprites[1], globals.p2.column.x, globals.p2.column.y)
			spr(globals.p2.column.sprites[2], globals.p2.column.x, globals.p2.column.y+8)
			spr(globals.p2.column.sprites[3], globals.p2.column.x, globals.p2.column.y+16)
		end

		-- draw the next columns for the players
		print("next", 56, 8)
		spr(globals.p1.column_next[1], 48, 16)
		spr(globals.p1.column_next[2], 48, 24)
		spr(globals.p1.column_next[3], 48, 32)

		spr(globals.p2.column_next[1], 72, 16)
		spr(globals.p2.column_next[2], 72, 24)
		spr(globals.p2.column_next[3], 72, 32)

		-- draw the current scores
		print("score", 56, 48)
		print(globals.p1.score, 48, 56)
		print(globals.p2.score, 72, 56)
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
00000000775555770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000755555570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000550550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000550550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000755555570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000775555770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
