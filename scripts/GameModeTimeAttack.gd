extends "res://scripts/GameModeScore.gd"

export (float) var starting_time
export (int) var places_to_round_to
export (NodePath) var ui_time_label_path
export (float) var max_time_weight

onready var ui_time_label = get_node(ui_time_label_path)

var current_time
var is_timer_timed_out = false
var is_timer_paused = false

func _ready():
    current_time = starting_time

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

func add_matched_block(match_size, chain_count, custom_weighting = 1.0):
    .add_matched_block(match_size, chain_count, get_time_weighting())
    ui_time_label.pop()

func get_time_weighting():
    return (-1.0 * ((max_time_weight - 1.0) / starting_time)) * current_time + max_time_weight

func on_grid_entered_wait_state():
    pause_timer()
    
func on_grid_entered_ready_state():
    unpause_timer()

func _process(delta):
    if current_time > 0.0 && !is_timer_paused:
        current_time -= delta
    elif current_time <= 0.0 && !is_timer_timed_out:
        is_timer_timed_out = true
        current_time = 0
        pause_timer()
        .on_game_over()

    ui_time_label.set_text("%.1f" % get_time_rounded())
