extends CharacterBody2D

@onready var prompt_label: Label = $PromptLabel
var is_player_near: bool = false

func _on_detector_body_entered(body: Node2D) -> void:
	prompt_label.show()
	is_player_near = true

func _on_detector_body_exited(body: Node2D) -> void:
	prompt_label.hide()
	is_player_near = false

func _process(delta: float) -> void:
	if is_player_near and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://Scenes/Worlds/arena.tscn")
