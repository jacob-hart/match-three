extends Node2D

enum BlockColor {MAGENTA, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

export (BlockColor) var block_color
export (float) var move_speed
export (float) var select_speed
export (float) var destroy_speed
export (float) var destroy_delay
export (Vector2) var destroy_scale
export (Vector2) var pressed_scale
export (Vector2) var selected_scale 

onready var move_tween = get_node("move_tween")

onready var select_tween = get_node("select_tween")

onready var destroy_tween = get_node("destroy_tween")

# Tweens the block to the target pixel position
func move_smooth(position_to_move_to):
	move_tween.interpolate_property(self, "position", self.position, position_to_move_to, move_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	move_tween.start()

func move_bounce(position_to_move_to):
	move_tween.interpolate_property(self, "position", self.position, position_to_move_to, move_speed, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	move_tween.start()
	
# All changes to the block that happen when it is in the destruction process go here
func on_matched():
	destroy_tween.interpolate_property(self, "modulate", self.modulate, Color(1.0, 1.0, 1.0, 0.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT, destroy_delay)
	destroy_tween.interpolate_property(self, "scale", self.scale, destroy_scale, destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT, destroy_delay)
	destroy_tween.start()

# This is called when the block is selected but the user has not released the mouse button on it yet
func on_selected_pressed():
	select_tween.interpolate_property(self, "scale", self.scale, pressed_scale, select_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	select_tween.start()

# This is called when the block is selected band the user has released the moused button
func on_selected_released():
	select_tween.interpolate_property(self, "scale", self.scale, selected_scale, select_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	select_tween.start()

# Resets any effects from selection back to normal
func on_unselected():
	select_tween.interpolate_property(self, "scale", self.scale, Vector2(1.0, 1.0), select_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	select_tween.start()