extends ClassVisual

var current_animation: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_animation(animtation_name: String):
	animated_sprite.play(animtation_name)
	current_animation = animtation_name


func _on_animated_sprite_2d_frame_changed() -> void:
	var frame: int = animated_sprite.frame
	match current_animation:
		"combo": 
			if frame == 2 or frame == 6 or frame == 10:
				hurt_enemy.emit()
		"kick":
			if frame == 2 or frame == 5:
				hurt_enemy.emit()
		"barrage":
			if frame == 2 or frame == 6 or frame == 10 or frame == 15 or frame == 18:
				hurt_enemy.emit()



func _on_animated_sprite_2d_animation_finished() -> void:
	animation_finished.emit(current_animation)
