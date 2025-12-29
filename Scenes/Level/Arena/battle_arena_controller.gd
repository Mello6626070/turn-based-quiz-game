extends Node2D

@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy

enum STATE {
	BATTLE_START,
	BATTLE_END_WIN,
	BATTLE_END_LOSS,
	PLAYER_TURN,
	ENEMY_TURN
}

var current_state: STATE

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func set_state(to_state: STATE) -> void:
	match to_state:
		STATE.BATTLE_START: pass

func process_state() -> void:
	pass
