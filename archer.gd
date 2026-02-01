extends ClassVisual
@onready var attack: AudioStreamPlayer = %Attack
@onready var hurt: AudioStreamPlayer = %Hurt

var current_animation: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_animation(animtation_name: String):
	current_animation = animtation_name
	match animtation_name:
		"idle": 
			animated_sprite.play(animtation_name)
		"shoot": 
			animated_sprite.play(animtation_name)
		"pierce": 
			animated_sprite.play(animtation_name)
		"snipe": 
			animated_sprite.play(animtation_name)
		"death": 
			animated_sprite.play(animtation_name)
		"hurt":
			animated_sprite.play(animtation_name)
			hurt.play()


func _on_animated_sprite_2d_frame_changed() -> void:
	var frame: int = animated_sprite.frame
	match current_animation:
		"shoot": 
			if frame == 7:
				hurt_enemy.emit()
				attack.play()
		"pierce": 
			if frame == 7 or frame == 13:
				hurt_enemy.emit()
				attack.play()
		"snipe":
			if frame == 10:
				hurt_enemy.emit()
				attack.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_finished.emit(current_animation)
