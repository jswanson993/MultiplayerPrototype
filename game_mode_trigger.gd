extends Node


@export var game_mode_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().on_pickup.connect(on_pickup_triggered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_pickup_triggered():

	print_debug("triggered")
	trigger_game_mode_change()

func trigger_game_mode_change():
	if not multiplayer.is_server():
		return
	var game_mode_base = get_tree().get_first_node_in_group("game_mode_manager")
	if game_mode_base.has_method("change_game_mode"):
		game_mode_base.change_game_mode(game_mode_scene)
