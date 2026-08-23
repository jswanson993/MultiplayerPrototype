extends CharacterBody2D

const SPEED = 300.0
const  MAX_HEALTH = 100.0
var current_health = 0
var client_input := Vector2.ZERO

func _ready() -> void:
	current_health = MAX_HEALTH

func _physics_process(_delta):
# Check if this client actually owns this player node
	if multiplayer.get_unique_id() == str(name).to_int():
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var attack_input = Input.get_action_strength("ui_attack")
		
		if(input_dir != Vector2(0, 0)):
			pass	
		if(attack_input != 1):
			pass
		# Send input directly to the server (peer id 1)
		send_input_to_server.rpc_id(1, input_dir)
		send_attack_input_to_server.rpc_id(1, attack_input)

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
		
@rpc("any_peer", "call_local", "reliable")
func send_attack_input_to_server(attack_input: float):
	if not multiplayer.is_server():
		return
	if attack_input > 0:
		$AnimationPlayer.play("punch")
		
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

func take_damage(damage: float):
	print_debug("Taking Damage")
	current_health -= damage;
	current_health = clamp(0, MAX_HEALTH, current_health)
	if(current_health == 0):
		print_debug("Player Dead")
	
