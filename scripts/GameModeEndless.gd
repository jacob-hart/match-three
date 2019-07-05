extends Node2D

export (int) var starting_score = 0
export (int) var default_high_score = 1000
export (int) var base_score_for_match = 100

onready var score:int = starting_score
var high_score:int

signal score_updated(new_score)
signal high_score_updated(new_high_score)

func _ready():
	high_score = SavedData.get_value(self.name, "high_score", int(default_high_score))
	emit_signal("high_score_updated", int(high_score))
	emit_signal("score_updated", int(score))
	Audio.stop_music()
	Audio.play_music("game_mode_endless")
	
func get_match_size_weighting(match_size):
	match match_size:
		3:
			return 1.0
		4:
			return 2.0
		5: 
			return 4.0

func get_chain_count_weighting(chain_count):
	return 1 + ((chain_count - 1) * 0.25)

func _on_grid_match_found(match_size, chain_count, custom_weighting, center_position):
	var match_score = int(get_match_size_weighting(match_size) * get_chain_count_weighting(chain_count) * custom_weighting * base_score_for_match)
	score += match_score
	emit_signal("score_updated", int(score))
	if score > high_score:
		emit_signal("high_score_updated", int(score))
		SavedData.set_value(self.name, "high_score", int(score))

	var popup_text = load("res://scenes/ScorePopupText.tscn").instance()
	add_child(popup_text)
	popup_text.rect_position = center_position + Vector2(-32, -24)
	popup_text._on_value_source_updated(match_score)