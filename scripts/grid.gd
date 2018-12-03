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
		if blocks[row - 1][column] != null && blocks[row - 2][column] != null: # Make sure that the color comparisons will be valid
			if blocks[row - 1][column].block_color == block_color && blocks[row - 2][column].block_color == block_color: # Determine if a color match exists # TODO: make it so colorless matches with anything
				return true
	if column >= 2:
		if blocks[row][column - 1] != null && blocks[row][column - 2] != null: # Make sure that the color comparisons will be valid
			if blocks[row][column - 1].block_color == block_color && blocks[row][column - 2].block_color == block_color: # Determine if a color match exists # TODO: make it so colorless matches with anything
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
	
func is_in_grid(row, column):
	return (column >= 0 && column < width_in_blocks && row >= 0 && row < height_in_blocks)

func get_user_touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		touch_begin = get_global_mouse_position()
		var grid_position = pixel_to_grid(touch_begin.x, touch_begin.y)
		if is_in_grid(grid_position.x, grid_position.y):
			is_controlling_block = true

	if Input.is_action_just_released("ui_touch"):
		touch_end = get_global_mouse_position()
		var grid_position = pixel_to_grid(touch_end.x, touch_end.y)
		if is_in_grid(grid_position.x, grid_position.y) && is_controlling_block:
			swap_blocks(pixel_to_grid(touch_begin.x, touch_begin.y), grid_position)
			is_controlling_block = false
	
func swap_blocks(first_block_grid, second_block_grid):
	if first_block_grid.distance_to(second_block_grid) <= 1:
		var first_block = blocks[first_block_grid.x][first_block_grid.y]
		var second_block = blocks[second_block_grid.x][second_block_grid.y]

		blocks[first_block_grid.x][first_block_grid.y] = second_block
		blocks[second_block_grid.x][second_block_grid.y] = first_block

		first_block.move(grid_to_pixel(second_block_grid.x, second_block_grid.y))
		second_block.move(grid_to_pixel(first_block_grid.x, first_block_grid.y))
	
func _process(delta):
	get_user_touch_input()
	