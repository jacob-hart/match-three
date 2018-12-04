extends Node2D

enum BlockColor {MAGENTA, RED, ORANGE, YELLOW, GREEN, BLUE, VIOLET, COLORLESS}

export (BlockColor) var block_color
export (float) var tween_speed

var move_tween
var is_matched = false

func _ready():
	move_tween = get_node("move_tween")

func move(position_to_move_to):
	move_tween.interpolate_property(self, "position", position, position_to_move_to, tween_speed, Tween.TRANS_QUINT, Tween.EASE_OUT)
	move_tween.start()

func _process(delta):
	pass

func change_opacity():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1, 1, 1, 0.5)
