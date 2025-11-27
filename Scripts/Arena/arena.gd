extends Node2D

enum State{
	PLAYER,
	ENEMY
}

var current_turn: State = State.PLAYER

@onready var arena_player: Control = $CanvasLayer/VBoxContainer/Control/CenterContainer/ArenaPlayer
@onready var arena_enemy: Control = $CanvasLayer/VBoxContainer/Control/CenterContainer2/ArenaEnemy
@onready var timer: Timer = $Timer
@onready var question_container: PanelContainer = $CanvasLayer/VBoxContainer/MarginContainer/QuestionContainer

func _on_arena_player_player_turn_end(damage: float) -> void:
	arena_enemy.take_damage(damage)
	timer.start(2)

func _on_arena_enemy_enemy_turn_end(damage: float) -> void:
	arena_player.take_damage(damage)
	arena_player.start_turn()


func _on_timer_timeout() -> void:
	arena_enemy.start_turn()


func _on_arena_player_mana_refill_request() -> void:
	question_container.show()


func _on_button_pressed() -> void:
	arena_player.player_mana = 100
	arena_player.start_turn()
	question_container.hide()
