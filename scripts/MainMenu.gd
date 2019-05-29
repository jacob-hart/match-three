extends CanvasLayer

func _on_button_play_time_pressed():
	get_tree().change_scene("res://scenes/GameModeTime.tscn")

func _on_button_play_score_pressed():
	print("UNIMPLEMENTED")

func _on_button_quit_pressed():
	get_tree().quit()