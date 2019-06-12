extends VBoxContainer

onready var mute_sound = get_node("SoundContainer/MuteSound")
onready var sound_volume = get_node("SoundContainer/SoundVolume")
onready var mute_music = get_node("MusicContainer/MuteMusic")
onready var music_volume = get_node("MusicContainer/MusicVolume")

func _ready():
	mute_sound.pressed = SavedData.get_value("Settings", "mute_sound", false)
	mute_music.pressed = SavedData.get_value("Settings", "mute_music", false)
	sound_volume.value = SavedData.get_value("Settings", "sound_volume", 0.0)
	music_volume.value = SavedData.get_value("Settings", "music_volume", 0.0)

func _on_mute_sound_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_sound", button_pressed)
	Audio.set_bus_muted("Sound", button_pressed)

func _on_mute_music_button_toggled(button_pressed):
	SavedData.set_value("Settings", "mute_music", button_pressed)
	Audio.set_bus_muted("Music", button_pressed)

func _on_sound_volume_slider_value_changed(value):
	SavedData.set_value("Settings", "sound_volume", value)
	Audio.set_bus_volume("Sound", value)
	Audio.play("click", "UI")

func _on_music_volume_slider_value_changed(value):
	SavedData.set_value("Settings", "music_volume", value)
	Audio.set_bus_volume("Music", value)
	Audio.play("click", "UI")