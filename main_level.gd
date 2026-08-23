extends Node2D

var peer = ENetMultiplayerPeer.new()
var player_scene = preload("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Host.pressed.connect(host_game)
	$Join.pressed.connect(join_game)

func host_game():
	peer.create_server(8910)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(spawn_player)
	spawn_player(1)
	hide_buttons()
	
func join_game():
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	hide_buttons()
	
func spawn_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	get_node("Players").add_child(player)
	
func hide_buttons():
	$Host.hide()
	$Join.hide()
