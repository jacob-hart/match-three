extends Node2D

const SOUND_VOLUME_DB = -33.0
const MUSIC_VOLUME_DB = -30.0

const SAMPLES = {
	"destroy": preload("res://assets/sounds/chime.wav"),
	"error": preload("res://assets/sounds/close.wav")
}

const MUSIC_TRACKS = {
	"the_hex": preload("res://assets/music/The Hex.wav"),
	"synthwave": preload("res://assets/music/Synthwave 3000.wav")
}

const major_scale = [1.0, 1.122462, 1.259921, 1.334840, 1.498307, 1.681793, 1.887749, 2.0]
const minor_scale = [1.0, 1.059463, 1.189207, 1.334840, 1.414214, 1.587401, 1.781797, 2.0]
const chromatic_scale = [1.0, 1.059463, 1.122462, 1.189207, 1.259921, 1.334840, 1.414214, 1.498307, 1.587401, 1.681793, 1.781797, 1.887749, 2.0]

const POOL_SIZE = 8
var pool = []
var next_player = 0

var music_player

func _ready():
	add_stream_players()
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	set_bus_muted("Sound", SavedData.get_value("Settings", "mute_sound", false))
	set_bus_muted("Music", SavedData.get_value("Settings", "mute_music", false))

func add_stream_players():
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)

func get_next_player_index():
	var next = next_player
	next_player = (next_player + 1) % POOL_SIZE
	return next

func play(sample, bus = "Master"):
	assert(sample in SAMPLES)
	var stream = SAMPLES[sample]
	var index = get_next_player_index()

	var player = pool[index]
	player.stream = stream
	player.volume_db = SOUND_VOLUME_DB
	player.bus = bus
	player.play()

func play_music(track):
	assert(track in MUSIC_TRACKS)
	music_player.stream = MUSIC_TRACKS[track]
	music_player.volume_db = MUSIC_VOLUME_DB
	music_player.bus = "Music"
	music_player.play()

func stop_music():
	music_player.stop()

func set_bus_pitch_by_note(bus, note):
	var pitch_scale = major_scale[clamp(note, 0, major_scale.size() - 1)]
	AudioServer.get_bus_effect(AudioServer.get_bus_index(bus), 0).pitch_scale = pitch_scale

func set_bus_muted(bus, is_muted):
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), is_muted)

func stop_all_players():
	for player in get_children():
		player.stop()