extends Node2D

const MIN_DB = -80.0
const SFX_DB = -33.0

const SAMPLES = {
	"destroy": preload("res://assets/sounds/chime.wav"),
	"error": preload("res://assets/sounds/close.wav")
}

const major_scale = [1.0, 1.122462, 1.259921, 1.334840, 1.498307, 1.681793, 1.887749, 2.0]
const minor_scale = [1.0, 1.059463, 1.189207, 1.334840, 1.414214, 1.587401, 1.781797, 2.0]
const chromatic_scale = [1.0, 1.059463, 1.122462, 1.189207, 1.259921, 1.334840, 1.414214, 1.498307, 1.587401, 1.681793, 1.781797, 1.887749, 2.0]

const POOL_SIZE = 8
var pool = []
# Index of the current audio player in the pool.
var next_player = 0

func _ready():
	_init_stream_players()
	set_bus_muted("Sound", SavedData.get_value("Settings", "mute_sound", false))
	set_bus_muted("Music", SavedData.get_value("Settings", "mute_music", false))

func _init_stream_players():
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)

func _get_next_player_idx():
	var next = next_player
	next_player = (next_player + 1) % POOL_SIZE
	return next

func play(sample, bus = "Master"):
	assert(sample in SAMPLES)
	var stream = SAMPLES[sample]
	var idx = _get_next_player_idx()

	var player = pool[idx]
	player.stream = stream
	player.volume_db = SFX_DB
	player.bus = bus
	player.play()

func set_bus_pitch_by_note(bus, note):
	var pitch_scale = major_scale[clamp(note, 0, major_scale.size() - 1)]
	AudioServer.get_bus_effect(AudioServer.get_bus_index(bus), 0).pitch_scale = pitch_scale

func set_bus_muted(bus, is_muted):
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), is_muted)

func stop_all_players():
	for player in get_children():
		player.stop()