extends EnemyVisual

@onready var attack: AudioStreamPlayer = $Attack
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var death: AudioStreamPlayer = $Death


var current_anim: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_animation(animtation_name: String):
	match animtation_name:
		"idle": animated_sprite.play("idle")
		"light_attack": 
			animated_sprite.play("attack1")
			hurt_player.emit()
			attack.play()
		"heavy_attack": 
			animated_sprite.play("attack2")
			hurt_player.emit()
			attack.play()
		"hurt": 
			animated_sprite.play("hurt")
			hurt.play()
		"death": 
			animated_sprite.play("death")
			death.play()
	current_anim = animated_sprite.animation


func _on_animated_sprite_2d_frame_changed() -> void:
	var frame: int = animated_sprite.frame


func _on_animated_sprite_2d_animation_finished() -> void:
	enemy_animation_finished.emit(animated_sprite.animation)
