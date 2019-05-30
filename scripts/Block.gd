extends Node2D

enum BlockColor {MAGENTA, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

enum SpecialDestroyBehavior {NO_SPECIAL_BEHAVIOR, SQUARE, ROW, COLUMN, CROSS, ALL_OF_SAME_COLOR}

export (BlockColor) var block_color
export (SpecialDestroyBehavior) var special_destroy_behavior = SpecialDestroyBehavior.NO_SPECIAL_BEHAVIOR
export (bool) var is_swappable = true
export (float) var move_speed
export (float) var select_speed
export (float) var destroy_speed
export (float) var destroy_fade_delay

onready var move_tween = get_node("move_tween")

onready var select_tween = get_node("select_tween")

onready var destroy_tween = get_node("destroy_tween")

func move_smooth(position_to_move_to):
	move_tween.interpolate_property(self, "position", null, position_to_move_to, move_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	move_tween.start()

func move_bounce(position_to_move_to):
	move_tween.interpolate_property(self, "position", null, position_to_move_to, move_speed, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	move_tween.start()
	
# All changes to the block that happen when it is in the destruction process go here
func play_destroy_animation():
	destroy_tween.interpolate_property(self, "scale", null, Vector2(0.0, 0.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	destroy_tween.interpolate_property(self, "modulate", null, Color(1.0, 1.0, 1.0, 0.0), destroy_speed - destroy_fade_delay, Tween.TRANS_QUINT, Tween.EASE_OUT, destroy_fade_delay)
	destroy_tween.start()

func select():
	get_node("SelectSprite").show()

func deselect():
	get_node("SelectSprite").hide()