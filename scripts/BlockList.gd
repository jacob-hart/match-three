extends Resource

export (Array, PackedScene) var filler

export (Array, PackedScene) var special
export (Array, float) var special_spawn_chance

func _ready():
    assert(special.size() == special_spawn_chance.size())