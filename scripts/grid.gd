extends Node2D

export (int) var width_in_blocks
export (int) var height_in_blocks
export (int) var x_start_position
export (int) var y_start_position # TODO make these determined programmatically
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
	print(blocks)
	pass

func make_2D_array():
	var array = []
	for i in width_in_blocks:
		array.append([])
		for j in height_in_blocks:
			array[i].append(null)
	return array


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
