pico-8 cartridge // http://www.pico-8.com
version 17
__lua__

--[[function check_del_blks(x,y,d_b)
	for b in all(d_b) do
		if(b[x]==x and b[y]==y) then return true end
	end
	return false
end]]

function create_rain_gemstone(x,y)
    local gem = {}
    gem.spr = flr(rnd(5)) + 1
    gem.x = x or flr(rnd(15)) * 8
    gem.y = y or 0
    gem.life_timer = 0
    return gem
end

function extend_gem_raindrop(raindrop)
    local head = raindrop[#raindrop]
    if(head ~= nil) then
        local gem = create_rain_gemstone(head.x,head.y + 8)
        add(raindrop,gem)
    end
    return raindrop
end

function create_gem_raindrop()

    local gem_raindrop = {}
    local gem = create_rain_gemstone()

    -- if a raindrop already exists for the selected x value, pick again
    local create_new_gem = true
    while(create_new_gem) do
        create_new_gem = false
        for raindrop in all(globals.gem_raindrops) do
            if(#raindrop >= 1) then
                if(gem.x == raindrop[1].x) then
                    gem = create_rain_gemstone()
                    create_new_gem = true
                end
            end
        end
    end

    add(gem_raindrop, gem)
    add(globals.gem_raindrops, gem_raindrop)
end

function update_gem_raindrop(raindrop)
    if(globals.timer % 3 == 0) then
        raindrop = extend_gem_raindrop(raindrop)
    end
    for gem in all(raindrop) do
        gem.life_timer += 1
        if(gem.life_timer >= 30 or gem.y >= 128) then
            del(raindrop,gem)
        end
    end

    if(#raindrop == 0) then raindrop = nil end
    return raindrop
end

-- remove blocks
function blk_removal(p)

	-- remove blocks as necessary
	for b in all(p.del_blks) do
		p.well[b["x"]][b["y"]] = 0
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

	-- a table of blocks to be deleted after all checking is complete
	local d_b = {}

	-- check the well vertically
	
	for x=1,6 do
		for y=1,13 do

			-- the current block we are looking at
			local blk_clr = p.well[x][y]
			
			-- check for a vertical row
			if(blk_clr ~= 0 and blk_clr ~= 7) then

				-- if the two blocks above are the same
				if(p.well[x][y+1] == blk_clr and p.well[x][y+2] == blk_clr) then

					-- add 3 blocks in a column
					add(d_b, {x=x,y=y})
					add(d_b, {x=x,y=y+1})
					add(d_b, {x=x,y=y+2})

					-- keep checking blocks above until a different block is found
					for y_2=y+3,15 do
						if(p.well[x][y_2] == blk_clr) then
							add(d_b, {x=x,y=y_2})
						else
							break
						end
					end
				end

				
			end
		end
	end

	-- check the well horizontally
	
	for y=1,15 do
		for x=1,4 do

			-- the current block we are looking at
			local blk_clr = p.well[x][y]

			-- check for a horizontal row
			if(blk_clr ~= 0 and blk_clr ~= 7) then

				-- if 2 blocks to the right are the same, mark the row for deletion
				if(p.well[x+1][y] == blk_clr and p.well[x+2][y] == blk_clr) then
					
					add(d_b, {x=x,y=y})
					add(d_b, {x=x+1,y=y})
					add(d_b, {x=x+2,y=y})

					-- keep checking blocks to the right until they are different
					for x_2=x+3,6 do
						if(p.well[x_2][y] == blk_clr) then
							add(d_b, {x=x_2,y=y})
						else
							break
						end
					end
					x=5
				end
			end
		end
	end

	-- check the well for upper left to lower right diagonal
	
	for y=1,13 do
		for x=1,4 do

			-- the current block we are looking at
			local blk_clr = p.well[x][y]

			-- check for a diagonal row
			if(blk_clr ~= 0 and blk_clr ~= 7) then
				if(p.well[x+1][y+1] == blk_clr and p.well[x+2][y+2] == blk_clr) then

					-- if 2 blocks to the lower right are the same, mark the row for deletion
					add(d_b, {x=x,y=y})
					add(d_b, {x=x+1,y=y+1})
					add(d_b, {x=x+2,y=y+2})

					-- keep checking blocks to the lower right until they are different
					if(x+3<=6) then
						if(p.well[x+3][y+3] == blk_clr) then
							add(d_b, {x=x+3,y=y+3})
						else
							break
						end
					end

					if(x+4<=6) then
						if(p.well[x+4][y+4] == blk_clr) then
							add(d_b, {x=x+4,y=y+4})
						else
							break
						end
					end

					if(x+5<=6) then
						if(p.well[x+5][y+5] == blk_clr) then
							add(d_b, {x=x+5,y=y+5})
						else
							break
						end
					end

				end
			end
		end
	end

	-- check the well for lower left to upper right diagonal
	for x=1,4 do
		for y=3,15 do

			-- the current block we are looking at
			local blk_clr = p.well[x][y]

			-- check for a diagonal row
			if(blk_clr ~= 0 and blk_clr ~= 7) then

				-- if 2 blocks to the upper right are the same, mark the row for deletion
				if(p.well[x+1][y-1] == blk_clr and p.well[x+2][y-2] == blk_clr) then
					
					add(d_b, {x=x,y=y})
					add(d_b, {x=x+1,y=y-1})
					add(d_b, {x=x+2,y=y-2})

					-- keep checking blocks to the upper right until they are different
					if(x+3<=6) then
						if(p.well[x+3][y-3] == blk_clr) then
							add(d_b, {x=x+3,y=y-3})
						else
							break
						end
					end

					if(x+4<=6) then
						if(p.well[x+4][y-4] == blk_clr) then
							add(d_b, {x=x+4,y=y-4})
						else
							break
						end
					end

					if(x+5<=6) then
						if(p.well[x+5][y-5] == blk_clr) then
							add(d_b, {x=x+5,y=y-5})
						else
							break
						end
					end
				end
			end
		end
	end

    -- remove duplicates
    local no_dup = {}
    for i in all(d_b) do
        local is_dup = false
        for j in all(no_dup) do
            if (i.x == j.x and i.y == j.y) then
                is_dup = true
            end
        end
        if not is_dup then add(no_dup,i) end
    end

    d_b = no_dup

	return d_b
end

-- clear each row out
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

-- add crush levels to a player
function add_crush_levels(p,crush_levels,x)
    -- update the number of crush bar levels for the player
    p.crush_bar_level += crush_levels

	-- first, copy blocks up by the number of crush levels
	for i=1,6 do
		for j=crush_levels,globals.well_hgt do
			p.well[i][j] = p.well[i][j+crush_levels]
		end
	end

	-- next, setup gray crush bars for each crush level
	for i=1,6 do
		for j=globals.well_hgt-crush_levels+1, globals.well_hgt do
			p.well[i][j] = 7
		end
	end

	-- create a new column for the player
	p = create_new_column(p,x)

	return p
end

-- function remove_crush_levels
function remove_crush_levels(p,crush_levels)

    -- compare the number of crush levels by the current crush bar level
    -- if the number of crush levels is greater than the current crush bar level,
    -- set the number to crush levels to the current crush bar level
    if(crush_levels > p.crush_bar_level) then
        crush_levels = p.crush_bar_level
    end

    -- copy blocks down by the number of crush levels
    for i=1,6 do
        for j=globals.well_hgt,crush_levels,-1 do
            if(p.well[i][j] ~= 0) then
                p.well[i][j] = p.well[i][j-crush_levels]
            end
        end
    end

	-- update the number of crush bar levels for the player
	p.crush_bar_level -= crush_levels
    if(p.crush_bar_level < 0) then p.crush_bar_level = 0 end

	return p
end

-- check if a block coming down has overlap with the lowest block
function check_overlap(p, x)

	--printh((p.column.x-x)/8+1)

	if(p.well[(p.column.x-x)/8+1][p.column.y/8] ~= 0) then
		
		-- if player 1 has lost, player 2 has won
		if(p.player == 0) then
			globals.game_state = "p2 victory"
		else
			globals.game_state = "p1 victory"
		end
	end
end

-- initialize the player
function init_player(p, x, player, character)

	-- setup player values
	p.player = player or 0
	p.timer = 0
	p.clear_process = false
	p.crush_process = false
	p.del_blks = {}
	p.crush_bar_level = 0
    p.remove_1_block_type = false

	-- create the column
	p.column = {}
	p.column.x = x or 32 
	p.column.y = 8
	p.column.sprites = {}
    p.column_pool_pos = 1
    for i=1,3 do
        add(p.column.sprites, globals.column_pool[p.column_pool_pos][i])
    end
    p.column_pool_pos += 1
    
	-- create the next column that will be used
	-- (display this to the player)
	p.column_next = {}
	for i=1,3 do
		add(p.column_next, globals.column_pool[p.column_pool_pos][i])
	end
    p.column_pool_pos += 1

	-- current score
	p.score = 0
    p.total_score = 0
    p.arrow_score = 0

    --p.next_column_arrow = false
    --p.next_column_flashing = false

	-- 6 x 15
	p.well = {
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
				{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
			}

    p.character = character

	return p
end

-- create a new column and init values
function create_new_column(p,x)
	sfx(0)

	p.column.sprites[1] = p.column_next[1]
	p.column.sprites[2] = p.column_next[2]
	p.column.sprites[3] = p.column_next[3]

    -- if practice player

    if(globals.state == "practice") then
    	p.column_next[1] = flr(rnd(6)) + 1
    	p.column_next[2] = flr(rnd(6)) + 1
    	p.column_next[3] = flr(rnd(6)) + 1
    else

        if(p.arrow_score >= 30) then

            p.column_next[1] = 26
            p.column_next[2] = 27
            p.column_next[3] = 28
            
            p.arrow_score = 0
        else

            p.column_pool_pos += 1

            -- add additional columns if current player position exceeds pool size
            if(p.column_pool_pos > #globals.column_pool) then
                for i=1,1000 do
                    local column = {}
                    for j=1,3 do
                        add(column,flr(rnd(6)) + 1)
                    end
                    add(globals.column_pool,column)
                end
            end

            p.column_next[1] = globals.column_pool[p.column_pool_pos][1]
            p.column_next[2] = globals.column_pool[p.column_pool_pos][2]
            p.column_next[3] = globals.column_pool[p.column_pool_pos][3]
        end
    end

	p.clear_process = false
	p.column.y = 8
	p.timer = 0

	check_overlap(p, x)

	return p
end

-- update the player
function update_player(p, x)
	p.timer += 1

	-- normal gameplay
	if not (p.clear_process) then

        -- each second or when the player pushes down, 
		if(p.timer == 30 or btnp(3, p.player)) then

			if(p.column.y < 32+72 and p.well[(p.column.x-x)/8+1][p.column.y/8+3] == 0) then

                -- advance the column down one row and reset the timer
				p.column.y += 8
				p.timer = 0
			else

                -- up arrow on the arrow column
                if(p.column.sprites[3] == 26) then
                    -- add crush levels to the other player
                    if(p.player == 0) then
                        globals.p2 = add_crush_levels(globals.p2, 3, 112-32)
                    else
                        globals.p1 = add_crush_levels(globals.p1, 3, 0)
                    end

                -- middle block of the arrow column
                elseif(p.column.sprites[3] == 27) then
                    -- get the block below this block. this block and all blocks of this type
                    -- will be deleted
                    local del_blk_type = p.well[(p.column.x-x)/8+1][p.column.y/8+3]
                    p.del_blks = {}
                    -- check all blocks in the well. delete those blocks
                    for x=1,globals.well_len do
                        for y=1,globals.well_hgt do
                            if(p.well[x][y] == del_blk_type) then
                                add(p.del_blks,{x=x,y=y})
                            end
                        end
                    end

                    p.clear_process = true
                    p.timer = 30
                    sfx(1)
                    p.remove_1_block_type = true

                -- down arrow on the arrow column
                elseif(p.column.sprites[3] == 28) then
                    -- remove any existing crush levels from the current player
                    if(p.player == 0) then
                        globals.p1 = remove_crush_levels(globals.p1, 3)
                    else
                        globals.p2 = remove_crush_levels(globals.p2, 3)
                    end

                else

    				-- update the well
    				p.well[(p.column.x-x)/8+1][p.column.y/8] = p.column.sprites[1]
    				p.well[(p.column.x-x)/8+1][p.column.y/8+1] = p.column.sprites[2]
    				p.well[(p.column.x-x)/8+1][p.column.y/8+2] = p.column.sprites[3]
                end

                if(p.column.sprites[3] ~= 27) then

                    -- check the rows to mark blocks to be deleted
    				p.del_blks = check_rows(p)

                    -- if we are deleting non-empty blocks
    				if(#p.del_blks ~= 0) then
    					p.clear_process = true
    					p.timer = 30
    					sfx(1)
                        --printh(#p.del_blks)
    				else
    					-- create a new column
    					p = create_new_column(p,x)
    				end
                end
			end
		end

        -- if the player presses the "up" key, instantly drop the piece
        if(btnp(2, p.player)) then
            -- starting with one space below the bottom of the column block, check below until
            -- a solid block (or the bottom of the well) is found
            local occupied_space_y_pos = p.column.y
            while(p.well[(p.column.x-x)/8+1][occupied_space_y_pos/8+3] == 0 
                and occupied_space_y_pos < 32 + 72) do
                    occupied_space_y_pos += 8
            end
            p.column.y = occupied_space_y_pos
            p.timer = 29
        end

	-- if we are running the block clearing process
	else

		if(p.timer == 30) then
			for x in all(p.del_blks) do
				p.well[x["x"]][x["y"]] = 12
			end

		elseif(p.timer == 35) then
			for x in all(p.del_blks) do
				p.well[x["x"]][x["y"]] = 13
			end

		elseif(p.timer == 40) then
			for x in all(p.del_blks) do
				p.well[x["x"]][x["y"]] = 14
			end

		elseif(p.timer == 45) then
			for x in all(p.del_blks) do
				p.well[x["x"]][x["y"]] = 15
			end

		elseif(p.timer == 50) then
			p = blk_removal(p)
			p = drop_blocks(p)
            if not(p.remove_1_block_type) then
    			for i in all(p.del_blks) do
                    p.total_score += 1
                    p.arrow_score += 1
    				if(p.score < 30) then
    					p.score += 1
    				else
    					p.score = 30
    				end
    			end
            end

			-- check if new blocks can be removed
			p.del_blks = check_rows(p)
			if(#p.del_blks ~= 0) then
				p.clear_process = true
				p.timer = 30
				sfx(1)

			-- otherwise, continue as normal
			else
                if(p.remove_1_block_type) then p.remove_1_block_type = false end
				-- create a new column
				p = create_new_column(p,x)
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
	if(globals.state ~= "practice") then
		if(btnp(5, p.player) and p.score >= 10) then
        
			-- first, calculate the number of crush levels
			local crush_levels = flr(p.score / 10)

			-- subtract 10 x number of crush levels from the players score
			p.score -= 10 * crush_levels

			-- add crush levels to the other player
			if(p.player == 0) then
				globals.p2 = add_crush_levels(globals.p2, crush_levels, 112-32)
			else
				globals.p1 = add_crush_levels(globals.p1, crush_levels, 0)
			end

            -- remove any existing crush levels from the current player
            if(p.player == 0) then
                globals.p1 = remove_crush_levels(globals.p1, crush_levels)
            else
                globals.p2 = remove_crush_levels(globals.p2, crush_levels)
            end
		end
	end

	return p
end

-- init game
function init_game(character,character2)

    globals.column_pool = {}
    for i=1,10000 do
        local column = {}
        for j=1,3 do
            add(column,flr(rnd(6)) + 1)
        end
        add(globals.column_pool,column)
    end

	if(globals.state == "1 player game") then
		globals.p1 = init_player(globals.p1, 32, 0, character)

    elseif(globals.state ==  "2 player game") then
        globals.p1 = init_player(globals.p1, 32, 0, character)
        globals.p2 = init_player(globals.p2, 112, 1, character2)

	elseif(globals.state == "practice") then
		globals.p1 = init_player(globals.p1, 32, 0, character)
	end

	globals.game_state = "gameplay"
end

function _init()
	globals = {}

	-- setup initial state
	globals.state = "roc_studios_logo"

	-- setup initial gameplay state
	globals.game_state = "gameplay"

	globals.timer = 0

	-- setup some constants
	globals.well_len = 6
	globals.well_hgt = 15

    globals.gem_raindrops = {}
    globals.characters = {"atom girl", "james", "brenna", "rudari", "shi'era"}
    globals.character_sprites = {192,131,137,134,128}
    globals.p1 = {player_select_state=1}
    globals.p2 = {player_select_state=1}

    --globals.state_table = {"roc_studios_logo", "opening_cinematic", "title", "select mode", "1 player game",
    --"2 player game", "practice", "options", "player select"}
end

function _update()
	--for k,v in pairs(globals) do

    -- opening logo
    if(globals.state == "roc_studios_logo") then
        if(globals.timer >= 90) then
            globals.state = "opening_cinematic"
            globals.timer = 0

        -- skip the logo
        elseif(globals.timer < 60 and btnp(4)) then
            globals.timer = 60
        end

    elseif(globals.state == "opening_cinematic") then
        color(7)
        if(globals.timer % 15 == 0) then
            create_gem_raindrop()
        end

        for gem_raindrop in all(globals.gem_raindrops) do
            gem_raindrop = update_gem_raindrop(gem_raindrop)
        end

        -- go to the title screen after long enough or hitting the skip cutscene button
        if(globals.timer >= 270 or btnp(4)) then
            globals.state = "title"
            globals.timer = 0
        end

	elseif(globals.state == "title") then

        -- go from the title screen to the "select mode" screen
		if(btnp(4)) then
			globals.state = "select mode"
			globals.title_state = "1 player"
		end

	-- game type selection
	elseif(globals.state == "select mode") then

        -- if the player selects an option
		if(btnp(4)) then
            if(globals.title_state == "1 player") then
                --globals.game_state = "1 player game"
                --globals.player_select_state = 1
                --globals.state = "1 player game"

			elseif(globals.title_state == "2 player") then
				--globals.state = "2 player game"
                globals.player_select_state = 1
                globals.game_state = "2 player game"
                globals.state = "player select"

			elseif(globals.title_state == "practice") then
				--globals.state = "practice"
                globals.player_select_state = 1
                globals.game_state = "practice"
                globals.state = "player select"

            elseif(globals.title_state == "options") then
                --globals.state = "options"
			end
		end

		-- if the player pushes up
		if(btnp(2)) then
			if(globals.title_state == "1 player") then
				globals.title_state = "options"
			elseif(globals.title_state == "2 player") then
				globals.title_state = "1 player"
			elseif(globals.title_state == "practice") then
				globals.title_state = "2 player"
			elseif(globals.title_state == "options") then
				globals.title_state = "practice"
			end

		-- if the player pushes down
		elseif(btnp(3)) then
			if(globals.title_state == "1 player") then
				globals.title_state = "2 player"
			elseif(globals.title_state == "2 player") then
				globals.title_state = "practice"
			elseif(globals.title_state == "practice") then
				globals.title_state = "options"
			elseif(globals.title_state == "options") then
				globals.title_state = "1 player"
			end
		end


	elseif(globals.state == "1 player game") then
		globals.p1 = update_player(globals.p1, 0)

	elseif(globals.state == "2 player game") then
		if(globals.game_state == "gameplay") then
			globals.p1 = update_player(globals.p1, 0)
			globals.p2 = update_player(globals.p2,112-32)
		else
			if(btnp(4) or btnp(5)) then
				init_game(globals.p1.player_select_state, globals.p2.player_select_state)
			end
		end
	elseif(globals.state == "practice") then

		if(globals.game_state == "gameplay") then
			globals.p1 = update_player(globals.p1, 0)
		else
            -- restart the gameplay
			if(btnp(4) or btnp(5)) then
				init_game(globals.p1.player_select_state)
			end
		end

    elseif(globals.state == "options") then

        
    elseif(globals.state == "player select") then
        if(btnp(0)) then
            globals.p1.player_select_state = (((globals.p1.player_select_state - 1) - 1) % 5) + 1
        elseif(btnp(1)) then
            globals.p1.player_select_state = (((globals.p1.player_select_state + 1) - 1) % 5) + 1
        end

        if(globals.game_state == "2 player game") then

            if(btnp(0,1)) then
                globals.p2.player_select_state = (((globals.p2.player_select_state - 1) - 1) % 5) + 1
            elseif(btnp(1,1)) then
                globals.p2.player_select_state = (((globals.p2.player_select_state + 1) - 1) % 5) + 1
            end
        end

        -- when the character(s) is/are selected, start the game
        if(btnp(4)) then
            globals.state = globals.game_state
            init_game(globals.p1.player_select_state, globals.p2.player_select_state)
        end
	end

    globals.timer += 1
end

function _draw()
	cls()

    if(globals.state == "roc_studios_logo") then
        sspr(32, 32*1, 32, 32, 32, 16, 64, 64)
        sspr(64, 32*1, 32, 32, 32, 16+64, 64, 64)
        if(globals.timer >= 60) then
            rectfill(0, 0, 128, (globals.timer-60)*5, 0)
        end

    elseif(globals.state == "opening_cinematic") then

        for gem_raindrop in all(globals.gem_raindrops) do

            for gem in all(gem_raindrop) do
                if(gem == gem_raindrop[#gem_raindrop]) then
                    spr(gem.spr,gem.x,gem.y)
                else
                    spr(gem.spr+32,gem.x,gem.y)
                end
            end
        end

	elseif(globals.state == "title") then
		local margin = 4
		print("gem hunter", 48, margin)

		-- draw gems on the title screen
		for i=1,2 do
			for j=1,4 do
				spr(64+(i-1)+16*(j-1), 32+8*i, 40+8*j)
				spr(66+(i-1)+16*(j-1), 72+8*i, 40+8*j)
			end
		end

		print("press z to start", 36, 104)
		print("v0.7.1", 101-margin, 123-margin)

	elseif(globals.state == "select mode") then
		local margin = 4

		print("select game mode", 38, margin)
		if(globals.title_state == "1 player") then
			color(8)
		end
		print("1 player (unfinished)", 36, 48)
		color(7)

		if(globals.title_state == "2 player") then
			color(8)
		end
		print("2 player", 36, 64)
		color(7)

		if(globals.title_state == "practice") then
			color(8)
		end
		print("practice", 36, 80)
		color(7)

		if(globals.title_state == "options") then
			color(8)
		end
		print("options (unfinished)", 36, 96)
		color(7)

	elseif(globals.state == "1 player game") then
            -- draw blocks in the well
            rect(0,7,47,127,7)
            rect(8+72,7,8+72+47,127,7)

            for i=1,globals.well_len do
                for j=1,globals.well_hgt do
                    if(globals.p1.well[i][j] ~= 0) spr(globals.p1.well[i][j], 8*(i-1), 8+8*(j-1))
                    if(globals.p2.well[i][j] ~= 0) spr(globals.p2.well[i][j], 8+72+8*(i-1), 8+8*(j-1))
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
            for i=1,3 do
                spr(globals.p1.column_next[i], 48, 16+8*(i-1))
                spr(globals.p2.column_next[i], 72, 16+8*(i-1))
            end

            -- draw the current scores
            print("score", 56, 48)
            print(globals.p1.score, 48, 56)
            print(globals.p2.score, 72, 56)

            --print("total", 56, 72)
            --print(globals.p1.total_score%100, 48, 80)
            --print(globals.p2.total_score%100, 72, 80)

            -- display victory
            if(globals.game_state == "p1 victory") then
                print("p1 wins", 50, 96)
            elseif(globals.game_state == "p2 victory") then
                print("p2 wins", 50, 96)
            end

	elseif(globals.state == "2 player game") then

		-- draw blocks in the well
        rect(0,7,47,127,7)
        rect(8+72,7,8+72+47,127,7)

		for i=1,globals.well_len do
			for j=1,globals.well_hgt do
                if(globals.p1.well[i][j] ~= 0) spr(globals.p1.well[i][j], 8*(i-1), 8+8*(j-1))
				if(globals.p2.well[i][j] ~= 0) spr(globals.p2.well[i][j], 8+72+8*(i-1), 8+8*(j-1))
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
		for i=1,3 do
			spr(globals.p1.column_next[i], 48, 16+8*(i-1))
			spr(globals.p2.column_next[i], 72, 16+8*(i-1))
		end

		-- draw the current scores
		print("score", 56, 48)
		print(globals.p1.score, 48, 56)
		print(globals.p2.score, 72, 56)

        --print("total", 56, 72)
        --print(globals.p1.total_score%100, 48, 80)
        --print(globals.p2.total_score%100, 72, 80)

		-- display victory
		if(globals.game_state == "p1 victory") then
            rectfill(10,64,10+26,68,0)
			print("p1 wins", 10, 64, 7)
		elseif(globals.game_state == "p2 victory") then
            rectfill(90,64,90+26,68,0)
			print("p2 wins", 90, 64, 7)
		end

        -- draw borders for the portraits
        rect(50,70,50+25,70+25,7)
        rect(50,70+31,50+26,70+26+31,7)

        -- draw player 1
        --if(globals.game_state == "p1 victory") then
        spr(globals.character_sprites[globals.p1.character], 51, 71, 3, 3)
        --elseif(globals.game_state == "gameplay") then
            --spr(192, 51, 71, 3, 3)
        --end

        -- draw player 2
        --palt(7,true)
        spr(globals.character_sprites[globals.p2.character], 51, 71+31, 3, 3)
        --palt(7,false)

	elseif(globals.state == "practice") then

        rect(0,7,47,127,7)

		-- draw blocks in the well
		for i=1,6 do
			for j=1,15 do
				if(globals.p1.well[i][j] ~= 0) spr(globals.p1.well[i][j], 8*(i-1), 8+8*(j-1))
			end
		end

		if not(globals.p1.clear_process) then
			for i=1,3 do
				spr(globals.p1.column.sprites[i], globals.p1.column.x, globals.p1.column.y+8*(i-1))
			end
			--spr(globals.p1.column.sprites[1], globals.p1.column.x, globals.p1.column.y)
			--spr(globals.p1.column.sprites[2], globals.p1.column.x, globals.p1.column.y+8)
			--spr(globals.p1.column.sprites[3], globals.p1.column.x, globals.p1.column.y+16)
		end

		-- draw the next columns for the players
		print("next", 56, 8)
		for i=1,3 do
			spr(globals.p1.column_next[i], 48, 16+8*(i-1))
		end

		for i=2,3 do
			spr(49, 80 + 16 * (i-1), 8)
			for j=1,14 do
				spr(50, 80 + 16 * (i-1), 8+8*j)
			end
			spr(51, 80 + 16 * (i-1), 120)
		end

		-- display game over state
		if(globals.game_state == "p2 victory") then
            rectfill(6,64,6+34,68,0)
            print("game over", 6, 64, 7)
		end

        -- draw borders for the portraits
        --rect(50,70,50+25,70+25,7)
        rect(50,70+31,50+26,70+26+31,7)

        -- draw player 1
        --spr(192, 51, 71, 3, 3)
        spr(globals.character_sprites[globals.p1.character], 51, 71+31, 3, 3)

    elseif(globals.state == "options") then

    elseif(globals.state == "player select") then
        print("select a character", 32, 4,7)

        -- player boxes
        rect(56,16,56+25,16+25,7)
        rect(16,56,16+25,56+25,7)
        rect(96,56,96+25,56+25,7)
        rect(32,96,32+25,96+25,7)
        rect(80,96,80+25,96+25,7)

        if(globals.timer % 30 <= 15) then

            -- player 1 select character
            if(globals.p1.player_select_state == 1) then
                rect(56,16,56+25,16+25,8)
            elseif(globals.p1.player_select_state == 2) then
                rect(96,56,96+25,56+25,8)
            elseif(globals.p1.player_select_state == 3) then
                rect(80,96,80+25,96+25,8)
            elseif(globals.p1.player_select_state == 4) then
                rect(32,96,32+25,96+25,8)
            elseif(globals.p1.player_select_state == 5) then
                rect(16,56,16+25,56+25,8)
            end

            -- player 2 select character
            if(globals.game_state == "2 player game") then
                if(globals.p2.player_select_state == 1) then
                    rect(56,16,56+25,16+25,12)
                elseif(globals.p2.player_select_state == 2) then
                    rect(96,56,96+25,56+25,12)
                elseif(globals.p2.player_select_state == 3) then
                    rect(80,96,80+25,96+25,12)
                elseif(globals.p2.player_select_state == 4) then
                    rect(32,96,32+25,96+25,12)
                elseif(globals.p2.player_select_state == 5) then
                    rect(16,56,16+25,56+25,12)
                end
            end
        end
        color(7)

        -- characters
        spr(192, 56+1, 16+1, 3, 3)
        spr(128, 16+1, 56+1, 3, 3)
        spr(131, 96+1, 56+1, 3, 3)
        spr(134, 32+1, 96+1, 3, 3)
        spr(137, 80+1, 96+1, 3, 3)

        if(globals.p1.player_select_state == 1) then
            print(globals.characters[globals.p1.player_select_state],52,66,8)
        elseif(globals.p1.player_select_state == 2) then
            print(globals.characters[globals.p1.player_select_state],58,66,8)
        elseif(globals.p1.player_select_state < 5) then
            print(globals.characters[globals.p1.player_select_state],57,66,8)
        elseif(globals.p1.player_select_state == 5) then
            print(globals.characters[globals.p1.player_select_state],55,66,8)
        end

        if(globals.game_state == "2 player game") then

            if(globals.p2.player_select_state == 1) then
                print(globals.characters[globals.p2.player_select_state],52,74,12)
            elseif(globals.p2.player_select_state == 2) then
                print(globals.characters[globals.p2.player_select_state],58,74,12)
            elseif(globals.p2.player_select_state < 5) then
                print(globals.characters[globals.p2.player_select_state],57,74,12)
            elseif(globals.p2.player_select_state == 5) then
                print(globals.characters[globals.p2.player_select_state],55,74,12)
            end
        end

	end
end
__gfx__
000000000088880000099000000a90000033330000cccc000eeeeee0005555000000000000000000000000000000000000000000000000000000100000800b00
000000000888ff800898898000aa7a000377b3300c77ccc0ee77eeee0555775000000000000000000000000000000000000000000000000000a00000080000b0
0000000088888f88998778990aa99aa03b7bb3b30771ccc0e77eeeee5555575500000000000000000000000000000000000000000000100000000b008000000b
0000000088888888998798999997a999303bb3b3071ccc10e7eeeee25555555500000000000000000000000000000000000a10000a0000008000000000000000
000000008e88888899899899aa9aa99a303bbb330ccccc10eeeeeee25655555500000000000000000000000000000000000b8000000000800000000a00000000
000000008ee88888998998990aa99990303bb30301ccc110eeeeee2256655555000000000000000000000000000000000000000000070000000008001000000a
0000000008ee88800898898000aa990003b300300ccc1110eeeee222056655500000000000000000000000000000000000000000000000000b000000010000a0
000000000088880000099000000990000033330000c111000ee22220005555000000000000000000000000000000000000000000000000000001000000100a00
00000000008888000099990000aaaa0000bbbb000011110000222200005555000000000000000000000880008877778888888888000000000000000000000000
0000000008888880099999900aaaaaa00bbbbbb00111111002222220055555500000000000000000008778008787787887877878000000000000000000000000
000000008888888899999999aaaaaaaabbbbbbbb1111111122222222555555550000000000000000008778007877778787788778000000000000000000000000
000000008808808899099099aa0aa0aabb0bb0bb1101101122022022550550550000000000000000087887807778877708877880000000000000000000000000
000000008808808899099099aa0aa0aabb0bb0bb1101101122022022550550550000000000000000088778807778877708788780000000000000000000000000
000000008888888899999999aaaaaaaabbbbbbbb1111111122222222555555550000000000000000877887787877778700877800000000000000000000000000
0000000008888880099999900aaaaaa00bbbbbb00111111002222220055555500000000000000000878778788787787800877800000000000000000000000000
00000000008888000099990000aaaa0000bbbb000011110000222200005555000000000000000000888888888877778800088000000000000000000000000000
00000000005555000006600000065000005555000066660006666660000000000000000000000000000000000000000000000000000000000000000000000000
00000000055577500565565000667600057765500677666066776666000000000000000000000000000000000000000000000000000000000000000000000000
00000000555557556657756606655660567665650775666067766666000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555556657656655576555505665650756665067666665000000000000000000000000000000000000000000000000000000000000000000000000
00000000565555556656656666566556505666550666665066666665000000000000000000000000000000000000000000000000000000000000000000000000
00000000566555556656656606655550505665050566655066666655000000000000000000000000000000000000000000000000000000000000000000000000
00000000056655500565565000665500056500500666555066666555000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555000006600000055000005555000065550006655550000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770707007007070070000000000055550000555500000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000070707007007070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700707007007070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700700707007007070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700700707007007070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700700707007007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700700707007070000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700700707007077777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c700000000033333333377700888888888888888888888888888888888777777777777777777777777777777800000000000000000000000000000000
000000cc77000000033b33bbbbbbbb70877777777777777777777777777777788777777777777777777777777777777800000000000000000000000000000000
00000c1c7c70000033333bbbbbbbb777878888888888888888888888888888788777777778887788877888777777777800000000000000000000000000000000
0000c1cc7cc700003333bbbbbbbb7bb7878788888888888888888888888888788777777778787787877877777777777800000000000000000000000000000000
000c1c1c7ccc700033333bbbbbb7bbb7878778888888888888888888888888788777777778877787877877777777777800000000000000000000000000000000
00c1c11c7ccc770033330b00707bbbb7878778888888888888888888888878788777777778787787877877777777777800000000000000000000000000000000
0c111c1c7c7ccc703330bbb77707bbb7878877888888888888888888888878788777777778787788877888777777777800000000000000000000000000000000
10c111c117c7c7c73330bbb00777bbb7878777788888888888888888888778788777777777777777777777777777777800000000000000000000000000000000
100c1c17707c7cc73330bb0b0077bbb7878877788888888888888888877778788777777777777777777777777777777800000000000000000000000000000000
1100c1717707cc773030bb000077bbb7878878778888888888888888777788788778887888787878877888788878887800000000000000000000000000000000
1110c1110707c7c73000b0b00007bbb7878887777888888888888787778888788778777787787878787787787878777800000000000000000000000000000000
1000c1100007ccc73000bb000007b777878888787788888888887877787778788778887787787878787787787878887800000000000000000000000000000000
1000c1100007ccc73300b00000077777878888877778888888887777777888788777787787787878787787787877787800000000000000000000000000000000
1100c0111007c7c73330b000000777b7878888888777877788777777778878788778887787788878877888788878887800000000000000000000000000000000
1000c01100077cc73330b0000007bbb7878888888877777777777777777788788777777777777777777777777777777800000000000000000000000000000000
1000c0000007ccc73300b0000007bbb7878888887777777777777777778888788888888888888888888888888888888800000000000000000000000000000000
11001000000cccc73300b000000bbbbb878888877777777777777777887788780000000000000000000000000000000000000000000000000000000000000000
11001011000cccc73330b000000bbbbb878888777777777777777777777778780000000000000000000000000000000000000000000000000000000000000000
10101110011cc77733003000000bbb7b878888777777777777777777777888780000000000000000000000000000000000000000000000000000000000000000
10001001111c77c730003000000bb7bb878887887877777777777777777778780000000000000000000000000000000000000000000000000000000000000000
11101111011cccc730003000000b7bbb878888878887777777777777787888780000000000000000000000000000000000000000000000000000000000000000
11001c00011cccc730303000000bbbbb878888888888777777778787878888780000000000000000000000000000000000000000000000000000000000000000
10001cc0111c7cc733303300000bbbbb878888888888777777777888888888780000000000000000000000000000000000000000000000000000000000000000
100101cc11ccc7c733003030000bbbbb878888888888777777778888888888780000000000000000000000000000000000000000000000000000000000000000
1010001c1ccccc7730003300000bbbbb878888888887777777778888888888780000000000000000000000000000000000000000000000000000000000000000
01001001cc1c1cc033303030300bb3bb878888877887777777788888888888780000000000000000000000000000000000000000000000000000000000000000
00100001c1c11c003330030300b33bbb878888777877777777777888888888780000000000000000000000000000000000000000000000000000000000000000
00010011ccc1c000330330bbbb3333bb878887887777777777777888888888780000000000000000000000000000000000000000000000000000000000000000
00001001c11c00003030303333333b3b878888888788877777777788888888780000000000000000000000000000000000000000000000000000000000000000
00000101c1c00000333303333333333b878888888788777777777778888888780000000000000000000000000000000000000000000000000000000000000000
00000011cc00000003333333333333b0878888887888777888777777888888780000000000000000000000000000000000000000000000000000000000000000
00000001c00000000033333333333b00878888888888888888888877888888780000000000000000000000000000000000000000000000000000000000000000
706ddd006077770600ddd607d0007777000000007777000d70000000000000000000777770aaaaaaaaa0aaaaaaaaaa0700000000000000000000000000000000
00600000600000060000060000777700011111100077770070000000004400000000007700aaaaaaaaaaaaaaaaaaaa0000000000000000000000000000000000
666666666666666666666666777700011111111110007777000000044444440000000000aaaaa00000000000000aaaaa00000000000000000000000000000000
666660000666666000066666077701111111111111107770000000044444444400000000aaa000999999999999000aaa00000000000000000000000000000000
66660a00a066660a00a06666000001111111111111100000000004444444444440000000a0009900000000000099000a00000000000000000000000000000000
66660a00a066660a00a06666d0011111111111111111100d000004444444444444400000a099900ffffffffff009990a00000000000000000000000000000000
666666666666666666666666d0000111111111111110000d000044400444444004440000a09000ffffffffffff00090a00000000000000000000000000000000
660000666666666666000066d0110000000000000000110d000044077044440770440000a000ffffffffffffffff000a00000000000000000000000000000000
6000f00006666660000f0006d0111111111111111111110d000044073044440370440000aaa0fff00ffffff00fff0aaa00000000000000000000000000000000
6000f07706000060770f0006d0111111111111111111110d000044073044440370440000aaa0ff0770ffff0770ff0aaa00000000000000000000000000000000
6000f07306000060370f0006d0111111001001001111110d000044444444444444440000aaa0ff0710ffff0170ff0aaa00000000000000000000000000000000
6000f07306600660370f0006d0000111001001001110000d000040444404404444040000aaa0ff0710ffff0170ff0aaa00000000000000000000000000000000
6000f88800666600888f00060d01000100100100100010d0000040000440044000040000aaa0ffffffffffffffff0aaa00000000000000000000000000000000
6000ff888000000888ff0006000111010010010010111000000044000044440000440000aaa0ffffff0ff0ffffff0aaa00000000000000000000000000000000
60000ffffffffffffff00006770111001010010100111077000004444444444444400000aaa00ffffff00ffffff00aaa00000000000000000000000000000000
60000888ffffffff88800006770111101110011101111077000004440444444044400000aaa00fff0ffffff0fff00aaa00000000000000000000000000000000
60000088f000000f88000006770111100010010001111077000000444000000444000000aa0000ff00000000ff0000aa00000000000000000000000000000000
6000000ffffffffff0000006770011111010010111110077000000044400004440000000aa0aa00ffffffffff00aa0aa00000000000000000000000000000000
600000000ffffff000000006007000111010010111000700000000000444444000000000000aaa000ffffff000aaa00000000000000000000000000000000000
66000000000ff0000000006610070011101001011100700170000000000440000000000777000aa0000ff0000aa0007700000000000000000000000000000000
06660000ff0000ff0000666011000000001111000000001100000ff0000000000ff000000777000fff0000fff000777000000000000000000000000000000000
006600000ffffff000006600110dddd0500000050dddd01100000ffff000000ffff00000000077000ffffff00077000000000000000000000000000000000000
6066606600ffff00660666061100ddd0055555500ddd0011000000fff004400fff000000c000000c000ff000c000000c00000000000000000000000000000000
60666066600ff006660666061110dddd00000000dddd0111aaaaa000f004400f000aaaaa0077770ccc0000ccc077770000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111100000080000000111111111111111111000000800000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111000080000000111111111111111111110000800000000000000000000000000000000000000000000000000000000000000000000000
11111111991111ff111110008000000011111111991111ff11111000800000000000000000000000000000000000000000000000000000000000000000000000
1111119ff9f111ffff111100800000001111119ff9f111ffff111100800000000000000000000000000000000000000000000000000000000000000000000000
111119ffffff11fffff1111080000000111119ffffff11fffff11110800000000000000000000000000000000000000000000000000000000000000000000000
11119ffffffff11fffff11108000000011119ffffffff11fffff1110800000000000000000000000000000000000000000000000000000000000000000000000
11199f0000ffff0000fff1118000000011199ffffffffffffffff111800000000000000000000000000000000000000000000000000000000000000000000000
1119f077770ff077770ff011800000001119ff0000ffff0000fff011800000000000000000000000000000000000000000000000000000000000000000000000
11999f7112ffff11170ff9018000000011999071110ff011170ff901800000000000000000000000000000000000000000000000000000000000000000000000
1199907211ffff11170fff00800000001199907211ffff11170fff00800000000000000000000000000000000000000000000000000000000000000000000000
11999f7111ffff11270ff9008000000011999f711ffffff1270ff900800000000000000000000000000000000000000000000000000000000000000000000000
119990711ffffff217fff90080000000119990ffffffffffff0ff900800000000000000000000000000000000000000000000000000000000000000000000000
109999fffff0fffffffff90080000000109999fffff0fffffffff900800000000000000000000000000000000000000000000000000000000000000000000000
1099ffffffff0ffffffff900800000001099ffffffff0ffffffff900800000000000000000000000000000000000000000000000000000000000000000000000
109fffffffffffffffffff0080000000109fffffffffffffffffff00800000000000000000000000000000000000000000000000000000000000000000000000
0099fffffffffffffffff900800000000099ffff00000000fffff900800000000000000000000000000000000000000000000000000000000000000000000000
0009ffff00000000fffff000800000000009ffff00000000fffff000800000000000000000000000000000000000000000000000000000000000000000000000
00099ffff000000fffff90008000000000099ffff000000fffff9000800000000000000000000000000000000000000000000000000000000000000000000000
000999ffff0000ffffff900080000000000999ffff0000ffffff9000800000000000000000000000000000000000000000000000000000000000000000000000
000099fffffffffffff9000080000000000099fffffffffffff90000800000000000000000000000000000000000000000000000000000000000000000000000
0000099ffffffffff9900000800000000000099ffffffffff9900000800000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffff00000008000000000000000fffffffff0000000800000000000000000000000000000000000000000000000000000000000000000000000
00000990000000000000000080000000000009900000000000000000800000000000000000000000000000000000000000000000000000000000000000000000
00000999999999999900000080000000000009999999999999000000800000000000000000000000000000000000000000000000000000000000000000000000
88888888888888888888888800000000888888888888888888888888000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006606660666000006060606066006660666066600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000060006000666000006060606060600600600060600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000060006600606000006660606060600600660066000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000060606000606000006060606060600600600060600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066606660606000006060066060600600666060600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000c70000000000000000000000000000000003333333337770000000000000000000000000000000000
0000000000000000000000000000000000000000000000cc77000000000000000000000000000000033b33bbbbbbbb7000000000000000000000000000000000
000000000000000000000000000000000000000000000c1c7c70000000000000000000000000000033333bbbbbbbb77700000000000000000000000000000000
00000000000000000000000000000000000000000000c1cc7cc700000000000000000000000000003333bbbbbbbb7bb700000000000000000000000000000000
0000000000000000000000000000000000000000000c1c1c7ccc700000000000000000000000000033333bbbbbb7bbb700000000000000000000000000000000
000000000000000000000000000000000000000000c1c11c7ccc770000000000000000000000000033330b00707bbbb700000000000000000000000000000000
00000000000000000000000000000000000000000c111c1c7c7ccc700000000000000000000000003330bbb77707bbb700000000000000000000000000000000
000000000000000000000000000000000000000010c111c117c7c7c70000000000000000000000003330bbb00777bbb700000000000000000000000000000000
0000000000000000000000000000000000000000100c1c17707c7cc70000000000000000000000003330bb0b0077bbb700000000000000000000000000000000
00000000000000000000000000000000000000001100c1717707cc770000000000000000000000003030bb000077bbb700000000000000000000000000000000
00000000000000000000000000000000000000001110c1110707c7c70000000000000000000000003000b0b00007bbb700000000000000000000000000000000
00000000000000000000000000000000000000001000c1100007ccc70000000000000000000000003000bb000007b77700000000000000000000000000000000
00000000000000000000000000000000000000001000c1100007ccc70000000000000000000000003300b0000007777700000000000000000000000000000000
00000000000000000000000000000000000000001100c0111007c7c70000000000000000000000003330b000000777b700000000000000000000000000000000
00000000000000000000000000000000000000001000c01100077cc70000000000000000000000003330b0000007bbb700000000000000000000000000000000
00000000000000000000000000000000000000001000c00000c7ccc70000000000000000000000003300b0000007bbb700000000000000000000000000000000
000000000000000000000000000000000000000011001000ccccccc70000000000000000000000003300b000000bbbbb00000000000000000000000000000000
000000000000000000000000000000000000000011001011c00cccc70000000000000000000000003330b000000bbbbb00000000000000000000000000000000
000000000000000000000000000000000000000010101110011cc77700000000000000000000000033003000000bbb7b00000000000000000000000000000000
000000000000000000000000000000000000000010001001111c77c700000000000000000000000030003000000bb7bb00000000000000000000000000000000
000000000000000000000000000000000000000011101111011cccc700000000000000000000000030003000000b7bbb00000000000000000000000000000000
000000000000000000000000000000000000000011001c00011cccc700000000000000000000000030303000000bbbbb00000000000000000000000000000000
000000000000000000000000000000000000000010001cc0111c7cc700000000000000000000000033303300000bbbbb00000000000000000000000000000000
0000000000000000000000000000000000000000100101cc11ccc7c700000000000000000000000033003030000bbbbb00000000000000000000000000000000
00000000000000000000000000000000000000001010001c1ccccc7700000000000000000000000030003300000bbbbb00000000000000000000000000000000
000000000000000000000000000000000000000001001001cc1c1cc000000000000000000000000033303030300bb3bb00000000000000000000000000000000
000000000000000000000000000000000000000000100001c1c11c000000000000000000000000003330030300b33bbb00000000000000000000000000000000
000000000000000000000000000000000000000000010011ccc1c000000000000000000000000000330330bbbb3333bb00000000000000000000000000000000
000000000000000000000000000000000000000000001001c11c00000000000000000000000000003030303333333b3b00000000000000000000000000000000
000000000000000000000000000000000000000000000101c1c00000000000000000000000000000333303333333333b00000000000000000000000000000000
000000000000000000000000000000000000000000000011cc00000000000000000000000000000003333333333333b000000000000000000000000000000000
000000000000000000000000000000000000000000000001c00000000000000000000000000000000033333333333b0000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000066606660666006600660000066600000666006600000066066606660666066600000000000000000000000000000
00000000000000000000000000000000000060606060600060006000000000600000060060600000600006006060606006000000000000000000000000000000
00000000000000000000000000000000000066606600660066606660000006000000060060600000666006006660660006000000000000000000000000000000
00000000000000000000000000000000000060006060600000600060000060000000060060600000006006006060606006000000000000000000000000000000
00000000000000000000000000000000000060006060666066006600000066600000060066000000660006006060606006000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006060666000006000000066000000660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006060606000006000000006000000060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006060606000006660000006000000060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660606000006060000006000000060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600666006006660060066600600666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000100000635007350083500a3500c3500e3500f35011350133501535017350193501a3501a3501a3501a3501d3001d3001d3001c300155001500015000151001510015100151001510015100151001510015100
000300002e0402f04030040320403404036040380403a0403c0403d0402b0002c0002f0003400037000257002d3003b300103000e3000d3000d3000d3000d3000c3000c3000c3000c3000c3000d3000f30010300
