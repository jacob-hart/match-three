extends CanvasLayer

signal scene_changed

onready var shade = get_node("Shade")
onready var tween = get_node("Tween")

func change_scene(path, transition_time = 0.2, delay = 0.0):
	yield(get_tree().create_timer(delay), "timeout")
	shade.show()
	tween.interpolate_property(shade, "color", null, Color("ff272822"), transition_time / 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT) 
	tween.start()
	yield(tween, "tween_completed")
	assert(get_tree().change_scene(path) == OK)
	tween.interpolate_property(shade, "color", null, Color("00272822"), transition_time / 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	shade.hide()
	emit_signal("scene_changed")