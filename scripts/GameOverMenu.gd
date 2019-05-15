extends CanvasLayer

func pause_tree():
	print("paused")
	show()
	get_tree().paused = true

func unpause_tree():
	get_tree().paused = false
	print("unpaused")
	hide()

func hide():
	get_node("MarginContainer").hide()
	get_node("Tint").hide()

func show():
	get_node("MarginContainer").show()
	get_node("Tint").show()

func _on_game_mode_game_over():
	pause_tree()

func _on_button_play_again_pressed():
	unpause_tree()
	get_tree().reload_current_scene()

func _on_button_quit_to_menu_pressed():
	unpause_tree()
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func _on_button_quit_to_desktop_pressed():
	get_tree().quit()

func _ready():
	hide()