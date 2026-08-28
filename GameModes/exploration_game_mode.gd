extends Node

var free_for_all_scene = preload("res://GameModes/free_for_all_game_mode.tscn")
@export var ui_container : Node
var time_label : Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label = Label.new()
	ui_container.add_child(time_label)
	time_label.anchor_top = 0
	time_label.anchor_left = .5
	get_owner().game_started.connect(on_game_start)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.is_server():
		server_timer_update.rpc($Timer.time_left)
		

@rpc("authority", "call_local", "unreliable")
func server_timer_update(time: float):
	var minutes = str(int(time) / 60)
	var seconds = str(int(time) % 60)
	var formated_time = minutes + ":" + seconds
	time_label.text =  str(formated_time)


func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		var free_for_all = free_for_all_scene.instantiate()
		get_parent().add_child(free_for_all)
		server_remove_timer.rpc()
		call_deferred("queue_free")

@rpc("authority", "call_local", "reliable")
func server_remove_timer():
	time_label.queue_free()

func on_game_start() -> void:
	if multiplayer.is_server():
		$Timer.start()
