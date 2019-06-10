extends CanvasLayer

export (int) var score_to_display = 0
export (float) var score_tick_time = 1.90

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
	get_node("Shade").hide()

func show():
	get_node("MarginContainer").show()
	get_node("Shade").show()

func _on_game_mode_game_over(final_score, is_new_high_score):
	Audio.stop_music()
	pause_tree()
	Audio.play("impact", "Sound", 10)
	yield(get_tree().create_timer(.85), "timeout")
	if final_score > 0:
		tick_up_score(final_score, is_new_high_score)
		
func tick_up_score(final_score, is_new_high_score):
	get_node("Tween").interpolate_property(self, "score_to_display", null, final_score, score_tick_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	Audio.play("tick_up")
	yield(get_node("Tween"), "tween_completed")
	yield(get_tree().create_timer(.85), "timeout")
	if is_new_high_score:
		get_node("MarginContainer/VBoxContainer/VBoxContainer/FinalScoreText"). _on_value_source_updated("New high score!")
		Audio.play("destroy")
	
func _on_button_play_again_pressed():
	unpause_tree()
	Audio.stop_all_players()
	get_tree().reload_current_scene()

func _on_button_quit_to_menu_pressed():
	Audio.stop_all_players()
	SceneChanger.change_scene("res://scenes/MainMenu.tscn")
	yield(SceneChanger, "about_to_change_scene")
	unpause_tree()

func _on_button_quit_to_desktop_pressed():
	get_tree().quit()

func _ready():
	hide()

func _process(delta):
	get_node("MarginContainer/VBoxContainer/VBoxContainer/FinalScoreValue").set_text(String(int(score_to_display)))