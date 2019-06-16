extends Node2D

export (int) var starting_score = 0
export (int) var default_high_score = 1000
export (float) var match_size_weighting = 1.0
export (float) var chain_count_weighting = 1.0
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
	
func _on_grid_match_found(match_size, chain_count, custom_weighting):
	score += match_size * match_size_weighting * chain_count * chain_count_weighting * custom_weighting * base_score_for_match
	emit_signal("score_updated", int(score))
	if score > high_score:
		emit_signal("high_score_updated", int(score))
		SavedData.set_value(self.name, "high_score", int(score))