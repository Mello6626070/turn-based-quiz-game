class_name SkillPanel extends PanelContainer

signal skill_selected(skill: Skill)

@onready var skill_name_label: Label = %SkillNameLabel
@onready var damage_label: Label = %DamageLabel
@onready var mana_cost_label: Label = %ManaCostLabel

var skill: Skill

func init_skill_panel() -> void:
	skill_name_label.text = skill.skill_name
	damage_label.text = str("DMG: ", skill.damage)
	mana_cost_label.text = str("MAN: ", skill.mana_cost)

func _on_select_button_pressed() -> void:
	skill_selected.emit(skill)
