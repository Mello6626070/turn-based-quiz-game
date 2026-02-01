extends Control
@onready var weapon_visual: AnimatedSprite2D = %WeaponVisual
@onready var hp_label: Label = %HPLabel
@onready var hp_regen_label: Label = %HPRegenLabel
@onready var mana_label: Label = %ManaLabel
@onready var mana_regen_label: Label = %ManaRegenLabel
@onready var weapon_label: Label = %WeaponLabel
@onready var skill_1_name: Label = %Skill1Name
@onready var skill_1dmg: Label = %Skill1DMG
@onready var skill_1mana: Label = %Skill1MANA
@onready var skill_2_name: Label = %Skill2Name
@onready var skill_2dmg: Label = %Skill2DMG
@onready var skill_2mana: Label = %Skill2MANA
@onready var skill_3_name: Label = %Skill3Name
@onready var skill_3dmg: Label = %Skill3DMG
@onready var skill_3mana: Label = %Skill3MANA
@onready var player_name_label: Label = %PlayerNameLabel
@onready var name_input_screen: Control = %NameInputScreen
@onready var name_input: LineEdit = %NameInput
@onready var levels: Control = %Levels
@onready var buttonsfx: AudioStreamPlayer = $buttonsfx

@export var player_weapon_list: Array[PlayerClass]

var weapon_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_stats()
	SavedData.load_data()
	player_name_label.text = SavedData.player_name
	
	for child in levels.get_children():
		if child.get_index() + 1 > SavedData.unlocked_level:
			print(SavedData.unlocked_level)
			child.hide()
	
	if SavedData.is_first_time and SavedData.player_name.length() <= 1:
		name_input_screen.show()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_weapon_visual() -> void:
	match weapon_index:
		0: weapon_visual.play("SwordIdle")
		1: weapon_visual.play("BowIdle")
		2: weapon_visual.play("KnucklesIdle")
	update_stats()

func update_stats() -> void:
	var weapon: PlayerClass = player_weapon_list[weapon_index]
	weapon_label.text = weapon.name
	hp_label.text = str("HP: ", int(weapon.default_hp))
	hp_regen_label.text = str("HP REGEN: ", int(weapon.default_heal))
	mana_label.text = str("MANA: ", int(weapon.default_mana))
	mana_regen_label.text = str("MANA REGEN: ", int(weapon.default_mana_restore))
	skill_1_name.text = str(weapon.skill1.skill_name)
	skill_1dmg.text = str("DMG: ", int(weapon.skill1.damage))
	skill_1mana.text = str("MANA: ", int(weapon.skill1.mana_cost))
	skill_2_name.text = str(weapon.skill2.skill_name)
	skill_2dmg.text = str("DMG: ", int(weapon.skill2.damage))
	skill_2mana.text = str("MANA: ", int(weapon.skill2.mana_cost))
	skill_3_name.text = str(weapon.skill3.skill_name)
	skill_3dmg.text = str("DMG: ", int(weapon.skill3.damage))
	skill_3mana.text = str("MANA: ", int(weapon.skill3.mana_cost))
	
func _on_previous_button_pressed() -> void:
	weapon_index -= 1
	if weapon_index < 0:
		weapon_index = 2
	update_weapon_visual()
	buttonsfx.play()


func _on_next_button_pressed() -> void:
	weapon_index += 1
	if weapon_index > 2:
		weapon_index = 0
	update_weapon_visual()
	buttonsfx.play()

func set_location_null() -> void:
	Global.current_world_previous_location = Vector2.ZERO

func _on_keyboard_forrest_button_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.KEYBOARD
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/KeyboardWorld/keyboard_world.tscn")

func _on_mouse_forrest_button_2_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.MOUSE
	print(Global.current_world)
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/MouseWorld/mouse_world.tscn")


func _on_name_confirm_button_pressed() -> void:
	buttonsfx.play()
	var name: String = name_input.text
	SavedData.player_name = name
	player_name_label.text = name
	SavedData.save()
	name_input_screen.hide()

func _on_camera_cave_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.CAMERA
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/CameraWorld/camera_world.tscn")


func _on_speaker_plains_button_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.SPEAKER
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/SpeakerWorld/speaker_world.tscn")


func _on_monitor_island_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.MONITOR
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/MonitorWorld/monitor_world.tscn")


func _on_printer_mountain_button_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.PRINTER
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/PrinterWorld/printer_world.tscn")


func _on_cpu_island_button_pressed() -> void:
	buttonsfx.play()
	Global.player_class = player_weapon_list[weapon_index]
	Global.current_world = Global.WORLD.CPU
	set_location_null()
	get_tree().change_scene_to_file("res://Scenes/Level/CPUWorld/cpu_world.tscn")


func _on_exit_button_pressed() -> void:
	buttonsfx.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
