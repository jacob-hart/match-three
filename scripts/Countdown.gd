extends CanvasLayer

export (float) var time_between_ticks = 1.0
export (float) var fade_time = 0.5

signal countdown_text_changed(new_value)
signal countdown_started()
signal countdown_finished()

onready var tween = get_node("Tween")
onready var children = get_children()

func _ready():
	start()

func start():
	get_tree().paused = true
	for child in children:
		if !(child is Tween):
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

	for child in children:
		if !(child is Tween):
			tween.interpolate_property(child, "modulate", null, Color(child.modulate.r, child.modulate.g, child.modulate.b, 0.0), fade_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	emit_signal("countdown_finished")
	get_tree().paused = false
	yield(tween, "tween_completed")

	for child in children:
		if !(child is Tween):
			child.hide()
