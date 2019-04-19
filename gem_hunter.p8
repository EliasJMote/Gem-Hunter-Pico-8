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

function drop_blocks(p)
	-- drop blocks
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

function check_rows(p)

	local d_b = {}
	local init_block_added = false

	-- check the well vertically
	for i=1,6 do
		for j=1,13 do

			-- the current block we are looking at
			local blk_clr = p.well[i][j]
			
			-- check for a vertical row
			if(blk_clr ~= 0) then
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
			if(blk_clr ~= 0) then
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
			if(blk_clr ~= 0) then
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
			if(blk_clr ~= 0) then
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

function init_player(p, x, player)

	-- setup player values
	p.player = player or 0
	p.timer = 0
	p.clear_process = false
	p.del_blks = {}

	-- create the column
	p.column = {}
	p.column.x = x or 32 
	p.column.y = 8
	p.column.sprites = {}

	add(p.column.sprites, flr(rnd(4)) + 1)
	add(p.column.sprites, flr(rnd(4)) + 1)
	add(p.column.sprites, flr(rnd(4)) + 1)

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
					-- create new column
					p.column.sprites[1] = flr(rnd(4)) + 1
					p.column.sprites[2] = flr(rnd(4)) + 1
					p.column.sprites[3] = flr(rnd(4)) + 1

					p.clear_process = false
					p.column.y = 8
					p.timer = 0
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

			-- check if new blocks can be removed
			p.del_blks = check_rows(p)
			if(#p.del_blks ~= 0) then
				p.clear_process = true
				p.timer = 30

			-- otherwise, continue as normal
			else

				-- create new column
				p.column.sprites[1] = flr(rnd(4)) + 1
				p.column.sprites[2] = flr(rnd(4)) + 1
				p.column.sprites[3] = flr(rnd(4)) + 1

				p.clear_process = false
				p.column.y = 8
				p.timer = 0
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
		print("v0.4.3", 105-margin, 123-margin)

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
