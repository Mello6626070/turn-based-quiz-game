extends Node


enum WORLD{
	KEYBOARD,
	MOUSE,
	CAMERA,
	SPEAKER,
	MONITOR,
	PRINTER,
	CPU
}

var current_world: WORLD
var current_world_previous_location: Vector2
var current_enemy_index: int
var current_enemy_data: EnemyType
var current_enemy_is_defeated: bool

var player_class: PlayerClass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
