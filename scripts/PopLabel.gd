extends Label

export (float) var pop_time = 0.1
export (float) var fade_out_time = 0.1
export (bool) var pop_on_value_change = true
export (bool) var pop_on_first_change = false

onready var pop_tween = get_node("pop_tween")

var is_first_change = true

func set_text(new_text):
	text = new_text
	self.rect_pivot_offset.x = self.rect_size.x / 2.0
	self.rect_pivot_offset.y = self.rect_size.y / 2.0
	if pop_on_value_change:
		if !(!pop_on_first_change && is_first_change):
			pop()
	if is_first_change:
		is_first_change = false

func pop(pop_scale = Vector2(1.25, 1.25)):
	pop_tween.interpolate_property(self, "rect_scale", null, pop_scale, pop_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	pop_tween.interpolate_property(self, "rect_scale", pop_scale, Vector2(1.0, 1.0), fade_out_time, Tween.TRANS_QUINT, Tween.EASE_OUT, pop_time)
	pop_tween.start()

func _on_value_source_updated(new_value):
	set_text(String(new_value))