extends HBoxContainer

onready var mute_sound = get_node("MuteSound")
onready var mute_music = get_node("MuteMusic")

func _ready():
	mute_sound.pressed = SavedData.get_value("Settings", "mute_sound", false)
	mute_music.pressed = SavedData.get_value("Settings", "mute_music", false)
	Audio.set_bus_muted("Sound", mute_sound.pressed)
	Audio.set_bus_muted("Music", mute_music.pressed)

func _on_mute_sound_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_sound", button_pressed)
	Audio.set_bus_muted("Sound", button_pressed)

func _on_mute_music_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_music", button_pressed)
	Audio.set_bus_muted("Music", button_pressed)
