extends "res://scripts/GameMode.gd"

export (float) var starting_time
export (int) var places_to_round_to
export (int) var starting_score = 0
export (int) var default_high_score = 1000
export (float) var max_time_weight
export (float) var match_size_weighting = 1.0
export (float) var chain_count_weighting = 1.0
export (int) var base_score_for_match = 100

onready var score:int = starting_score
var high_score:int

signal score_updated(new_score)
signal high_score_updated(new_high_score)
signal time_updated(new_time)

var current_time
var is_timer_timed_out = false
var is_timer_paused = false

func _ready():
    current_time = starting_time
    if SavedData.has_section_key(self.name, "high_score"):
        high_score = SavedData.get_value(self.name, "high_score")
    else:
        high_score = default_high_score
    emit_signal("score_updated", score)
    emit_signal("high_score_updated", high_score)

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
        return 0.00
    return floor(current_time * pow(10.0, places_to_round_to)) / (pow(10.0, places_to_round_to))

func pause_timer():
    is_timer_paused = true

func unpause_timer():
    is_timer_paused = false

func get_time_weighting():
    return (-1.0 * ((max_time_weight - 1.0) / starting_time)) * current_time + max_time_weight

func on_game_over():
    if score > high_score:
        SavedData.set_value(self.name, "high_score", score)
    .on_game_over()

func _on_grid_entered_wait_state():
    pause_timer()
    
func _on_grid_entered_ready_state():
    unpause_timer()

func _on_grid_match_found(match_size, chain_count, custom_weighting):
    score += match_size * match_size_weighting * chain_count * chain_count_weighting * custom_weighting * get_time_weighting() * base_score_for_match
    emit_signal("score_updated", score)
    if score > high_score:
        high_score = score
        emit_signal("high_score_updated", high_score)