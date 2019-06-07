extends CanvasLayer

export (float) var time_between_ticks = 1.0

signal countdown_text_changed(new_value)
signal countdown_started()
signal countdown_finished()

func _ready():
	start()

func start():
	get_tree().paused = true
	for child in get_children():
		child.show()
	emit_signal("countdown_started")
	emit_signal("countdown_text_changed", "3")
	Audio.play("notify", "Countdown")
	yield(get_tree().create_timer(time_between_ticks), "timeout")

	emit_signal("countdown_text_changed", "2")
	Audio.play("notify", "Countdown")
	yield(get_tree().create_timer(time_between_ticks), "timeout")

	emit_signal("countdown_text_changed", "1")
	Audio.play("notify", "Countdown")
	yield(get_tree().create_timer(time_between_ticks), "timeout")

	emit_signal("countdown_text_changed", "GO!")
	Audio.play("notify", "Countdown")
	yield(get_tree().create_timer(time_between_ticks), "timeout")

	for child in get_children():
		child.hide()
	emit_signal("countdown_finished")
	get_tree().paused = false