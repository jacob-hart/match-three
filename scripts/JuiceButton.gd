extends Button

export (Vector2) var pressed_scale = Vector2(0.95, 0.95)
export (float) var pressed_time = 0.1

export (Vector2) var hover_scale = Vector2(1.05, 1.05)
export (float) var hover_time = 0.1

export (float) var return_to_normal_time = 0.25

onready var tween = get_node("Tween")

func _ready():
	center_pivot()

func _notification(what):
	if what == Control.NOTIFICATION_MOUSE_ENTER || what == Control.NOTIFICATION_FOCUS_ENTER:
		Audio.play("click", "UI")
	elif what == Control.NOTIFICATION_RESIZED:
		center_pivot()

func _process(delta):
	var draw_mode = get_draw_mode()
	match draw_mode:
		DRAW_NORMAL:
			return_to_normal_size()
		DRAW_PRESSED:
			scale(pressed_scale, pressed_time)
		DRAW_HOVER:
			scale(hover_scale, hover_time)

func center_pivot():
	rect_pivot_offset.x = rect_size.x / 2
	rect_pivot_offset.y = rect_size.y / 2

func scale(scale, time):
	if self.rect_scale != scale:
		tween.stop(self)
		tween.interpolate_property(self, "rect_scale", null, scale, time, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.start()

func return_to_normal_size():
	if self.rect_scale != Vector2(1.0, 1.0):
		tween.stop(self)
		tween.interpolate_property(self, "rect_scale", null, Vector2(1.0, 1.0), return_to_normal_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
		tween.start()