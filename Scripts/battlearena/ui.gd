class_name ArenaUI extends Control

signal attack_button_pressed()
signal restore_health_button_pressed()
signal restore_mana_button_pressed()
signal skill_selected(skill: Skill)

@onready var player_name_label: Label = %PlayerNameLabel
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var player_mana_bar: ProgressBar = %PlayerManaBar
@onready var button_sfx: AudioStreamPlayer = %ButtonSFX

@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar

@onready var action_selection_panel: CenterContainer = %ActionSelectionPanel
@onready var questionaire_panel: VBoxContainer = %QuestionairePanel
@onready var skill_selection_panel: HBoxContainer = %SkillSelectionPanel
@onready var question_timer: Timer = %QuestionTimer
@onready var timer_progress_bar: ProgressBar = %TimerProgressBar

@onready var context_panel: VBoxContainer = %ContextPanel
@onready var context_label: Label = %ContextLabel
@onready var win_panel: Control = %WinPanel
@onready var win_loss_label: Label = %WinLossLabel
@onready var back_to_world_button: Button = $Screen/WinPanel/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackToWorldButton


var skill_panel_scene: PackedScene = preload("res://Scenes/Level/Arena/skill_panel.tscn")

var current_health: float
var previous_health: float

var current_mana: float
var previous_mana: float

var current_enemy_health: float
var previous_enemy_health: float

func _ready() -> void:
	SavedData.load_data()
	player_name_label.text = SavedData.player_name

func _process(delta: float) -> void:
	
	if current_health != previous_health:
		previous_health = lerp(previous_health, current_health, 0.1)
		player_health_bar.value = previous_health
	
	if current_mana != previous_mana:
		previous_mana = lerp(previous_mana, current_mana, 0.1)
		player_mana_bar.value = previous_mana
	
	if current_enemy_health != previous_enemy_health:
		previous_enemy_health = lerp(previous_enemy_health, current_enemy_health, 0.1)
		enemy_health_bar.value = previous_enemy_health
	
	if context_panel.visible:
		var ratio: float = lerp(context_label.visible_ratio, 1.0, 0.2)
		if ratio >= 0.9:
			ratio = 1
		context_label.visible_ratio = ratio
		
	if questionaire_panel.visible:
		timer_progress_bar.max_value = question_timer.wait_time
		timer_progress_bar.value = question_timer.time_left
	else:
		timer_progress_bar.value = 0

func set_player_panel(player_name: String, health: float, mana: float) -> void:
	player_name_label.text = player_name
	player_health_bar.max_value = health
	player_health_bar.value = health
	current_health = health
	previous_health = health
	player_mana_bar.max_value = mana
	player_mana_bar.value = mana
	current_mana = mana
	previous_mana = mana

func update_player_bar(health_amount: float, mana_amount: float) -> void:
	previous_health = current_health
	current_health = health_amount
	previous_mana = current_mana
	current_mana = mana_amount

func set_enemy_panel(enemy_name: String, health: float) -> void:
	enemy_name_label.text = enemy_name
	enemy_health_bar.max_value = health
	enemy_health_bar.value = health
	current_enemy_health = health
	previous_enemy_health = health

func update_enemy_bar(health_amount: float) -> void:
	previous_enemy_health = current_enemy_health
	current_enemy_health = health_amount

func clear_bottom_panel() -> void:
	action_selection_panel.hide()
	questionaire_panel.hide()
	skill_selection_panel.hide()
	context_panel.hide()

func show_action_selection_panel() -> void:
	clear_bottom_panel()
	action_selection_panel.show()

func show_questionaire_panel() -> void:
	clear_bottom_panel()
	questionaire_panel.show()
	question_timer.start()

func show_skill_selection_panel() -> void:
	clear_bottom_panel()
	skill_selection_panel.show()

func show_context_panel(text: String) -> void:
	clear_bottom_panel()
	context_panel.show()
	context_label.text = text
	context_label.visible_ratio = 0

func _on_attack_button_pressed() -> void:
	button_sfx.play()
	attack_button_pressed.emit()

func _on_restore_health_button_pressed() -> void:
	button_sfx.play()
	restore_health_button_pressed.emit()

func _on_restore_mana_button_pressed() -> void:
	button_sfx.play()
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

func show_player_lost() -> void:
	win_panel.show()
	win_loss_label.text = "YOU LOST"
	Global.current_enemy_is_defeated = false

func show_player_win() -> void:
	win_panel.show()
	win_loss_label.text = "YOU WIN"
	Global.current_enemy_is_defeated = true

func _on_back_to_world_button_pressed() -> void:
	button_sfx.play()
	match Global.current_world:
		Global.WORLD.KEYBOARD:
			get_tree().change_scene_to_file("res://Scenes/Level/KeyboardWorld/keyboard_world.tscn")
		Global.WORLD.MOUSE:
			get_tree().change_scene_to_file("res://Scenes/Level/MouseWorld/mouse_world.tscn")
		Global.WORLD.CAMERA:
			get_tree().change_scene_to_file("res://Scenes/Level/CameraWorld/camera_world.tscn")
		Global.WORLD.SPEAKER:
			get_tree().change_scene_to_file("res://Scenes/Level/SpeakerWorld/speaker_world.tscn")
		Global.WORLD.MONITOR:
			get_tree().change_scene_to_file("res://Scenes/Level/MonitorWorld/monitor_world.tscn")
		Global.WORLD.PRINTER:
			get_tree().change_scene_to_file("res://Scenes/Level/PrinterWorld/printer_world.tscn")
		Global.WORLD.CPU:
			get_tree().change_scene_to_file("res://Scenes/Level/CPUWorld/cpu_world.tscn")
