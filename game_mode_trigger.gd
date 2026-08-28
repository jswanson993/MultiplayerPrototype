extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().on_pickup.connect(on_pickup_triggered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_pickup_triggered():
	print_debug("triggered")
