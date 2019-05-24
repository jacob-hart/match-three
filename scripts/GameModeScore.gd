extends "res://scripts/GameMode.gd"

export (float) var starting_score = 0
export (NodePath) var ui_score_label_path

onready var ui_score_label = get_node(ui_score_label_path)

var score = 0

func on_game_over():
	print("FINAL SCORE: ", score)
	.on_game_over()

func add_matched_block(match_size, chain_count, custom_weighting = 1.0):
	print("Add score for size ", match_size, ", chain ", chain_count, " and weight ", custom_weighting)
	ui_score_label.pop()

func _process(delta):
	ui_score_label.set_text(String(score))