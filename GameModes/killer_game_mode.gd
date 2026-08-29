class_name killer
extends "res://GameModes/game_mode.gd"
var killer : CharacterBody2D
var bystanders = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	print_debug("Started Killer Game Mode")
	if "player_container" not in get_parent():
		return
	var players = get_parent().player_container.get_children()
	for player in players:
		player.died.connect(on_player_death)
		if "killer" in player.tags:
			self.killer = player
		else:
			bystanders.add(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_player_death(player: CharacterBody2D):
	if not multiplayer.is_server():
		return
	print_debug("player_died")
