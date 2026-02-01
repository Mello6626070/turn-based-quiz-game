class_name PlayerEnemyEncounter extends Node2D

@export var enemy_data: EnemyType
@export var line: String
@export var index: int

@onready var sprite_container: Node2D = %SpriteContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_enemy_sprite()

func init_enemy_sprite() -> void:
	var scene: PackedScene = enemy_data.scene
	var instance: Node2D = scene.instantiate()
	sprite_container.add_child(instance)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_player_detector_body_entered(body: Node2D) -> void:
	Global.current_world_previous_location = body.global_position
	Global.current_enemy_data = enemy_data
	Global.current_enemy_index = index
	get_tree().change_scene_to_file("res://Scenes/Level/Arena/battle_arena.tscn")
