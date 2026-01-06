extends Node2D

@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy
@onready var ui: ArenaUI = %UI

@export var player_class: PlayerClass
@export var enemy_type: EnemyType
@export var transition_duration: float = 0.8

@onready var state_transition_timer: Timer = %StateTransitionTimer

@onready var state_debug_label: Label = %StateDebugLabel

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
	PLAYER_QUESTION_TIMEOUT,
	PLAYER_TURN_END,
	ENEMY_TURN,
	ENEMY_ATTACK,
	ENEMY_HEAL,
	ENEMY_SKIP,
	ENEMY_TURN_END,
	STATE_TRANSITION
}

var current_state: STATE
var previous_state: STATE
var target_state: STATE
var selected_skill: Skill
var current_answer: CurrentAnswer

var player_health: float
var player_mana: float
var player_name: String = "YOU"
var player_sprite_instance: ClassVisual

var enemy_health: float = 100
var enemy_name: String
var enemy_current_attack_damage: float
var enemy_sprite_instance: EnemyVisual

func _ready() -> void:
	set_state(STATE.BATTLE_START)
	
func _process(delta: float) -> void:
	process_state()

func set_state(to_state: STATE) -> void:
	previous_state = current_state
	current_state = to_state
	
	match current_state:
		STATE.BATTLE_START:
			print("Battle Start")
			start_battle()
		STATE.PLAYER_TURN: 
			ui.show_context_panel("YOUR TURN")
			start_player_turn()
			print("Player Turn")
		STATE.PLAYER_SKILL_SELECT:
			start_skill_select()
			print("Skill Select")
		STATE.PLAYER_ATTACK_QUESTION: 
			start_question()
			print("Player Attack Question")
		STATE.PLAYER_ATTACK:
			ui.show_context_panel("ATTACKS THE ENEMY")
			start_attack()
		STATE.PLAYER_QUESTION_HEAL: 
			start_question()
			print("Player Heal Question")
		STATE.PLAYER_HEAL:
			ui.show_context_panel("HEALS YOURSELF")
			start_heal()
		STATE.PLAYER_QUESTION_RESTORE_MANA:
			start_question()
			print("Player Restore Mana Question")
		STATE.PLAYER_RESTORE_MANA:
			ui.show_context_panel("MANA RESTORED")
			start_restore_mana()
		STATE.PLAYER_TURN_END: 
			print("Player End Turn")
			player_turn_end()
		STATE.ENEMY_TURN:
			ui.show_context_panel("ENEMY'S TURN")
			print("Enemy Turn") 
			start_enemy_turn()
		STATE.ENEMY_ATTACK:
			ui.show_context_panel("ENEMY ATTACKS") 
			print("Enemy Attack")
			start_enemy_attack()
		STATE.ENEMY_HEAL: 
			ui.show_context_panel("ENEMY HEALS")
			print("Enemy Heal")
			start_enemy_heal()
		STATE.ENEMY_SKIP:
			ui.show_context_panel("ENEMY SKIPS TURN")
			start_enemy_skip()
		STATE.ENEMY_TURN_END:
			ui.show_context_panel("YOUR TURN")
			print("Enemy Turn End")
			enemy_turn_end()
		STATE.STATE_TRANSITION:
			state_transition()
		STATE.PLAYER_QUESTION_TIMEOUT:
			start_time_out()

func process_state() -> void:
	pass

func start_battle() -> void:
	init_player()
	init_enemy()
	ui.show_context_panel("BATTLE START")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	if rng.randi_range(0, 100) > 69:
		target_state = STATE.PLAYER_TURN
		set_state(STATE.STATE_TRANSITION)
	else:
		target_state = STATE.ENEMY_TURN
		set_state(STATE.STATE_TRANSITION)

func init_player() -> void:
	var skill_list: Array[Skill]
	var player_scene: PackedScene = player_class.class_scene
	player_sprite_instance = player_scene.instantiate()
	player.add_child(player_sprite_instance)
	player_sprite_instance.start_animation("idle")
	player_sprite_instance.animation_finished.connect(player_animation_finished)
	player_sprite_instance.hurt_enemy.connect(hurt_enemy)
	player_health = player_class.default_hp
	player_mana = player_class.default_mana
	ui.set_player_panel(player_name, player_health, player_mana)
	skill_list.append(player_class.skill1)
	skill_list.append(player_class.skill2)
	skill_list.append(player_class.skill3)
	ui.populate_skill_panel(skill_list)

func init_enemy() -> void:
	var enemy_scene: PackedScene = enemy_type.scene
	enemy_sprite_instance = enemy_scene.instantiate()
	enemy.add_child(enemy_sprite_instance)
	enemy_sprite_instance.start_animation("idle")
	enemy_sprite_instance.enemy_animation_finished.connect(enemy_animation_finished)
	enemy_sprite_instance.hurt_player.connect(hurt_player)
	enemy_health = enemy_type.health
	enemy_name = enemy_type.name
	ui.set_enemy_panel(enemy_name, enemy_health)

func player_turn_end() -> void:
	target_state = STATE.ENEMY_TURN
	set_state(STATE.STATE_TRANSITION)

func enemy_turn_end() -> void:
	target_state = STATE.PLAYER_TURN
	set_state(STATE.STATE_TRANSITION)

func start_player_turn() -> void:
	ui.show_action_selection_panel()

func start_skill_select() -> void:
	ui.show_skill_selection_panel()

func start_question() -> void:
	ui.show_questionaire_panel()

func start_heal() -> void:
	player_health += player_class.default_heal / current_answer.modifier
	if player_health > player_class.default_hp:
		player_health = player_class.default_hp
	ui.update_player_bar(player_health, player_mana)
	target_state = STATE.PLAYER_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_restore_mana() -> void:
	player_mana += player_class.default_mana_restore / current_answer.modifier
	if player_mana > player_class.default_mana:
		player_mana = player_class.default_mana
	ui.update_player_bar(player_health, player_mana)
	target_state = STATE.PLAYER_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_attack() -> void:
	player_mana -= selected_skill.mana_cost
	if player_mana <= 0:
		player_mana = 0
	ui.update_player_bar(player_health, player_mana)
	player_sprite_instance.start_animation(selected_skill.animation_name)

func start_enemy_turn() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var weight_total: int = enemy_type.heal_weight + enemy_type.heavy_attack_weight + enemy_type.light_attack_weight + enemy_type.skip_weight
	rng.seed = Time.get_ticks_msec()
	var magic_number: int = rng.randi_range(0, weight_total)
	if magic_number <= enemy_type.heal_weight:
		target_state = STATE.ENEMY_HEAL
		set_state(STATE.STATE_TRANSITION)
	elif magic_number > enemy_type.heal_weight and magic_number <= enemy_type.heal_weight + enemy_type.heavy_attack_weight + enemy_type.light_attack_weight:
		target_state = STATE.ENEMY_ATTACK
		set_state(STATE.STATE_TRANSITION)
	else:
		target_state = STATE.ENEMY_SKIP
		set_state(STATE.STATE_TRANSITION)

func start_enemy_heal() -> void:
	enemy_health += enemy_type.heal
	if enemy_health > enemy_type.health:
		enemy_health = enemy_type.health
	ui.update_enemy_bar(enemy_health)
	target_state = STATE.ENEMY_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_enemy_skip() -> void:
	target_state = STATE.ENEMY_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_time_out() -> void:
	ui.show_context_panel("RAN OUT OF TIME")
	target_state = STATE.PLAYER_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_enemy_attack() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_msec()
	var weight_total: int = enemy_type.light_attack_damage + enemy_type.heavy_attack_damage
	var magic_number: int = rng.randi_range(0, weight_total)
	if magic_number < enemy_type.light_attack_weight:
		enemy_current_attack_damage = enemy_type.light_attack_damage
		enemy_sprite_instance.start_animation("light_attack")
	else:
		enemy_current_attack_damage = enemy_type.heavy_attack_damage
		enemy_sprite_instance.start_animation("heavy_attack")

func _on_ui_attack_button_pressed() -> void:
	set_state(STATE.PLAYER_SKILL_SELECT)


func _on_ui_restore_health_button_pressed() -> void:
	set_state(STATE.PLAYER_QUESTION_HEAL)


func _on_ui_restore_mana_button_pressed() -> void:
	set_state(STATE.PLAYER_QUESTION_RESTORE_MANA)


func _on_ui_skill_selected(skill: Skill) -> void:
	selected_skill = skill
	if selected_skill.mana_cost > player_mana:
		ui.show_context_panel("NOT ENOUGH MANA")
		target_state = STATE.PLAYER_TURN
		set_state(STATE.STATE_TRANSITION)
		return
	set_state(STATE.PLAYER_ATTACK_QUESTION)

func player_animation_finished(animation: String) -> void:
	if !animation == "hurt":
		target_state = STATE.PLAYER_TURN_END
		set_state(STATE.STATE_TRANSITION)
	player_sprite_instance.start_animation("idle")

func enemy_animation_finished(animation: String) -> void:
	if !animation == "hurt":
		target_state = STATE.ENEMY_TURN_END
		set_state(STATE.STATE_TRANSITION)
	enemy_sprite_instance.start_animation("idle")

func hurt_player() -> void:
	player_health -= enemy_current_attack_damage
	player_sprite_instance.start_animation("hurt")
	ui.update_player_bar(player_health, player_mana)

func hurt_enemy() -> void:
	var damage: float = float(selected_skill.damage) / float(selected_skill.burst_number) / current_answer.modifier
	enemy_sprite_instance.start_animation("hurt")
	enemy_health -= damage
	ui.update_enemy_bar(enemy_health)


func _on_questionaire_panel_answered(is_correct: bool, modifier: float) -> void:
	print("answered")
	ui.questionaire_panel.hide()
	current_answer = CurrentAnswer.new(is_correct, modifier)
	match current_state:
		STATE.PLAYER_ATTACK_QUESTION:
			target_state = STATE.PLAYER_ATTACK
			set_state(STATE.STATE_TRANSITION)
		STATE.PLAYER_QUESTION_HEAL:
			target_state = STATE.PLAYER_HEAL
			set_state(STATE.STATE_TRANSITION)
		STATE.PLAYER_QUESTION_RESTORE_MANA:
			target_state = STATE.PLAYER_RESTORE_MANA
			set_state(STATE.STATE_TRANSITION)

class CurrentAnswer:
	var is_correct: bool
	var modifier: float
	func _init(correct: bool, mod: float) -> void:
		is_correct = correct
		modifier = mod

func state_transition() -> void:
	if previous_state == STATE.BATTLE_START:
		state_transition_timer.start(1)
	else:
		state_transition_timer.start(transition_duration)

func _on_state_transition_timer_timeout() -> void:
	set_state(target_state)


func _on_questionaire_panel_question_time_out() -> void:
	if current_state == STATE.PLAYER_QUESTION_HEAL or current_state == STATE.PLAYER_QUESTION_RESTORE_MANA or current_state == STATE.PLAYER_ATTACK_QUESTION:
		set_state(STATE.PLAYER_QUESTION_TIMEOUT)
