class_name Player extends CharacterBody2D

@export var PLAYER_SPEED: float = 10

var movement_lock: bool = false

func get_input() -> void:
	if !movement_lock:
		var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = PLAYER_SPEED * direction
	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
