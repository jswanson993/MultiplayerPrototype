extends Node

var players = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not multiplayer.is_server():
		return
	if "player_container" not in get_parent():
		return
	players = get_parent().player_container.get_children()
	for player in players:
		player.died.connect(on_player_death)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_player_death(player):
	if not multiplayer.is_server():
		return
	var player_index = players.find(player)
	players.remove_at(player_index)
	if players.size() == 1:
		print_debug("Player: " + str(players[0]) + " won")
