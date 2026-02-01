extends Node2D

@onready var player_start_spawner: Node2D = $PlayerStartSpawner
@onready var enemies: Node2D = $Enemies
@onready var bg_music: AudioStreamPlayer = $BGMusic

@export var player_instance: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player: PlayerMovementController = player_instance.instantiate()
	add_child(player)
	
	if Global.current_world_previous_location:
		player.global_position = Global.current_world_previous_location - Vector2(20, 0)
	else:
		player.global_position = player_start_spawner.global_position
	
	if Global.current_enemy_is_defeated:
		
		if enemies.get_children().size() == Global.current_enemy_index and Global.current_world == Global.WORLD.CPU:
			get_tree().change_scene_to_file("res://Scenes/Level/outro_scene.tscn")
		
		for child in enemies.get_children():
			if child.get_index() <= Global.current_enemy_index:
				child.call_deferred("queue_free")
		Global.current_enemy_is_defeated = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bg_music_finished() -> void:
	bg_music.play()
