extends Node2D

enum BlockColor {WHITE, MAGENTA, PINK, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

export (BlockColor) var block_color
export (float) var move_speed
export (float) var select_speed
export (float) var destroy_speed
export (Texture) var destroy_particles_texture
export (Vector2) var pressed_scale
export (Vector2) var selected_scale 

#var destroy_particles_scene = preload("res://scenes/block_destroy_particles.tscn")
var destroy_particles_scene = preload("res://scenes/particles/sparkle_particles.tscn")
var destroy_particles

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
func play_destroy_animation():
	destroy_tween.interpolate_property(self, "scale", self.scale, Vector2(0.0, 0.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	destroy_tween.interpolate_property(self, "modulate", self.modulate, Color(1.0, 1.0, 1.0, 0.0), destroy_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	destroy_tween.start()

	destroy_particles = destroy_particles_scene.instance()
	destroy_particles.set_name("destroy_particles")
	#destroy_particles.texture = destroy_particles_texture
	get_parent().add_child(destroy_particles) # The particles must be added to the parent or otherwise they disappear when the block scene is deinstanced
	destroy_particles.position = self.position
	destroy_particles.emitting = true

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
