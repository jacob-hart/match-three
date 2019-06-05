extends CanvasLayer

export (float) var time_between_ticks = 1.0

signal countdown_text_changed(new_value)
signal countdown_started()
signal countdown_finished()

func _ready():
	play_countdown_animation()

func play_countdown_animation():
	emit_signal("countdown_started")
	emit_signal("countdown_text_changed", "3")
	yield(get_tree().create_timer(time_between_ticks), "timeout")
	emit_signal("countdown_text_changed", "2")
	yield(get_tree().create_timer(time_between_ticks), "timeout")
	emit_signal("countdown_text_changed", "1")
	yield(get_tree().create_timer(time_between_ticks), "timeout")
	emit_signal("countdown_text_changed", "GO!")
	emit_signal("countdown_finished")