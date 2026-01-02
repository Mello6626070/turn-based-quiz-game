extends Node2D

@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy
@onready var ui: ArenaUI = %UI

@export var skill_list: Array[Skill]

enum STATE {
	BATTLE_START,
	BATTLE_END_WIN,
	BATTLE_END_LOSS,
	PLAYER_TURN,
	PLAYER_SKILL_SELECT,
	PLAYER_QUESTION_HEAL,
	PLAYER_HEAL,
	PLAYER_QUESTION_RESTORE_MANA,
	PLAYER_RESTORE_MANA,
	PLAYER_ATTACK_QUESTION,
	PLAYER_ATTACK,
	PLAYER_TURN_END,
	ENEMY_TURN,
	ENEMY_ATTACK,
	ENEMY_HEAL,
	ENEMY_SKIP,
	ENEMY_TURN_END
}

var current_state: STATE
var previous_state: STATE
var selected_skill: Skill

func _ready() -> void:
	set_state(STATE.BATTLE_START)
	
func _process(delta: float) -> void:
	process_state()

func set_state(to_state: STATE) -> void:
	previous_state = current_state
	current_state = to_state
	match to_state:
		STATE.BATTLE_START: start_battle()
		STATE.PLAYER_TURN: start_player_turn()
		STATE.PLAYER_SKILL_SELECT: start_skill_select()
		STATE.PLAYER_ATTACK_QUESTION: start_question()
		STATE.PLAYER_QUESTION_HEAL: start_question()
		STATE.PLAYER_QUESTION_RESTORE_MANA: start_question()

func process_state() -> void:
	pass

func start_battle() -> void:
	ui.set_player_panel("JESUS", 100, 100)
	ui.set_enemy_panel("CHRIST", 100)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	if rng.randi_range(0, 100) > 50:
		set_state(STATE.PLAYER_TURN)
	else:
		set_state(STATE.ENEMY_TURN)

func player_turn_end() -> void:
	set_state(STATE.ENEMY_TURN)

func enemy_turn_end() -> void:
	set_state(STATE.PLAYER_TURN)

func start_player_turn() -> void:
	ui.show_action_selection_panel()

func start_skill_select() -> void:
	ui.show_skill_selection_panel()
	ui.populate_skill_panel(skill_list)

func start_question() -> void:
	ui.show_questionaire_panel()

func _on_ui_attack_button_pressed() -> void:
	set_state(STATE.PLAYER_SKILL_SELECT)


func _on_ui_restore_health_button_pressed() -> void:
	set_state(STATE.PLAYER_QUESTION_HEAL)


func _on_ui_restore_mana_button_pressed() -> void:
	set_state(STATE.PLAYER_QUESTION_RESTORE_MANA)


func _on_ui_skill_selected(skill: Skill) -> void:
	selected_skill = skill
	set_state(STATE.PLAYER_ATTACK_QUESTION)
