extends "res://scripts/GameMode.gd"

export (int) var starting_score = 0
export (NodePath) var ui_score_label_path
export (float) var match_size_weighting = 1.0
export (float) var chain_count_weighting = 1.0
export (int) var base_score_for_match = 100

onready var ui_score_label = get_node(ui_score_label_path)

var score : int = 0

func on_game_over():
	print("FINAL SCORE: ", score)
	.on_game_over()

func add_matched_block(match_size, chain_count, custom_weighting = 1.0):
	score += ((match_size * match_size_weighting) * (chain_count * chain_count_weighting)) * custom_weighting * base_score_for_match
	ui_score_label.pop()

func _process(delta):
	ui_score_label.set_text(String(score))