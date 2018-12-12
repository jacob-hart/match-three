extends "res://scripts/GameMode.gd"

export (float) var starting_time

var current_time
var is_timer_timed_out = false
var is_timer_paused = false

func _ready():
    current_time = starting_time

func add_time(seconds):
    current_time += seconds

func get_time():
    return current_time

func pause_timer():
    is_timer_paused = true

func unpause_timer():
    is_timer_paused = false

func on_game_over():
    pass

func _process(delta):
    if current_time > 0 && !is_timer_paused:
        current_time -= delta
    elif current_time <= 0 && !is_timer_timed_out:
        is_timer_timed_out = true
        current_time = 0
        pause_timer()
        on_game_over()