extends CanvasLayer

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_button_play_time_pressed():
	get_tree().change_scene("res://scenes/GameModeTimeAttack.tscn")

func _on_button_play_score_pressed():
	print("UNIMPLEMENTED")
	get_tree().quit()

func _on_button_quit_pressed():
	get_tree().quit()