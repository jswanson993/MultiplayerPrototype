extends Node2D

@export var item: PackedScene

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("pickup"):
		body.pickup(item)
		if multiplayer.is_server():
			request_pickup_server.rpc()
	
@rpc("authority", "call_local", "unreliable")
func request_pickup_server():
	queue_free()
	
	
