extends Node2D


@onready var label: Label = $Label

@export var level: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label.visible and Input.is_action_just_pressed("interact"):
		if SavedData.unlocked_level < level:
			SavedData.unlocked_level = level
			SavedData.save()
		Global.current_enemy_index = -1
		get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	label.show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	label.hide()
