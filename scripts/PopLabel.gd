extends Label

export (Vector2) var pop_scale = Vector2(2.5, 2.5)
export (float) var pop_time = 0.15
export (float) var fade_out_time = 0.5

onready var pop_tween = get_node("pop_tween")

func set_text(new_text):
	text = new_text
	self.rect_pivot_offset.x = self.rect_size.x / 2.0
	self.rect_pivot_offset.y = self.rect_size.y / 2.0

func pop():
	pop_tween.interpolate_property(self, "rect_scale", self.rect_scale, pop_scale, pop_time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	pop_tween.interpolate_property(self, "rect_scale", pop_scale, Vector2(1.0, 1.0), fade_out_time, Tween.TRANS_QUINT, Tween.EASE_OUT, pop_time)
	pop_tween.start()