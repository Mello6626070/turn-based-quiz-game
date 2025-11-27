extends Control

signal player_turn_end(damage: float)
signal mana_refill_request()

var player_health: float = 100
var player_mana: float = 100

@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $Mana
@onready var action_options: VBoxContainer = $ActionOptions
@onready var skill_options: HBoxContainer = $SkillOptions

func _ready() -> void:
	start_turn()

func _process(delta: float) -> void:
	mana_bar.value = player_mana
	health_bar.value = player_health

func start_turn() -> void:
	action_options.show()

func _on_attack_button_pressed() -> void:
	skill_selection()


func _on_use_items_button_pressed() -> void:
	pass # Replace with function body.


func _on_flee_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Worlds/test_world.tscn")

func skill_selection() -> void:
	action_options.hide()
	skill_options.show()

func end_turn(damage: float):
	player_turn_end.emit(damage)


func _on_skill_1_pressed() -> void:
	if player_mana < 20:
		mana_refill_request.emit()
	else:
		end_turn(5)
		player_mana -= 20
	skill_options.hide()


func _on_skill_2_pressed() -> void:
	if player_mana < 40:
		mana_refill_request.emit()
	else:
		end_turn(10)
		player_mana -= 40
	skill_options.hide()


func _on_skill_3_pressed() -> void:
	if player_mana < 80:
		mana_refill_request.emit()
	else:
		end_turn(20)
		player_mana -= 80
	skill_options.hide()

func take_damage(damage: float) -> void:
	player_health -= damage
