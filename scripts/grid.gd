extends Node2D

export (int) var width_in_blocks
export (int) var height_in_blocks

# TODO make these determined programmatically
export (int) var x_start_position
export (int) var y_start_position 
export (int) var offset

var potential_blocks = [
	preload("res://scenes/block_magenta.tscn"),
	preload("res://scenes/block_red.tscn"),
	preload("res://scenes/block_orange.tscn"),
	preload("res://scenes/block_yellow.tscn"),
	preload("res://scenes/block_green.tscn"),
	preload("res://scenes/block_blue.tscn"),
	preload("res://scenes/block_violet.tscn"),
]

var blocks = []

func _ready():
	blocks = make_2D_array()
	populate_grid()
	pass

func make_2D_array():
	var array = []
	for i in width_in_blocks:
		array.append([])
		for j in height_in_blocks:
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
	pass

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


func grid_to_pixel(column, row):
	var new_x = x_start_position + offset * column
	var new_y = y_start_position + offset * row
	return Vector2(new_x, new_y)

# func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
