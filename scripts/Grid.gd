extends Node2D

# Grid setup variables
export (int) var width_in_blocks = 8
export (int) var height_in_blocks = 10
export (int) var x_start_position = 64
export (int) var y_start_position = 128
export (int) var offset = 78
export (int) var new_block_start_offset = 1

var filler_blocks = [
	preload("res://scenes/blocks/filler/block_magenta.tscn"),
	preload("res://scenes/blocks/filler/block_red.tscn"),
	preload("res://scenes/blocks/filler/block_orange.tscn"),
	preload("res://scenes/blocks/filler/block_yellow.tscn"),
	preload("res://scenes/blocks/filler/block_green.tscn"),
	preload("res://scenes/blocks/filler/block_blue.tscn"),
	preload("res://scenes/blocks/filler/block_violet.tscn")
]
var special_blocks = [
	preload("res://scenes/blocks/special/cross/block_magenta_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_red_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_orange_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_yellow_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_green_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_blue_cross.tscn"),
	preload("res://scenes/blocks/special/cross/block_violet_cross.tscn")
]
# TOOD: do something more robust than this (if only this language supported structures)
var special_blocks_spawn_percent = [
	1,
	1,
	1,
	1,
	1,
	1,
	1,
]

# The blocks currently in the grid, a 2D array filled at runtime
var blocks

# Locations currently marked for destruction because they are matched
var matched_locations

export (NodePath) var game_mode_path

onready var game_mode = get_node(game_mode_path)

const MAX_MOVEMENT_DISTANCE = 1

enum InteractionState {WAITING_ON_ANIMATION, WAITING_FOR_FIRST_SELECTION, WAITING_FOR_SECOND_SELECTION}
var interaction_state = WAITING_FOR_FIRST_SELECTION

const directions = {
	up = Vector2(0, 1),
	down = Vector2(0, -1),
	left = Vector2(-1, 0),
	right = Vector2(1, 0)
}

func _ready():
	randomize()
	blocks = make_2D_array()
	populate_grid()
	matched_locations = make_2D_array()
	reset_matched_locations()

# Creates and returns a 2-dimensional array
func make_2D_array():
	var array = []
	for i in height_in_blocks:
		array.append([])
		for j in width_in_blocks:
			array[i].append(null)
	return array

func reset_matched_locations():
	for i in height_in_blocks:
		for j in width_in_blocks:
			matched_locations[i][j] = false

func reset_interaction_state():
	is_first_time_finding_matches = true
	interaction_state = WAITING_FOR_FIRST_SELECTION
	game_mode.on_grid_entered_ready_state()

# func get_block(row, column):
# 	assert(row >= 0 && row < height_in_blocks)
# 	assert(column >= 0 && column < width_in_blocks)
# 	assert(blocks[row][column] != null)
# 	return blocks[row][column]

func get_new_block():
	var total_chance_for_special = 0.0
	for i in special_blocks.size():
		total_chance_for_special += special_blocks_spawn_percent[i] * 0.01
	var spawn_filler_or_special = rand_range(0.0, 1.0)
	if spawn_filler_or_special <= total_chance_for_special:
		var random_special_block_index = floor(rand_range(0, special_blocks.size()))
		return special_blocks[random_special_block_index].instance()
	else:
		var random_filler_block_index = floor(rand_range(0, filler_blocks.size()))
		return filler_blocks[random_filler_block_index].instance()

# func set_block(row, column, new_block):
# 	assert(row >= 0 && row < height_in_blocks)
# 	assert(column >= 0 && column < width_in_blocks)
# 	assert(new_block != null)
# 	blocks[row][column] = new_block

func populate_grid():
	for i in height_in_blocks:
		for j in width_in_blocks:
			var new_block = get_new_block()

			while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
				new_block = get_new_block()

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

func shuffle_grid():
	if OS.is_debug_build():
		for i in height_in_blocks:
			for j in width_in_blocks:
				blocks[i][j].queue_free()
				blocks[i][j] = null
		reset_matched_locations()
		populate_grid()
		reset_interaction_state()

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
			if interaction_state == WAITING_FOR_FIRST_SELECTION:
				blocks[click.x][click.y].on_selected_pressed()

	if Input.is_action_just_released("ui_click"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			if interaction_state == WAITING_FOR_FIRST_SELECTION:
				first_click = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
				blocks[first_click.x][first_click.y].on_selected_released()
				interaction_state = WAITING_FOR_SECOND_SELECTION
			elif interaction_state == WAITING_FOR_SECOND_SELECTION:
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
	if first_block_grid.distance_squared_to(second_block_grid) <= MAX_MOVEMENT_DISTANCE:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null && first_block.is_swappable && second_block.is_swappable:
			store_last_swap(first_block, second_block, first_block_grid, second_block_grid)

			interaction_state = WAITING_ON_ANIMATION
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
			# play error tone, whatever
			reset_interaction_state() # TODO: this is ugly, fix this by adding get_block(row, col)
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
	# for each block
	# get all the nearby ones within the valid distance for matching
	# find any with same color
	# extend the chain in the same direction until color stops being the same
	# save length
	# set matched

	for i in height_in_blocks:
		for j in width_in_blocks:
			if blocks[i][j] != null:
				var color_to_check = blocks[i][j].block_color
				if i > 0 && i < height_in_blocks - 1:
					if blocks[i - 1][j] != null && blocks[i + 1][j] != null:
						if blocks[i - 1][j].block_color == color_to_check && blocks[i + 1][j].block_color == color_to_check:
							any_matches_found = true
							set_matched(i - 1, j)
							set_matched(i, j)
							set_matched(i + 1, j)
				if j > 0 && j < width_in_blocks - 1:
					if blocks[i][j - 1] != null && blocks[i][j + 1] != null:
						if blocks[i][j - 1].block_color == color_to_check && blocks[i][j + 1].block_color == color_to_check:
							any_matches_found = true
							set_matched(i, j - 1)
							set_matched(i, j)
							set_matched(i, j + 1)

	if any_matches_found:
		do_special_destroy_behavior()
	else: 
		# No matches were found, so either swap back (the match was invalid) or select again (the chain is finished)
		if is_first_time_finding_matches:
			unswap_blocks()
		else:
			reset_interaction_state()

# Called whenever a location becomes part of a match
func set_matched(row, column):
	# Verify row and column are accessible
	if row >= 0 && row < height_in_blocks:
		if column >= 0 && column < blocks[row].size():
			# Blocks can only be set as matched once
			if !matched_locations[row][column]:
				matched_locations[row][column] = true
				blocks[row][column].play_destroy_animation()

# TODO: refactor this
func do_special_destroy_behavior():
	for row in height_in_blocks:
		for column in width_in_blocks:
			if matched_locations[row][column]:
				var block = blocks[row][column]
				var behavior = block.special_destroy_behavior
				match behavior:
					block.SpecialDestroyBehavior.SQUARE:
						for i in range(row - 1, row + 1 + 1): # range() uses final - 1, so add 1 
							for j in range(column - 1, column + 1 + 1): # range() uses final - 1, so add 1 
								set_matched(i, j)
					block.SpecialDestroyBehavior.ROW:
						for j in blocks[row].size():
							set_matched(row, j)
					block.SpecialDestroyBehavior.COLUMN:
						for i in height_in_blocks:
							set_matched(i, column)
					block.SpecialDestroyBehavior.CROSS:
						for i in height_in_blocks:
							set_matched(i, column)
						for j in blocks[row].size():
							set_matched(row, j)
					block.SpecialDestroyBehavior.ALL_OF_SAME_COLOR:
						for i in height_in_blocks:
							for j in width_in_blocks:
								if blocks[i][j] != null:
									if blocks[i][j].block_color == block.block_color:
										set_matched(i, j)
	get_node("destroy_animation_delay").start()

func _on_destroy_animation_delay_timeout():
	destroy_matched()

# Destroys all blocks that are matched
func destroy_matched():
	for i in height_in_blocks:
		for j in width_in_blocks:
			if blocks[i][j] != null:
				if matched_locations[i][j]:
					blocks[i][j].queue_free()
					blocks[i][j] = null

	reset_matched_locations()
	collapse_null()

# Collapses grid columns, moving any null spaces to the top of the column
func collapse_null():
	is_first_time_finding_matches = false
	for i in range(height_in_blocks - 1, 0 - 1, -1): # Iterates from the bottom of the grid up
		for j in width_in_blocks:
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
	for i in height_in_blocks:
		for j in width_in_blocks:
			if blocks[i][j] == null:
				var new_block = get_new_block()

				while would_match_be_formed_at(i, j, new_block.block_color): # Make sure that index will not form a match
					new_block = get_new_block()

				add_child(new_block)
				new_block.position = grid_to_pixel(i - new_block_start_offset, j)
				new_block.move_smooth(grid_to_pixel(i, j))
				blocks[i][j] = new_block
	get_node("after_repopulate_delay").start()

func _on_after_repopulate_delay_timeout():
	find_matches()

func _process(delta):
	get_user_mouse_input()
