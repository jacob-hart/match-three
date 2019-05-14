extends CanvasLayer

func pause_tree():
	print("paused")
	get_tree().paused = true

func unpause_tree():
	get_tree().paused = false
	print("unpaused")

func _on_button_resume_pressed():
	print("resumed")

func _on_button_quit_to_menu_pressed():
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func _on_button_quit_to_desktop_pressed():
	get_tree().quit()

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
        unpause_tree()
    elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
        pause_tree()