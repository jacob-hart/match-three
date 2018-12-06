extends Node2D

enum BlockColor {MAGENTA, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

export (BlockColor) var block_color
export (float) var tween_speed

onready var move_tween = get_node("move_tween")
var is_matched = false
var is_selected = false

# Tweens the block to the target pixel position
func move(position_to_move_to):
	move_tween.interpolate_property(self, "position", position, position_to_move_to, tween_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	move_tween.start()

# All changes to the block that happen when it is in the destruction process go here
func set_matched():
	is_matched = true
	self.scale = Vector2(1.1, 1.1)
	pass

# This is called when the block is selected by the user
func set_selected():
	if !is_selected:
		is_selected = true
		self.scale = Vector2(1.1, 1.1)

# This should do the opposite of set_selected
func set_unselected():
	if is_selected:
		is_selected = false
		self.scale = Vector2(1.0, 1.0)