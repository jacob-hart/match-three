extends Node2D

# Grid state machine variables
enum {STATE_WAITING_ON_ANIMATION, STATE_WAITING_FOR_FIRST_SELECTION, STATE_WAITING_FOR_SECOND_SELECTION}
var interaction_state = STATE_WAITING_FOR_FIRST_SELECTION

enum MovementDirections {ADJACENT_ONLY = 1, ADJACENT_AND_DIAGONAL = 2}

export (int) var width_in_blocks
export (int) var height_in_blocks

# TODO make these determined programmatically
export (int) var x_start_position
export (int) var y_start_position 
export (int) var offset
export (int) var new_block_start_offset

export (MovementDirections) var allowed_movement_directions

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

func _ready():
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

var first_click = Vector2(0, 0)
var second_click = Vector2(0, 0)
# Gets click locations and selects blocks based on that input
func get_user_mouse_input():
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			if interaction_state == STATE_WAITING_FOR_FIRST_SELECTION:
				first_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
				blocks[first_click.x][first_click.y].set_selected()
				interaction_state = STATE_WAITING_FOR_SECOND_SELECTION
			elif interaction_state == STATE_WAITING_FOR_SECOND_SELECTION:
				second_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
				blocks[first_click.x][first_click.y].set_unselected()
				swap_blocks(first_click, second_click)

### TODO: replace this block with a struct of some sort
var last_first_block = null
var last_second_block = null
var last_first_block_grid = Vector2(0, 0)
var last_second_block_grid = Vector2(0, 0)
###
var first_time_finding = true

# Swaps on-screen positions and grid positions of two blocks as long as they are adjacent
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_squared_to(second_block_grid) <= allowed_movement_directions:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null:
			### TODO: replace this block with a method perhaps or something more robust
			last_first_block = first_block
			last_second_block = second_block
			last_first_block_grid = first_block_grid
			last_second_block_grid = second_block_grid
			###
			interaction_state = STATE_WAITING_ON_ANIMATION
			blocks[first_block_grid.x][first_block_grid.y] = second_block
			blocks[second_block_grid.x][second_block_grid.y] = first_block

			first_block.z_index = 1 # The user is likely more focused on the movement of the first block than the second block, so render the first block above the second
			first_block.move(grid_to_pixel(second_block_grid.x, second_block_grid.y))
			second_block.move(grid_to_pixel(first_block_grid.x, first_block_grid.y))
			find_matches()
	else:
		# The swap must not have been possible, so let the user select again
		interaction_state = STATE_WAITING_FOR_FIRST_SELECTION

func unswap_blocks():
	if last_first_block != null && last_second_block != null:
		swap_blocks(last_second_block_grid, last_first_block_grid)
	first_time_finding = false
	get_node("unswap_timer").start()

func _on_unswap_timer_timeout():
	interaction_state = STATE_WAITING_FOR_FIRST_SELECTION

# Marks every match found for later removal
func find_matches(): # TODO: simplify this using the match_at function
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				var color_to_check = blocks[i][j].block_color
				if i > 0 && i < blocks.size() - 1:
					if blocks[i - 1][j] != null && blocks[i + 1][j] != null:
						if blocks[i - 1][j].block_color == color_to_check && blocks[i + 1][j].block_color == color_to_check:
							blocks[i - 1][j].set_matched()
							blocks[i][j].set_matched()
							blocks[i + 1][j].set_matched()
				if j > 0 && j < blocks[i].size() - 1:
					if blocks[i][j - 1] != null && blocks[i][j + 1] != null:
						if blocks[i][j - 1].block_color == color_to_check && blocks[i][j + 1].block_color == color_to_check:
							blocks[i][j - 1].set_matched()
							blocks[i][j].set_matched()
							blocks[i][j + 1].set_matched()
	get_node("destroy_timer").start()

# Destroys all blocks where is_matched is true
func destroy_matched():
	var any_matches_found = false
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				if blocks[i][j].is_matched:
					any_matches_found = true
					blocks[i][j].queue_free()
					blocks[i][j] = null
	if any_matches_found:
		get_node("collapse_timer").start()
	else: 
		# No matches were found, so either swap back (the match was invalid) or select again (the chain is finished)
		if first_time_finding:
			unswap_blocks()
		else:
			first_time_finding = true
			interaction_state = STATE_WAITING_FOR_FIRST_SELECTION

func _on_destroy_timer_timeout():
	destroy_matched() 

# Collapses grid columns, moving any null spaces to the top of the column
func collapse_null():
	first_time_finding = false
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
	get_user_mouse_input()
