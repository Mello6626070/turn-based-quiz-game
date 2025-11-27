extends StaticBody2D

@onready var promp_label: Label = $PrompLabel
@onready var dialogue_box: CanvasLayer = $DialogueBox

var player: CharacterBody2D

var is_showing_prompt: bool = false

func _on_detector_body_entered(body: Node2D) -> void:
	is_showing_prompt = true
	player = body

func _on_detector_body_exited(body: Node2D) -> void:
	is_showing_prompt = false
	player = null

func _process(delta: float) -> void:
	if is_showing_prompt:
		promp_label.show()
		if Input.is_action_just_pressed("interact"):
			dialogue_box.show()
			player.movement_lock = true
		
		if player.movement_lock:
			if Input.is_action_just_pressed("next_dialogue"):
				dialogue_box.hide()
				player.movement_lock = false
	else: 
		promp_label.hide()

func toggle_label() -> void:
	if is_showing_prompt:
		promp_label.hide()
		is_showing_prompt = false
	else:
		promp_label.show()
		is_showing_prompt = true
