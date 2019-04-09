extends Label

export (Vector2) var pop_scale = Vector2(1.25, 1.25)
export (float) var pop_time = 0.5


func set_text(new_text):
	text = new_text

func pop():
	pass
	#get_node("tween").interpolate_property(self, "scale", self.scale, pop_scale, pop_time / 2, Tween.TRANS_QUINT, Tween.EASE_OUT)
	#get_node("tween").interpolate_property(self, "scale", self.scale, Vector2(1.0, 1.0), pop_time / 2, Tween.TRANS_QUINT, Tween.EASE_OUT, pop_time / 2)