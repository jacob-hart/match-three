extends "res://scripts/GameMode.gd"

export (float) var starting_time
export (int) var places_to_round_to

var current_time
var is_timer_timed_out = false
var is_timer_paused = false

onready var ui_time_label = get_parent().get_node("ui").get_node("time_left")

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

func on_game_over():
    pass

func add_match(blocks_in_match, multiplier = 1.0):
    add_time(blocks_in_match * multiplier)

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
        on_game_over()

    ui_time_label.text = "%.1f" % get_time_rounded()