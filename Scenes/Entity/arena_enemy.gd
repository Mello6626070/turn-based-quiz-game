extends Control

signal enemy_turn_end(damage: float)

@onready var health_bar: ProgressBar = $HealthBar


var enemy_health: float = 100

func _process(delta: float) -> void:
	health_bar.value = enemy_health

func take_damage(damage: float) -> void:
	enemy_health -= damage

func start_turn() -> void:
	var damage: float = randf_range(5, 15)
	end_turn(damage)

func end_turn(damage: float) -> void:
	enemy_turn_end.emit(damage)
