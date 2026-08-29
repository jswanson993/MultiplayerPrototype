class_name exploration_game_mode 
extends "res://GameModes/game_mode.gd"

var free_for_all_scene = preload("res://GameModes/free_for_all_game_mode.tscn")
var time_label : Label
var base : Node
var ui_container : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base = get_parent()
	ui_container = get_tree().get_first_node_in_group("ui")
	time_label = Label.new()
	ui_container.add_child(time_label)
	time_label.anchor_top = 0
	time_label.anchor_left = .5
	get_owner().game_started.connect(on_game_start)

	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.is_server():
		server_timer_update.rpc($Timer.time_left)
		
func clean():
	server_remove_timer()

@rpc("authority", "call_local", "unreliable")
func server_timer_update(time: float):
	var minutes = str(int(time) / 60)
	var seconds = str(int(time) % 60)
	var formated_time = minutes + ":" + seconds
	time_label.text =  str(formated_time)

func _on_timer_timeout() -> void:
	if not multiplayer.is_server():
		return
	if base.has_method("change_game_mode"):
		base.change_game_mode(free_for_all_scene)
	
@rpc("authority", "call_local", "reliable")
func server_remove_timer():
	time_label.queue_free()

func on_game_start() -> void:
	if multiplayer.is_server():
		$Timer.start()
