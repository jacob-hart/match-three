extends Node2D

enum BlockColor {MAGENTA, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

enum SpecialDestroyBehavior {NO_SPECIAL_BEHAVIOR, SQUARE, ROW, COLUMN, CROSS, ALL_OF_SAME_COLOR}

export (BlockColor) var block_color
export (SpecialDestroyBehavior) var special_destroy_behavior = SpecialDestroyBehavior.NO_SPECIAL_BEHAVIOR
export (bool) var is_swappable = true
export (float) var move_speed = 0.3
export (float) var select_speed = 0.1
export (float) var deselect_fade_speed = 0.3
export (float) var destroy_speed = 0.3
export (float) var destroy_fade_delay = 0.1

onready var tween = get_node("Tween")

func move_to_position(position_to_move_to, trans_type = Tween.TRANS_QUINT, ease_type = Tween.EASE_OUT):
	tween.interpolate_property(self, "position", null, position_to_move_to, move_speed, trans_type, ease_type)
	tween.start()
	
func play_entry_animation():
	scale =  Vector2(0.0, 0.0)
	modulate = Color(self.modulate.r, self.modulate.g, self.modulate.b, 0.0)
	#rotation_degrees = rand_range(30, 60)
	tween.interpolate_property(self, "scale", null, Vector2(1.0, 1.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate", null, Color(self.modulate.r, self.modulate.g, self.modulate.b, 1.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	#tween.interpolate_property(self, "rotation_degrees", null, 0.0, destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func play_destroy_animation():
	tween.interpolate_property(self, "scale", null, Vector2(0.0, 0.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate", null, Color(self.modulate.r, self.modulate.g, self.modulate.b, 0.0), destroy_speed - destroy_fade_delay, Tween.TRANS_QUINT, Tween.EASE_OUT, destroy_fade_delay)
	#tween.interpolate_property(self, "rotation_degrees", null, rand_range(30, 60), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func select():
	tween.interpolate_property(get_node("SelectSprite"), "modulate", null, Color(1.0, 1.0, 1.0, 1.0), select_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func deselect():
	tween.interpolate_property(get_node("SelectSprite"), "modulate", null, Color(1.0, 1.0, 1.0, 0.0), deselect_fade_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()