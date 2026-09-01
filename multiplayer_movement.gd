extends MultiplayerSynchronizer

@export var speed = 300

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
	
func process_client_movement(character : CharacterBody2D, input_direction : Vector2) -> void:

	var direction = (Vector2(input_direction.x, input_direction.y)).normalized()
	
	if direction:
		owner.velocity.x = direction.x * owner.speed
		owner.velocity.y = direction.y * owner.speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.speed)
		owner.velocity.y = move_toward(owner.velocity.y, 0, owner.speed)
		
	owner.move_and_slide()
func process_client_rotation(character  : CharacterBody2D, mouse_position : Vector2) -> void:
	character.look_at(mouse_position)
