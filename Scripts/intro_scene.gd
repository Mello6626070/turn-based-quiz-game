extends Control

@onready var label: Label = %Label
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var continue_button: Button = %ContinueButton

var current_ratio: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continue_button.hide()
	SavedData.load_data()
	#var text: String = str("Pagkatapos mong iligtas lahat, magiging maayos ang Computer World! Salamat, ", SavedData.player_name, ". Ngayon, handa ka nang gumamit ng kompyuter nang tama.")
	#label.text = text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	current_ratio += 0.002
	label.visible_ratio = current_ratio
	if label.visible_ratio == 1:
		continue_button.show()
	
	if audio_stream_player.get_playback_position() >= 15.0:
		audio_stream_player.stop()


func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")
