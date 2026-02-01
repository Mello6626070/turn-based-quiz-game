extends EnemyVisual
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack: AudioStreamPlayer = $Attack
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var death: AudioStreamPlayer = $Death


func start_animation(animation_name: String) -> void:
	match animation_name:
		"light_attack":
			var rng: float = randi_range(0, 1)
			if rng == 0:
				animated_sprite_2d.play("slash1")
			else :
				animated_sprite_2d.play("slash2")
			attack.play()
		"heavy_attack":
			animated_sprite_2d.play("three_fold_slash")
			attack.play()
		"ultimate":
			animated_sprite_2d.play("ultimate")
		"idle":
			animated_sprite_2d.play("idle")
		"hurt":
			animated_sprite_2d.play("hurt")
			hurt.play()
		"death":
			animated_sprite_2d.play("death")
			death.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	enemy_animation_finished.emit(animated_sprite_2d.animation)

func _on_animated_sprite_2d_frame_changed() -> void:
	var current_frame: int = animated_sprite_2d.frame
	var current_animation: String = animated_sprite_2d.animation
	match current_animation:
		"slash1":
			if current_frame == 2:
				hurt_player.emit()
		"slash2":
			if current_frame == 2:
				hurt_player.emit()
		"three_fold_slash":
			if current_frame == 2 or current_frame == 8 or current_frame == 13:
				hurt_player.emit()
		"ultimate":
			if current_frame == 1 or current_frame == 4 or current_frame == 8:
				hurt_player.emit()
