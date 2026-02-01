extends Node2D

@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy
@onready var ui: ArenaUI = %UI
@onready var button_sfx: AudioStreamPlayer = %ButtonSFX
@onready var restore: AudioStreamPlayer = $Restore
@onready var win_sfx: AudioStreamPlayer = $WinSfx
@onready var lost_sfx: AudioStreamPlayer = $LostSfx

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
	PLAYER_WRONG_ANSWER,
	PLAYER_DEATH,
	PLAYER_TURN_END,
	ENEMY_TURN,
	ENEMY_ATTACK,
	ENEMY_HEAL,
	ENEMY_SKIP,
	ENEMY_DEATH,
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
	print(Global.current_world)
	player_class = Global.player_class
	enemy_type = Global.current_enemy_data
	set_state(STATE.BATTLE_START)
	
func _process(delta: float) -> void:
	process_state()

func set_state(to_state: STATE) -> void:
	previous_state = current_state
	current_state = to_state
	
	match current_state:
		STATE.BATTLE_START:
			print("Simula na ang laban")
			start_battle()
		STATE.PLAYER_TURN: 
			ui.show_context_panel("Ikaw na")
			start_player_turn()
			print("Player Turn")
		STATE.PLAYER_SKILL_SELECT:
			start_skill_select()
			print("Skill Select")
		STATE.PLAYER_ATTACK_QUESTION: 
			start_question()
			print("Player Attack Question")
		STATE.PLAYER_ATTACK:
			ui.show_context_panel("Inatake mo ang kalaban")
			start_attack()
			print("Player Attack")
		STATE.PLAYER_QUESTION_HEAL: 
			start_question()
			print("Player Heal Question")
		STATE.PLAYER_HEAL:
			ui.show_context_panel("Pinagaling ang sarili")
			start_heal()
			print("Player Heal")
		STATE.PLAYER_QUESTION_RESTORE_MANA:
			start_question()
			print("Player Restore Mana Question")
		STATE.PLAYER_RESTORE_MANA:
			ui.show_context_panel("Dinagdagan ang aking mana")
			start_restore_mana()
			print("Player Mana Restore")
		STATE.PLAYER_TURN_END: 
			print("Player End Turn")
			player_turn_end()
		STATE.ENEMY_TURN:
			ui.show_context_panel("Ang kalaban na")
			print("Enemy Turn") 
			start_enemy_turn()
		STATE.ENEMY_ATTACK:
			ui.show_context_panel("Inatake ka ng kalaban") 
			print("Enemy Attack")
			start_enemy_attack()
		STATE.ENEMY_HEAL: 
			ui.show_context_panel("Nagpagaling ang kalaban")
			print("Enemy Heal")
			start_enemy_heal()
		STATE.ENEMY_SKIP:
			ui.show_context_panel("Walang ginawa ang kalaban")
			start_enemy_skip()
		STATE.ENEMY_TURN_END:
			ui.show_context_panel("Ikaw na")
			print("Enemy Turn End")
			enemy_turn_end()
		STATE.STATE_TRANSITION:
			state_transition()
		STATE.PLAYER_QUESTION_TIMEOUT:
			ui.show_context_panel("Nawalan ka ng oras")
			start_time_out()
		STATE.PLAYER_DEATH:
			print("Player ded")
			ui.show_context_panel("Napatay ka ng kalaban")
			player_death()
		STATE.ENEMY_DEATH:
			print("Enemy ded")
			ui.show_context_panel("Napatay mo ang kalaban")
			enemy_death()
		STATE.PLAYER_WRONG_ANSWER:
			ui.show_context_panel("Mali ang iyong sagot")
			player_wrong_answer()
		STATE.BATTLE_END_WIN:
			battle_end_win()
		STATE.BATTLE_END_LOSS:
			battle_end_lost()

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
	if enemy_health > 0:
		target_state = STATE.ENEMY_TURN
		set_state(STATE.STATE_TRANSITION)
	else:
		set_state(STATE.ENEMY_DEATH)

func enemy_turn_end() -> void:
	if player_health > 0:
		target_state = STATE.PLAYER_TURN
		set_state(STATE.STATE_TRANSITION)
	else:
		set_state(STATE.PLAYER_DEATH)

func start_player_turn() -> void:
	ui.show_action_selection_panel()

func start_skill_select() -> void:
	ui.show_skill_selection_panel()

func start_question() -> void:
	ui.show_questionaire_panel()

func start_heal() -> void:
	restore.play()
	player_health += player_class.default_heal / current_answer.modifier
	if player_health > player_class.default_hp:
		player_health = player_class.default_hp
	ui.update_player_bar(player_health, player_mana)
	target_state = STATE.PLAYER_TURN_END
	set_state(STATE.STATE_TRANSITION)

func start_restore_mana() -> void:
	restore.play()
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
	restore.play()
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
	button_sfx.play()
	set_state(STATE.PLAYER_SKILL_SELECT)


func _on_ui_restore_health_button_pressed() -> void:
	button_sfx.play()
	set_state(STATE.PLAYER_QUESTION_HEAL)


func _on_ui_restore_mana_button_pressed() -> void:
	button_sfx.play()
	set_state(STATE.PLAYER_QUESTION_RESTORE_MANA)


func _on_ui_skill_selected(skill: Skill) -> void:
	button_sfx.play()
	selected_skill = skill
	if selected_skill.mana_cost > player_mana:
		ui.show_context_panel("NOT ENOUGH MANA")
		target_state = STATE.PLAYER_TURN
		set_state(STATE.STATE_TRANSITION)
		return
	set_state(STATE.PLAYER_ATTACK_QUESTION)

func player_animation_finished(animation: String) -> void:
	if animation == "hurt" or animation == "idle":
		if player_health > 0:
			player_sprite_instance.start_animation("idle")
	elif animation == "death":
		set_state(STATE.BATTLE_END_LOSS)
	else:
		target_state = STATE.PLAYER_TURN_END
		set_state(STATE.STATE_TRANSITION)
		player_sprite_instance.start_animation("idle")

func enemy_animation_finished(animation: String) -> void:
	if animation == "hurt" or animation == "idle":
		if enemy_health > 0:
			enemy_sprite_instance.start_animation("idle")
	elif animation == "death":
		set_state(STATE.BATTLE_END_WIN)
	else:
		target_state = STATE.ENEMY_TURN_END
		set_state(STATE.STATE_TRANSITION)
		enemy_sprite_instance.start_animation("idle")

func hurt_player() -> void:
	if !current_state == STATE.PLAYER_DEATH:
		player_health -= enemy_current_attack_damage
		player_sprite_instance.start_animation("hurt")
		ui.update_player_bar(player_health, player_mana)

func hurt_enemy() -> void:
	var damage: float = float(selected_skill.damage) / float(selected_skill.burst_number) / current_answer.modifier
	enemy_health -= damage
	enemy_sprite_instance.start_animation("hurt")
	ui.update_enemy_bar(enemy_health)


func _on_questionaire_panel_answered(is_correct: bool, modifier: float) -> void:
	button_sfx.play()
	print("answered")
	ui.questionaire_panel.hide()
	current_answer = CurrentAnswer.new(is_correct, modifier)
	if is_correct:
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
	else:
		set_state(STATE.PLAYER_WRONG_ANSWER)

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

func player_death() -> void:
	player_sprite_instance.start_animation("death")

func enemy_death() -> void:
	enemy_sprite_instance.start_animation("death")

func _on_state_transition_timer_timeout() -> void:
	set_state(target_state)


func _on_questionaire_panel_question_time_out() -> void:
	if current_state == STATE.PLAYER_QUESTION_HEAL or current_state == STATE.PLAYER_QUESTION_RESTORE_MANA or current_state == STATE.PLAYER_ATTACK_QUESTION:
		set_state(STATE.PLAYER_QUESTION_TIMEOUT)

func player_wrong_answer() -> void:
	target_state = STATE.PLAYER_TURN_END
	set_state(STATE.STATE_TRANSITION)

func battle_end_win() -> void:
	win_sfx.play()
	ui.show_player_win()

func battle_end_lost() -> void:
	lost_sfx.play()
	ui.show_player_lost()
