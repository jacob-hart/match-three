extends Node2D

export (int) var width_in_blocks
export (int) var height_in_blocks

var potential_blocks = [
	preload("res://scenes/block_magenta.tscn"),
	preload("res://scenes/block_red.tscn"),
	preload("res://scenes/block_orange.tscn"),
	preload("res://scenes/block_yellow.tscn"),
	preload("res://scenes/block_green.tscn"),
	preload("res://scenes/block_blue.tscn"),
	preload("res://scenes/block_violet.tscn"),
]

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
