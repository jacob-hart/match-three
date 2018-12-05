extends Node2D

export (int) var width_in_blocks
export (int) var height_in_blocks

# TODO make these determined programmatically
export (int) var x_start_position
export (int) var y_start_position 
export (int) var offset

# All blocks that can possibly fill the grid
var potential_blocks = [
	preload("res://scenes/block_magenta.tscn"),
	preload("res://scenes/block_red.tscn"),
	preload("res://scenes/block_orange.tscn"),
	preload("res://scenes/block_yellow.tscn"),
	preload("res://scenes/block_green.tscn"),
	preload("res://scenes/block_blue.tscn"),
	preload("res://scenes/block_violet.tscn"),
]

# The blocks currently in the grid, a 2D array filled at runtime
var blocks = []

# Locations for on-screen touches/mouse clicks
var touch_begin = Vector2(0, 0)
var touch_end = Vector2(0, 0)
var is_controlling_block = false

func _ready():
	blocks = make_2D_array()
	populate_grid()

func make_2D_array():
	var array = []
	for i in height_in_blocks:
		array.append([])
		for j in width_in_blocks:
			array[i].append(null)
	return array

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

func grid_to_pixel(row, column):
	var new_x = x_start_position + offset * column
	var new_y = y_start_position + offset * row
	return Vector2(abs(new_x), abs(new_y))

func pixel_to_grid(x, y):
	var row = round((y - y_start_position) / offset)
	var column = round((x - x_start_position) / offset)
	return Vector2(abs(row), abs(column))
	
func is_in_grid(grid_coordinate):
	return (grid_coordinate.x >= 0 && grid_coordinate.x < height_in_blocks && grid_coordinate.y >= 0 && grid_coordinate.y < width_in_blocks)

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

	
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_to(second_block_grid) <= 1:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]
		if first_block != null && second_block != null:
			blocks[first_block_grid.x][first_block_grid.y] = second_block
			blocks[second_block_grid.x][second_block_grid.y] = first_block

			first_block.z_index = 1 # The user is likely more focused on the movement of the first block than the second block, so render the first block above the second
			first_block.move(grid_to_pixel(second_block_grid.x, second_block_grid.y))
			second_block.move(grid_to_pixel(first_block_grid.x, first_block_grid.y))
			find_matches()

func find_matches(): # TODO: simplify this using the match_at function
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				var color_to_check = blocks[i][j].block_color
				if i > 0 && i < blocks.size() - 1:
					if blocks[i - 1][j] != null && blocks[i + 1][j] != null:
						if blocks[i - 1][j].block_color == color_to_check && blocks[i + 1][j].block_color == color_to_check:
							blocks[i - 1][j].is_matched = true
							#blocks[i - 1][j].change_opacity()
							blocks[i][j].is_matched = true
							#blocks[i][j].change_opacity()
							blocks[i + 1][j].is_matched = true
							#blocks[i + 1][j].change_opacity()
				if j > 0 && j < blocks[i].size() - 1:
					if blocks[i][j - 1] != null && blocks[i][j + 1] != null:
						if blocks[i][j - 1].block_color == color_to_check && blocks[i][j + 1].block_color == color_to_check:
							blocks[i][j - 1].is_matched = true
							#blocks[i][j - 1].change_opacity()
							blocks[i][j].is_matched = true
							#blocks[i][j].change_opacity()
							blocks[i][j + 1].is_matched = true
							#blocks[i][j + 1].change_opacity()
	get_node("destroy_timer").start() # TODO: make the destroy timer a child node of blocks to allow for asynchronous destruction

func destroy_matched():
	for i in blocks.size():
		for j in blocks[i].size():
			if blocks[i][j] != null:
				if blocks[i][j].is_matched:
					blocks[i][j].queue_free()
					blocks[i][j] = null

func _on_destroy_timer_timeout():
	destroy_matched()

func _process(delta):
	get_user_touch_input()