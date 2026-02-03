extends Node2D
@onready var player_spawner: Node2D = $PlayerSpawner
@onready var enemies: Node2D = $Enemies
@onready var bg_music: AudioStreamPlayer = $BGMusic

@export var player_instance: PackedScene
var player: PlayerMovementController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = player_instance.instantiate()
	add_child(player)
	if Global.current_world_previous_location:
		if Global.current_world == Global.WORLD.MOUSE:
			player.global_position = Global.current_world_previous_location + Vector2(50, 0)
		elif Global.current_world == Global.WORLD.PRINTER:
			player.global_position = Global.current_world_previous_location + Vector2(-50, 0)
	else:
		player.global_position = player_spawner.global_position
	
	if Global.current_enemy_is_defeated:
		for child in enemies.get_children():
			if child.get_index() <= Global.current_enemy_index:
				child.call_deferred("queue_free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bg_music_finished() -> void:
	bg_music.play()
