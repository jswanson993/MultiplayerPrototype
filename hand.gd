extends Area2D

@export var is_punching = false
const DAMAGE = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if is_punching and body != get_parent() and multiplayer.is_server():
		request_deal_damage_server.rpc_id(1, body)
		

@rpc("authority", "call_local", "reliable")
func request_deal_damage_server(body: Node2D):
	body.take_damage(DAMAGE)
