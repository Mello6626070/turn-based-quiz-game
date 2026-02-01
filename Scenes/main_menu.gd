extends Control
@onready var new_game: Button = $CenterContainer/VBoxContainer/NewGame
@onready var continue_game: Button = $CenterContainer/VBoxContainer/Continue
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SavedData.load_data()
	if SavedData.is_first_time:
		new_game.show()
		continue_game.hide()
	else:
		new_game.show()
		continue_game.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	audio_stream_player.play()
	SavedData.reset_data()
	get_tree().change_scene_to_file("res://Scenes/Level/intro_scene.tscn")

func _on_continue_pressed() -> void:
	audio_stream_player.play()
	SavedData.load_data()
	get_tree().change_scene_to_file("res://Scenes/level_selection.tscn")

func _on_exit_pressed() -> void:
	audio_stream_player.play()
	await audio_stream_player.finished
	SavedData.save()
	get_tree().quit()
