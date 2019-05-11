extends Node2D

func _process(delta):
	if Input.is_action_just_released("pause"):
		if (get_tree().paused):
			get_tree().paused = false
			print("Just unpaused!")
		else:
			print("Just paused!")
			get_tree().paused = true
