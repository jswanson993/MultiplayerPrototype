class_name exploration_game_mode 
extends "res://GameModes/game_mode.gd"

var free_for_all_scene = preload("res://GameModes/free_for_all_game_mode.tscn")
var base : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base = get_parent()
	get_owner().game_started.connect(on_game_start)
	get_owner().player_joined.connect(on_player_join)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.is_server():
		var formatted_time = get_formatted_time($Timer.time_left)
		update_client_timers.rpc(formatted_time)
		
func clean():
	if multiplayer.is_server():
		remove_client_timers.rpc()

func get_controlled_player() -> CharacterBody2D:
	var peer_id = str(multiplayer.get_unique_id())
	var players = get_tree().get_nodes_in_group("players")
	var matched_players = players.filter(func(player: CharacterBody2D) : return player.name == peer_id)
	if matched_players.size() > 0:
		return matched_players[0]
		
	return null

func get_timer_label() -> Label:
	var player = get_controlled_player()
	if player == null:
		return null
	var time_label = player.get_node("HUD/TimeLabel")
	return time_label

func get_formatted_time(time: float) -> String:
	if not multiplayer.is_server():
		return ""
	var minutes = str(int(time) / 60)
	var seconds = str(int(time) % 60)
	var formated_time = minutes + ":" + seconds
	return formated_time

@rpc("call_local")
func update_client_timers(time: String):
	var timer_label = get_timer_label()
	if timer_label == null: return
	get_timer_label().text = time

func _on_timer_timeout() -> void:
	if not multiplayer.is_server():
		return
	if base.has_method("change_game_mode"):
		base.change_game_mode(free_for_all_scene)

@rpc("call_local")
func add_client_timer():
	var player = get_controlled_player()
	if player == null:
		return
	var ui_container = player.get_node("HUD")
	
	if ui_container.has_node("TimeLabel"):
		return
		
	var timer_label = Label.new()
	timer_label.name = "TimeLabel"
	timer_label.text = "test"
	ui_container.add_child(timer_label)
	timer_label.anchor_left = .5
	
@rpc("any_peer", "call_local", "reliable")
func remove_client_timers():
	var timer_label = get_timer_label()
	if timer_label != null:
		timer_label.queue_free()

func on_game_start() -> void:
	if multiplayer.is_server():
		$Timer.start()

func on_player_join(player : CharacterBody2D) -> void:
	if multiplayer.is_server():
		var peer_id = int(player.name)
		await get_tree().process_frame
		add_client_timer.rpc_id(peer_id)
