extends CanvasLayer

func _ready():
	Audio.play_music("main_menu")

func _on_button_play_time_pressed():
	SceneChanger.change_scene("res://scenes/GameModeTime.tscn")

func _on_button_quit_pressed():
	get_tree().quit()