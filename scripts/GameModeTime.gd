extends Node2D

export (float) var starting_time = 30
export (int) var places_to_round_to = 0
export (int) var starting_score = 0
export (int) var default_high_score = 10000
export (int) var base_score_for_match = 100

onready var score:int = starting_score
var high_score:int

signal game_mode_time_game_over(final_score, is_new_high_score)
signal game_over_generic
signal score_updated(new_score)
signal high_score_updated(new_high_score)
signal time_updated(new_time)

onready var current_time = starting_time
var is_timer_timed_out = false
var is_timer_paused = false

func _ready():
    high_score = SavedData.get_value(self.name, "high_score", int(default_high_score))
    emit_signal("high_score_updated", int(high_score))
    emit_signal("score_updated", int(score))
    emit_signal("time_updated", current_time)
    Audio.stop_music()
    Audio.play_music("game_mode_time")

func _process(delta):
    if current_time > 0.0 && !is_timer_paused:
        current_time -= delta
        emit_signal("time_updated", get_time_rounded())
    elif current_time <= 0.0 && !is_timer_timed_out:
        is_timer_timed_out = true
        current_time = 0
        pause_timer()
        on_game_over()

func add_time(seconds):
    current_time += seconds

func get_time():
    if current_time < 0.0:
        return 0.0
    return current_time

func get_time_rounded():
    if current_time < 0:
        return 0.0
    return floor(current_time * pow(10.0, places_to_round_to)) / (pow(10.0, places_to_round_to))

func pause_timer():
    is_timer_paused = true

func unpause_timer():
    is_timer_paused = false

func on_game_over():
    if score > high_score:
        SavedData.set_value(self.name, "high_score", int(score))
    emit_signal("game_mode_time_game_over", int(score), score > high_score)
    emit_signal("game_over_generic")

func _on_grid_entered_wait_state():
    pause_timer()
    
func _on_grid_entered_ready_state():
    unpause_timer()

func get_time_weighting(at_time):
    return ((-1.0 / starting_time) * at_time) + 2.0

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
    var match_score = int(get_match_size_weighting(match_size) * get_chain_count_weighting(chain_count) * custom_weighting * get_time_weighting(current_time) * base_score_for_match)
    score += match_score
    emit_signal("score_updated", int(score))
    if score > high_score:
        emit_signal("high_score_updated", int(score))

    var popup_text = load("res://scenes/ScorePopupText.tscn").instance()
    add_child(popup_text)
    popup_text.rect_position = center_position + Vector2(-32, -24)
    popup_text._on_value_source_updated(match_score)
