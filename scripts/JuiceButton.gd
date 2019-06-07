extends Button

export (Vector2) var hover_scale = Vector2(1.05, 1.05)
export (float) var hover_time = 0.25

onready var tween = get_node("Tween")

func _ready():
	center_pivot()

func _notification(what):
	if what == Control.NOTIFICATION_MOUSE_ENTER:
		tween.interpolate_property(self, "rect_scale", null, hover_scale, hover_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.start()
	elif what == Control.NOTIFICATION_MOUSE_EXIT:
		tween.interpolate_property(self, "rect_scale", null, Vector2(1.0, 1.0), hover_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.start()
	elif what == Control.NOTIFICATION_RESIZED:
		center_pivot()

func center_pivot():
	rect_pivot_offset.x = rect_size.x / 2
	rect_pivot_offset.y = rect_size.y / 2