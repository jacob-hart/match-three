extends CanvasLayer

signal about_to_change_scene
signal scene_changed

onready var shade = get_node("Shade")
onready var tween = get_node("Tween")

var bar_color = preload("res://assets/textures/empty_bg.png")
func _ready():
	VisualServer.black_bars_set_images(bar_color.get_rid(), bar_color.get_rid(), bar_color.get_rid(), bar_color.get_rid())

func change_scene(path, transition_time = 0.2, delay = 0.0):
	yield(get_tree().create_timer(delay), "timeout")
	shade.show()
	tween.interpolate_property(shade, "color", null, Color(shade.color.r, shade.color.g, shade.color.b, 1.0), transition_time / 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT) 
	tween.start()
	yield(tween, "tween_completed")
	emit_signal("about_to_change_scene")
	assert(get_tree().change_scene(path) == OK)
	tween.interpolate_property(shade, "color", null, Color(shade.color.r, shade.color.g, shade.color.b, 0.0), transition_time / 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	shade.hide()
	emit_signal("scene_changed")