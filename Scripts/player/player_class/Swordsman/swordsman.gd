extends ClassVisual

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt: AudioStreamPlayer = %hurt
@onready var attack: AudioStreamPlayer = %attack


func start_animation(animation_name: String) -> void:
	match animation_name:
		"slash":
			var rng: float = randi_range(0, 1)
			if rng == 0:
				animated_sprite_2d.play("slash1")
			else :
				animated_sprite_2d.play("slash2")
		"three_fold_slash":
			animated_sprite_2d.play("three_fold_slash")
		"ultimate":
			animated_sprite_2d.play("ultimate")
		"idle":
			animated_sprite_2d.play("idle")
		"hurt":
			animated_sprite_2d.play("hurt")
			play_hurt_effect()
		"death":
			animated_sprite_2d.play("death")

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_finished.emit(animated_sprite_2d.animation)

func _on_animated_sprite_2d_frame_changed() -> void:
	var current_frame: int = animated_sprite_2d.frame
	var current_animation: String = animated_sprite_2d.animation
	match current_animation:
		"slash1":
			if current_frame == 2:
				hurt_enemy.emit()
				attack.play()
		"slash2":
			if current_frame == 2:
				hurt_enemy.emit()
				attack.play()
		"three_fold_slash":
			if current_frame == 2 or current_frame == 8 or current_frame == 13:
				hurt_enemy.emit()
				attack.play()
		"ultimate":
			if current_frame == 1 or current_frame == 4 or current_frame == 8:
				hurt_enemy.emit()
				attack.play()

func play_hurt_effect() -> void:
	var value = randf_range(0.5, 1.5)
	hurt.pitch_scale = value
	hurt.play()

func play_attack_effect() -> void:
	var value = randf_range(0.5, 1.5)
	attack.pitch_scale = value
	attack.play()
