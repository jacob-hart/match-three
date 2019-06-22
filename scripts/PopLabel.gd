extends Label

export (float) var pop_time = 0.075
export (float) var pop_fade_out_time = 0.1
export (bool) var pop_on_value_change = true
export (bool) var pop_on_first_change = false
export (float) var fade_up_and_out_time = 0.35
export (float) var fade_up_and_out_delay = 0.175
export (float) var fade_up_and_out_distance = -25.0
export (bool) var fade_up_and_out_on_value_change = false

onready var pop_tween = get_node("PopTween")
onready var fade_up_and_out_tween = get_node("FadeUpAndOutTween")

var is_first_change = true

func set_text(new_text):
	text = new_text
	self.rect_pivot_offset.x = self.rect_size.x / 2.0
	self.rect_pivot_offset.y = self.rect_size.y / 2.0

func pop(pop_scale = Vector2(1.25, 1.25)):
	pop_tween.interpolate_property(self, "rect_scale", null, pop_scale, pop_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	pop_tween.interpolate_property(self, "rect_scale", pop_scale, Vector2(1.0, 1.0), pop_fade_out_time, Tween.TRANS_QUINT, Tween.EASE_OUT, pop_time)
	pop_tween.start()

func fade_up_and_out():
	pop_tween.interpolate_property(self, "rect_position", null, self.rect_position + Vector2(0.0, fade_up_and_out_distance), fade_up_and_out_time, Tween.TRANS_QUINT, Tween.EASE_IN, fade_up_and_out_delay)
	pop_tween.interpolate_property(self, "modulate", null, Color(self.modulate.r, self.modulate.g, self.modulate.b, 0.0), fade_up_and_out_time, Tween.TRANS_QUINT, Tween.EASE_IN, fade_up_and_out_delay)
	pop_tween.start()

	yield(fade_up_and_out_tween, "tween_completed")
	self.queue_free()

func _on_value_source_updated(new_value):
	if pop_on_value_change:
		if !(!pop_on_first_change && is_first_change):
			if (String(new_value) != text):
				pop()
	if is_first_change:
		is_first_change = false
		if fade_up_and_out_on_value_change:
			fade_up_and_out()

	set_text(String(new_value))