extends Node

@export var player_container : Node2D
var current_game_mode : Node 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_game_mode = get_child(0)

func change_game_mode(new_game_mode_scene: PackedScene):
	if multiplayer.is_server():
		current_game_mode.clean()
		var new_game_mode = new_game_mode_scene.instantiate()
		get_parent().add_child(new_game_mode)
		current_game_mode.call_deferred("queue_free")
		current_game_mode = new_game_mode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
