class_name ArenaUI extends Control

signal attack_button_pressed()
signal restore_health_button_pressed()
signal restore_mana_button_pressed()
signal skill_selected(skill: Skill)

@onready var player_name_label: Label = %PlayerNameLabel
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var player_mana_bar: ProgressBar = %PlayerManaBar

@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar

@onready var action_selection_panel: CenterContainer = %ActionSelectionPanel
@onready var questionaire_panel: VBoxContainer = %QuestionairePanel
@onready var skill_selection_panel: HBoxContainer = %SkillSelectionPanel

var skill_panel_scene: PackedScene = preload("res://Scenes/Level/Arena/skill_panel.tscn")

func set_player_panel(player_name: String, health: float, mana: float) -> void:
	player_name_label.text = player_name
	player_health_bar.max_value = health
	player_health_bar.value = health
	player_mana_bar.max_value = mana
	player_mana_bar.value = mana

func update_player_bar(health_amount: float, mana_amount: float) -> void:
	player_health_bar.value = health_amount
	player_mana_bar.value = mana_amount

func set_enemy_panel(enemy_name: String, health: float) -> void:
	enemy_name_label.text = enemy_name
	enemy_health_bar.max_value = health
	enemy_health_bar.value = health

func update_enemy_bar(health_amount: float) -> void:
	enemy_health_bar.text = health_amount

func clear_bottom_panel() -> void:
	action_selection_panel.hide()
	questionaire_panel.hide()
	skill_selection_panel.hide()

func show_action_selection_panel() -> void:
	clear_bottom_panel()
	action_selection_panel.show()

func show_questionaire_panel() -> void:
	clear_bottom_panel()
	questionaire_panel.show()

func show_skill_selection_panel() -> void:
	clear_bottom_panel()
	skill_selection_panel.show()

func _on_attack_button_pressed() -> void:
	attack_button_pressed.emit()

func _on_restore_health_button_pressed() -> void:
	restore_health_button_pressed.emit()

func _on_restore_mana_button_pressed() -> void:
	restore_mana_button_pressed.emit()

func populate_skill_panel(list: Array[Skill]) -> void:
	for skill in list:
		var instance: SkillPanel = skill_panel_scene.instantiate()
		skill_selection_panel.add_child(instance)
		instance.skill = skill
		instance.init_skill_panel()
		instance.skill_selected.connect(skill_selected_recieved)

func skill_selected_recieved(skill: Skill) -> void:
	skill_selected.emit(skill)
