extends VBoxContainer

onready var mute_sound = get_node("HBoxContainer/MuteSound")
onready var mute_music = get_node("HBoxContainer/MuteMusic")
onready var master_volume = get_node("MasterVolume")

func _ready():
	mute_sound.pressed = SavedData.get_value("Settings", "mute_sound", false)
	mute_music.pressed = SavedData.get_value("Settings", "mute_music", false)
	master_volume.value = SavedData.get_value("Settings", "master_volume", 0.0)

func _on_mute_sound_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_sound", button_pressed)
	Audio.set_bus_muted("Sound", button_pressed)

func _on_mute_music_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_music", button_pressed)
	Audio.set_bus_muted("Music", button_pressed)

func _on_master_volume_slider_value_changed(value):
	SavedData.set_value("Settings", "master_volume", value)
	Audio.set_bus_volume("Master", value)
	Audio.play("click", "UI")