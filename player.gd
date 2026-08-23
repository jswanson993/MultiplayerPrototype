extends CharacterBody2D

const SPEED = 300.0
var client_input := Vector2.ZERO

func _physics_process(_delta):
# Check if this client actually owns this player node
	if multiplayer.get_unique_id() == str(name).to_int():
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if(input_dir != Vector2(0, 0)):
			pass
		# Send input directly to the server (peer id 1)
		send_input_to_server.rpc_id(1, input_dir)

@rpc("any_peer", "call_local", "unreliable_ordered")
func send_input_to_server(input_dir: Vector2):
# Ensure only the server executes movement logic
	if not multiplayer.is_server(): 
		return
		
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Server moves the body; Synchronizer replicates the new position
	move_and_slide()
		
const PICKUP_RANGE = 50.0
var inventory: Array[String] = []

func attempt_pickup(item: Node2D):
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		return
		
	if global_position.distance_to(item.global_position) <= PICKUP_RANGE:
		inventory.append(item.name)
		item.queue_free()

@rpc("any_peer", "call_local", "reliable")
func request_pickup_server(item_path: NodePath):
	var sender = multiplayer.get_remote_sender_id()
	
	if sender !=0 or str(sender) != name:
		return
	
	var item = get_node_or_null(item_path)
	
	if item != null and item is Node2D:
		attempt_pickup(item)
