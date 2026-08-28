extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().game_started.connect(on_game_start)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.is_server():
		server_timer_update.rpc($Timer.time_left)
		

@rpc("authority", "call_local", "unreliable")
func server_timer_update(time: float):
	var minutes = str(int(time) / 60)
	var seconds = str(int(time) % 60)
	var formated_time = minutes + ":" + seconds
	$TimeLabel.text =  str(formated_time)


func _on_timer_timeout() -> void:
	if multiplayer.is_server():
		print_debug("Timer finished")

func on_game_start() -> void:
	if multiplayer.is_server():
		$Timer.start()
