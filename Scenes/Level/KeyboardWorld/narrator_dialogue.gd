extends Area2D
@onready var label: Label = $Control/Label
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var showing_text: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !SavedData.is_first_time:
		static_body_2d.call_deferred("queue_free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if showing_text:
		label.visible_ratio += 0.005


func _on_body_entered(body: Node2D) -> void:
	label.show()
	if SavedData.is_first_time:
		SavedData.is_first_time = false
		SavedData.save()
		showing_text = true
		label.visible_ratio = 0
		audio_stream_player.play()
		return
	label.visible_ratio = 1.0
	showing_text = true

func _on_body_exited(body: Node2D) -> void:
	showing_text = false
	label.hide()


func _on_audio_stream_player_finished() -> void:
	if static_body_2d:
		static_body_2d.call_deferred("queue_free")
