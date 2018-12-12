extends "res://scripts/GameMode.gd"

export (float) var starting_time

onready var timer = get_node("timer")

func _ready():
    timer.wait_time = starting_time
    timer.start()

func add_time(seconds):
    pass

func pause_timer():
    timer.paused = true

func unpause_timer():
    timer.paused = false

func on_game_over():
    pass

func _on_timer_timeout():
    on_game_over()
    print("TIMER TIMED OUT!")

func _process(delta):
    if (Engine.get_frames_drawn() % 60 == 0):
        print("CURRENT TIMER TIME: ", timer.time_left)