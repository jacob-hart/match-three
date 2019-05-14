extends CanvasLayer

func _on_button_resume_pressed():
	print("resumed")

func _on_button_quit_pressed():
	get_tree().quit()

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
        print("tabbed in")
    elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
        print("tabbed out")