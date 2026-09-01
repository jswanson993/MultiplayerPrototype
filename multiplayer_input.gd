extends MultiplayerSynchronizer
 
@export var input_direction = Vector2.ZERO
@export var mouse_position = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		client_process(delta)
		
func client_process(delta: float) -> void:
	mouse_position = get_owner().get_global_mouse_position()
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
func _on_synchronized() -> void:
	pass#print_debug(multiplayer.multiplayer_peer.get_unique_id())
