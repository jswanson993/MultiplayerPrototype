extends Node

var player_scene = preload("res://player.tscn")

func _ready():
	print("--- Starting TDD Suite ---")
	test_initial_input_is_zero()
	test_rpc_updates_server_input()
	test_pickup_in_range()
	test_pickup_out_of_range()
	test_rpc_pickup_request()
	print("--- Tests Passed ---")
	get_tree().quit()
var player;
func setup():
	player = player_scene.instanciate()
	
func base_rpc_setup():
	player.name="2"
	# Node must be in the tree to use Godot's multiplayer API
	add_child(player)
	
func tear_down():
	player.queue_free()

func test_initial_input_is_zero():
	setup()
	assert(player.client_input == Vector2.ZERO, "Fail: Player input did not start at 0,0")
	tear_down()
	

func test_rpc_updates_server_input():
	setup()
	base_rpc_setup()
	
	player.send_input_to_server(Vector2.RIGHT)
	
	assert(player.client_input == Vector2.RIGHT, "Fail: RPC failed")
	tear_down()

func test_pickup_in_range():
	var player = player_scene.instantiate()
	var item = Node2D.new() 
	item.name = "Flashlight"
	
	add_child(player)
	add_child(item)
	
	player.global_position = Vector2.ZERO
	item.global_position = Vector2(10, 0) 
	
	player.attempt_pickup(item)
	
	assert(player.inventory.has("Flashlight"), "Fail: Item not added to inventory")
	assert(item.is_queued_for_deletion(), "Fail: Item was not destroyed")
	
	player.queue_free()

func test_pickup_out_of_range():
	var player = player_scene.instantiate()
	var item = Node2D.new()
	item.name = "Key"
	
	add_child(player)
	add_child(item)
	
	player.global_position = Vector2.ZERO
	item.global_position = Vector2(100, 0) 
	
	player.attempt_pickup(item)
	
	assert(not player.inventory.has("Key"), "Fail: Out of range item added to inventory")
	assert(not item.is_queued_for_deletion(), "Fail: Item destroyed when out of range")
	
	player.queue_free()
	item.queue_free()
	
func test_rpc_pickup_request():
	var player = player_scene.instanciate()
	player.name = "2"
	var item = Node2D.new()
	item.name = "Map"
	
	add_child(player)
	add_child(item)
	
	
