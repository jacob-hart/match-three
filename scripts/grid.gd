extends Node2D

# Grid state machine variables
enum {STATE_WAITING, STATE_READY_TO_MOVE}
var grid_state

export (int) var width_in_blocks
export (int) var height_in_blocks

# TODO make these determined programmatically
export (int) var x_start_position
export (int) var y_start_position 
export (int) var offset
export (int) var new_block_start_offset

# All blocks that can possibly fill the grid
var potential_blocks = [
	#preload("res://scenes/block_magenta.tscn"),
	preload("res://scenes/block_red.tscn"),
	preload("res://scenes/block_orange.tscn"),
	preload("res://scenes/block_yellow.tscn"),
	preload("res://scenes/block_green.tscn"),
	preload("res://scenes/block_blue.tscn"),
	preload("res://scenes/block_violet.tscn"),
]

# The blocks currently in the grid, a 2D array filled at runtime
var blocks = []

# TODO: create object pool for blocks and then make it so each destruction and addition uses the pool

# Locations for on-screen touches/mouse clicks
var touch_begin = Vector2(0, 0)
var touch_end = Vector2(0, 0)
var is_controlling_block = false

func _ready():
	grid_state = STATE_READY_TO_MOVE
	blocks = make_2D_array()
	populate_grid()

# Creates and returns a 2-dimensional array the old-fashioned way
func make_2D_array():
	var array = []
	for i in height_in_blocks:
		array.append([])
		for j in width_in_blocks:
			array[i].append(null)
	return array

# Fills the grid with blocks from potential_blocks
func populate_grid():
	randomize()
	for i in blocks.size():
		for j in blocks[i].size():
			var random_block_index = floor(rand_range(0, potential_blocks.size()))
			var new_block = potential_blocks[random_block_index].instance()

			while match_at(i, j, new_block.block_color): # Make sure that index will not form a match
				random_block_index = floor(rand_range(0, potential_blocks.size())) # Generate a new index to use
				new_block = potential_blocks[random_block_index].instance() # Form a new block with that index

			add_child(new_block)
			new_block.position = grid_to_pixel(i, j)
			blocks[i][j] = new_block
	
# Determines if there is a match of block_color at row, column in the grid
func match_at(row, column, block_color):
	if row >= 2:
		if blocks[row - 1][column] != null && blocks[row - 2][column] != null: 
			if blocks[row - 1][column].block_color == block_color && blocks[row - 2][column].block_color == block_color: # TODO: make it so colorless matches with anything
				return true
	if column >= 2:
		if blocks[row][column - 1] != null && blocks[row][column - 2] != null: 
			if blocks[row][column - 1].block_color == block_color && blocks[row][column - 2].block_color == block_color: # TODO: make it so colorless matches with anything
				return true
	return false

# Converts a grid coordinate to a screen pixel coordinate
func grid_to_pixel(row, column):
	var new_x = x_start_position + offset * column
	var new_y = y_start_position + offset * row
	return Vector2(abs(new_x), abs(new_y))

# Converts a screen pixel coordinate to a grid coordinate
func pixel_to_grid(x, y):
	var row = round((y - y_start_position) / offset)
	var column = round((x - x_start_position) / offset)
	return Vector2(abs(row), abs(column))
	
# Checks if a grid coordinate is in the grid and usable
func is_in_grid(grid_coordinate):
	return (grid_coordinate.x >= 0 && grid_coordinate.x < height_in_blocks && grid_coordinate.y >= 0 && grid_coordinate.y < width_in_blocks)

# Gets click/touch locations used for block movement
func get_user_touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			touch_begin = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			is_controlling_block = true

	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			touch_end = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			swap_blocks(touch_begin, touch_end)
			is_controlling_block = false

# Swaps on-screen positions and grid positions of two blocks as long as they are adjacent
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_to(second_block_grid) <= 1:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null:
			grid_state = STATE_WAITING
			blocks[first_block_grid.x][first_block_grid.y] = second_block
			blocks[second_block_grid.x][second_block_grid.y] = first_block

			first_block.z_index = 1 # The user is likely more focused on the movement of the first block than the second block, so render the first block above the second
			first_block.move(grid_to_pixel(second_block_grid.x, second_block_grid.y))
			second_block.move(grid_to_pixel(first_block_grid.x, first_block_grid.y))
			find_matches()

# TODO: add unswap behavior

# Determines if there are any matches in the entire grid, and then removes any found
func find_matches(): # TODO: simplify this using the match_at function
	var any_matches_found = false
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				var color_to_check = blocks[i][j].block_color
				if i > 0 && i < blocks.size() - 1:
					if blocks[i - 1][j] != null && blocks[i + 1][j] != null:
						if blocks[i - 1][j].block_color == color_to_check && blocks[i + 1][j].block_color == color_to_check:
							any_matches_found = true
							blocks[i - 1][j].set_matched()
							blocks[i][j].set_matched()
							blocks[i + 1][j].set_matched()
				if j > 0 && j < blocks[i].size() - 1:
					if blocks[i][j - 1] != null && blocks[i][j + 1] != null:
						if blocks[i][j - 1].block_color == color_to_check && blocks[i][j + 1].block_color == color_to_check:
							any_matches_found = true
							blocks[i][j - 1].set_matched()
							blocks[i][j].set_matched()
							blocks[i][j + 1].set_matched()
	if any_matches_found:
		get_node("destroy_timer").start()
	else:
		grid_state = STATE_READY_TO_MOVE

# Destroys all blocks where is_matched is true
func destroy_matched():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				if blocks[i][j].is_matched:
					blocks[i][j].queue_free()
					blocks[i][j] = null
	get_node("collapse_timer").start()

func _on_destroy_timer_timeout():
	destroy_matched() 

# Collapses grid columns, moving any null spaces to the top of the column
func collapse_null():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] == null:
				for k in range(i + 1, blocks.size()): # TODO: fix this so that the blocks collapse down not up
					if blocks[k][j] != null: 
						blocks[k][j].move(grid_to_pixel(i, j))
						blocks[i][j] = blocks[k][j]
						blocks[k][j] = null 
						break
	get_node("repopulate_timer").start()

func _on_collapse_timer_timeout():
	collapse_null()

# Adds new blocks to empty spaces after matches were destroyed
func repopulate_grid():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] == null:
				var random_block_index = floor(rand_range(0, potential_blocks.size()))
				var new_block = potential_blocks[random_block_index].instance()

				while match_at(i, j, new_block.block_color): # Make sure that index will not form a match
					random_block_index = floor(rand_range(0, potential_blocks.size())) # Generate a new index to use
					new_block = potential_blocks[random_block_index].instance() # Form a new block with that index

				add_child(new_block)
				new_block.position = grid_to_pixel(i + new_block_start_offset, j) # TODO: once collapsing is fixed, change this to subtract offset
				new_block.move(grid_to_pixel(i, j))
				blocks[i][j] = new_block
	find_matches()

# TODO: if no waiting is desired, remove the timer aspect of this 
func _on_repopulate_timer_timeout():
	repopulate_grid()

func _process(delta):
	if grid_state == STATE_READY_TO_MOVE:
		get_user_touch_input()



	
