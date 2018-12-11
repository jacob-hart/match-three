extends Node2D

export (int) var initial_score

var _score

func _ready():
	_score =  initial_score

func get_score():
	return _score

func add_score(value_to_add):
	_score += value_to_add
	print_score()

func subtract_score(value_to_subtract):
	if (_score - value_to_subtract >= 0):
		_score -= value_to_subtract
	else:
		print("Score cannot be negative!  Attempted subtraction of ", value_to_subtract, " failed!")

func save_score_to_disk(path):
	pass

func load_score_from_disk(path):
	pass

func print_score():
	print("Current score: ", _score)