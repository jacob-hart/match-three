extends Node2D

var file = ConfigFile.new()

func _init():
	var result = file.load("user://SavedData.ini")
	if result == OK:
		print("Successfully loaded config file")
	else:
		print("Error loading config file: ", result)

func get_value(section, key):
	return file.get_value(section, key)

func set_value(section, key, value):
	file.set_value(section, key, value)
	file.save("user://SavedData.ini")

func has_section_key(section, key):
	return file.has_section_key(section, key)