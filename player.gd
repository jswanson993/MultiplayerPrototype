extends CharacterBody2D

@export var speed = 300.0
@export var max_health = 100.0
var current_health = 0
var client_input := Vector2.ZERO
var current_weapon : Node
var tags = []
signal died(player)

func _ready() -> void:
	# Set starting weapon to hand
	current_weapon = $WeaponPoint/Hand
	current_health = max_health
	# Set camera to player camera
	if name == str(multiplayer.get_unique_id()):
		$Camera2D.make_current() 
	else:
		$Camera2D.enabled = false

func _physics_process(_delta):
	var mouse_position = get_global_mouse_position()
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
		send_rotation_input_to_server.rpc_id(1, mouse_position)

@rpc("any_peer", "call_local", "unreliable_ordered")
func send_input_to_server(input_dir: Vector2):
# Ensure only the server executes movement logic
	if not multiplayer.is_server(): 
		return
		
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	# Server moves the body; Synchronizer replicates the new position
	move_and_slide()

@rpc("any_peer", "call_local", "reliable")
func send_attack_input_to_server(attack_input: float):
	if not multiplayer.is_server():
		return
	if attack_input > 0:
		current_weapon.use()
	
@rpc("any_peer", "call_local", "unreliable")
func send_rotation_input_to_server(mouse_position: Vector2):
	if not multiplayer.is_server():
		return
	look_at(mouse_position)
	
## Picks up item and equips it
func pickup(item: PackedScene):
	if multiplayer.is_server():
		server_pickup.rpc(item.resource_path)

@rpc("authority", "call_local", "reliable")
func server_pickup(item_path: String):
	var item = load(item_path)
	current_weapon.queue_free()
	current_weapon = item.instantiate()
	current_weapon.set_name("weapon")
	$WeaponPoint.add_child(current_weapon)
	
## Reduces health by damage taken. When health hits zero player dies
func take_damage(damage: float):
	current_health -= damage;
	current_health = clamp(0, max_health, current_health)
	if(current_health == 0):
		if multiplayer.is_server():
			died.emit(self)
