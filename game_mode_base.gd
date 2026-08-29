extends Node

@export var player_container : Node2D
var current_game_mode : Node 
@export var chance_to_change = 10
@export var chance_inrease_rate = 10
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

func should_change_game_mode() -> bool:
	var num = randi_range(1, 100)
	print_debug(num)
	var result = num <= chance_to_change
	chance_to_change += chance_inrease_rate
	return result
