extends MultiplayerSynchronizer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		client_process(delta)
func client_process(delta: float) -> void:
	var owner = get_owner()
	if not owner is CharacterBody2D:
		pass
	process_client_movement(owner)
	process_client_rotation(owner)
	
func process_client_movement(owner : Node) -> void:
	var input_dir = %InputSynchronizer.input_direction

	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	
	if direction:
		owner.velocity.x = direction.x * owner.speed
		owner.velocity.y = direction.y * owner.speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.speed)
		owner.velocity.y = move_toward(owner.velocity.y, 0, owner.speed)
		
	owner.move_and_slide()
func process_client_rotation(owner : Node) -> void:
	owner.look_at(%InputSynchronizer.mouse_position)
