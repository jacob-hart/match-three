extends TextureButton

export (Vector2) var hover_scale = Vector2(1.1, 1.1)
export (float) var hover_time = 0.1

onready var tween = get_node("Tween")

func _ready():
	center_pivot()

func _notification(what):
	if what == Control.NOTIFICATION_MOUSE_ENTER || what == Control.NOTIFICATION_FOCUS_ENTER:
		expand(hover_scale, hover_time)
	elif what == Control.NOTIFICATION_MOUSE_EXIT || what == Control.NOTIFICATION_FOCUS_EXIT:
		return_to_normal_size()
	elif what == Control.NOTIFICATION_RESIZED:
		center_pivot()

func center_pivot():
	rect_pivot_offset.x = rect_size.x / 2
	rect_pivot_offset.y = rect_size.y / 2

func expand(scale, time):
	Audio.play("click", "UI")
	tween.interpolate_property(self, "rect_scale", null, scale, time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func return_to_normal_size():
	tween.interpolate_property(self, "rect_scale", null, Vector2(1.0, 1.0), hover_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()