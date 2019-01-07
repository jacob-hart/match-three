extends Node2D

# Grid state machine variables
enum {STATE_WAITING_ON_ANIMATION, STATE_WAITING_FOR_FIRST_SELECTION, STATE_WAITING_FOR_SECOND_SELECTION}
var interaction_state = STATE_WAITING_FOR_FIRST_SELECTION

enum MovementDirections {ADJACENT_ONLY = 1, DIAGONAL_AND_ADJACENT = 2}

export (int) var width_in_blocks
export (int) var height_in_blocks

# TODO make these determined programmatically
export (int) var x_start_position
export (int) var y_start_position 
export (int) var offset
export (int) var new_block_start_offset

export (MovementDirections) var allowed_movement_directions

export (NodePath) var game_mode_path

onready var game_mode = get_node(game_mode_path)

# All blocks that can possibly fill the grid
var potential_blocks = [
	preload("res://scenes/blocks/block_magenta.tscn"),
	preload("res://scenes/blocks/block_red.tscn"),
	preload("res://scenes/blocks/block_orange.tscn"),
	preload("res://scenes/blocks/block_yellow.tscn"),
	preload("res://scenes/blocks/block_green.tscn"),
	preload("res://scenes/blocks/block_blue.tscn"),
	preload("res://scenes/blocks/block_violet.tscn")
]

# The blocks currently in the grid, a 2D array filled at runtime
var blocks

# TODO: Add a get block function

# Locations currently marked for destruction because they are matched
var matched_locations

func _ready():
	blocks = make_2D_array()
	populate_grid()
	matched_locations = make_2D_array()
	reset_matched_locations()

# Creates and returns a 2-dimensional array the old-fashioned way
func make_2D_array():
	var array = []
	for i in height_in_blocks:
		array.append([])
		for j in width_in_blocks:
			array[i].append(null)
	return array

func reset_matched_locations():
	for i in matched_locations.size():
		for j in matched_locations[i].size():
			matched_locations[i][j] = false

func reset_interaction_state():
	is_first_time_finding_matches = true
	interaction_state = STATE_WAITING_FOR_FIRST_SELECTION
	game_mode.on_grid_entered_ready_state()

# Fills the grid with blocks from potential_blocks
func populate_grid():
	randomize()
	for i in blocks.size():
		for j in blocks[i].size():
			var random_block_index = floor(rand_range(0, potential_blocks.size()))
			var new_block = potential_blocks[random_block_index].instance()

			while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
				random_block_index = floor(rand_range(0, potential_blocks.size())) # Generate a new index to use
				new_block = potential_blocks[random_block_index].instance() # Form a new block with that index

			add_child(new_block)
			new_block.position = grid_to_pixel(i, j)

			blocks[i][j] = new_block

# Determines if a match of block_color would be formed by placing a block_color block at row, column
func would_match_be_formed_at(row, column, block_color):
	if row >= 2:
		if blocks[row - 1][column] != null && blocks[row - 2][column] != null: 
			if blocks[row - 1][column].block_color == block_color && blocks[row - 2][column].block_color == block_color:
				return true
	if column >= 2:
		if blocks[row][column - 1] != null && blocks[row][column - 2] != null: 
			if blocks[row][column - 1].block_color == block_color && blocks[row][column - 2].block_color == block_color:
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
	if Input.is_action_just_pressed("ui_click"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			var click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			if interaction_state == STATE_WAITING_FOR_FIRST_SELECTION:
				blocks[click.x][click.y].on_selected_pressed()

	if Input.is_action_just_released("ui_click"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			if interaction_state == STATE_WAITING_FOR_FIRST_SELECTION:
				first_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
				blocks[first_click.x][first_click.y].on_selected_released()
				interaction_state = STATE_WAITING_FOR_SECOND_SELECTION
			elif interaction_state == STATE_WAITING_FOR_SECOND_SELECTION:
				second_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
				blocks[first_click.x][first_click.y].on_unselected()
				swap_blocks(first_click, second_click)

var last_swap = {
	first_block =  null,
	second_block =  null,
	first_block_grid = Vector2(0, 0),
	second_block_grid = Vector2(0, 0)
}

func store_last_swap(first_block, second_block, first_block_grid, second_block_grid):
	last_swap["first_block"] = first_block
	last_swap["second_block"] = second_block
	last_swap["first_block_grid"] = first_block_grid
	last_swap["second_block_grid"] = second_block_grid

var is_first_time_finding_matches = true

# Swaps on-screen positions and grid positions of two blocks as long as they are an allowed movement
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_squared_to(second_block_grid) <= allowed_movement_directions:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null:
			store_last_swap(first_block, second_block, first_block_grid, second_block_grid)

			interaction_state = STATE_WAITING_ON_ANIMATION
			game_mode.on_grid_entered_wait_state()

			blocks[first_block_grid.x][first_block_grid.y] = second_block
			blocks[second_block_grid.x][second_block_grid.y] = first_block

			# The user is likely more focused on the movement of the first block than the second block, so render the first block above the second
			first_block.z_index = 1 
			second_block.z_index = 0

			first_block.move_smooth(grid_to_pixel(second_block_grid.x, second_block_grid.y))
			second_block.move_smooth(grid_to_pixel(first_block_grid.x, first_block_grid.y))

			get_node("after_swap_delay").start() 
	else:
		# The swap must not have been possible, so let the user select again
		reset_interaction_state()

func _on_after_swap_delay_timeout():
	find_matches()

func unswap_blocks():
	is_first_time_finding_matches = false # This prevents the unswapped blocks from entering an infinite loop of swapping back and forth 
	if last_swap["first_block"] != null && last_swap["second_block"] != null:
		swap_blocks(last_swap["second_block_grid"], last_swap["first_block_grid"])

# Marks every match found for later removal
func find_matches():
	var any_matches_found = false
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				var color_to_check = blocks[i][j].block_color
				if i > 0 && i < blocks.size() - 1:
					if blocks[i - 1][j] != null && blocks[i + 1][j] != null:
						if blocks[i - 1][j].block_color == color_to_check && blocks[i + 1][j].block_color == color_to_check:
							any_matches_found = true
							set_matched(i - 1, j)
							set_matched(i, j)
							set_matched(i + 1, j)
				if j > 0 && j < blocks[i].size() - 1:
					if blocks[i][j - 1] != null && blocks[i][j + 1] != null:
						if blocks[i][j - 1].block_color == color_to_check && blocks[i][j + 1].block_color == color_to_check:
							any_matches_found = true
							set_matched(i, j - 1)
							set_matched(i, j)
							set_matched(i, j + 1)

	if any_matches_found:
		get_node("destroy_animation_delay").start()
	else: 
		# No matches were found, so either swap back (the match was invalid) or select again (the chain is finished)
		if is_first_time_finding_matches:
			unswap_blocks()
		else:
			reset_interaction_state()

# Called whenever a location becomes part of a match
func set_matched(i, j):
	if !matched_locations[i][j]:
		if i >= 0 && i < blocks.size():
			if j >= 0 && j < blocks[i].size():
				blocks[i][j].play_destroy_animation()
				matched_locations[i][j] = true
				do_special_destroy_behavior(i, j)
				game_mode.add_match(1, 0.3)

func do_special_destroy_behavior(row, column):
	var block = blocks[row][column]
	var behavior = block.special_destroy_behavior
	match behavior:
		block.DESTROY_SQUARE:
			# Destroys blocks adjacent and diagonal to the originating block
			pass
		block.DESTROY_ROW:
			for j in blocks[row].size():
				set_matched(row, j)
		block.DESTROY_COLUMN:
			for i in blocks.size():
				set_matched(i, column)
		block.DESTROY_CROSS:
			# Does row and column destruction simultaneously
			pass
		block.DESTROY_X:
			# Destroys in two perpendicular diagonal lines that form an X shape with the orginating block at the center
			pass
		block.DESTROY_ALL_OF_SAME_COLOR:
			for i in blocks.size():
				for j in blocks[i].size():
					if blocks[i][j] != null:
						if blocks[i][j].block_color == block.block_color:
							set_matched(i, j)

func _on_destroy_animation_delay_timeout():
	destroy_matched()

# Destroys all blocks that are matched
func destroy_matched():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				if matched_locations[i][j]:
					blocks[i][j].queue_free()
					blocks[i][j] = null

	reset_matched_locations()
	collapse_null()

# Collapses grid columns, moving any null spaces to the top of the column
func collapse_null():
	is_first_time_finding_matches = false
	for i in range(blocks.size() - 1, 0 - 1, -1): # Iterates from the bottom of the grid up
		for j in blocks[i].size():
			if blocks[i][j] == null:
				for k in range(i, 0 - 1, -1): # Iterates from the bottom of the column up
					if blocks[k][j] != null: 
						blocks[k][j].move_smooth(grid_to_pixel(i, j))
						blocks[i][j] = blocks[k][j]
						blocks[k][j] = null 
						break
	get_node("after_collapse_delay").start()

func _on_after_collapse_delay_timeout():
	repopulate_grid()

# Adds new blocks to empty spaces after matches were destroyed
func repopulate_grid():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] == null:
				var random_block_index = floor(rand_range(0, potential_blocks.size()))
				var new_block = potential_blocks[random_block_index].instance()

				while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
					random_block_index = floor(rand_range(0, potential_blocks.size())) # Generate a new index to use
					new_block = potential_blocks[random_block_index].instance() # Form a new block with that index

				add_child(new_block)
				new_block.position = grid_to_pixel(i - new_block_start_offset, j)
				new_block.move_smooth(grid_to_pixel(i, j))
				blocks[i][j] = new_block
	get_node("after_repopulate_delay").start()

func _on_after_repopulate_delay_timeout():
	find_matches()

func _process(delta):
	get_user_mouse_input()
