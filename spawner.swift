# spawns players
extends Node3D

@export var PlrScene : PackedScene

func _ready() -> void:
	var index = 0
	for i in GameManager.Players:
		var currentPlr = PlrScene.instantiate()
		currentPlr.name = str(GameManager.Players[i].id)
		currentPlr.set_multiplayer_authority(GameManager.Players[i].id, true)
		add_child(currentPlr)
		
		for spawn in get_tree().get_nodes_in_group("SpawnLocation"):
			if spawn.name == str(index):
				currentPlr.global_position = spawn.global_position
		index += 1
