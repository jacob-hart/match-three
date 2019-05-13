extends CanvasLayer

func _on_button_resume_pressed():
	print("resumed")

func _on_button_quit_pressed():
	get_tree().quit()