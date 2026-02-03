extends Node

const SLOT1: String = "user://save1.json"
const KEY: String = "3.14159265"

var player_name: String = ""
var unlocked_level: int = 1
var is_first_time: bool = true

func save() -> void:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(SLOT1, FileAccess.WRITE, KEY)
	
	var data: Dictionary = {
		"player_name": player_name,
		"unlocked_level": unlocked_level,
		"is_first_time": is_first_time
	}
	
	var json: String = JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()

func load_data() -> void: 
	if FileAccess.file_exists(SLOT1):
		var file: FileAccess = FileAccess.open_encrypted_with_pass(SLOT1, FileAccess.READ, KEY)
		var json: String = file.get_as_text()
		var data: Dictionary = JSON.parse_string(json)
		
		player_name = data["player_name"]
		unlocked_level = data["unlocked_level"]
		is_first_time = data["is_first_time"]
		file.close()

func reset_data() -> void:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(SLOT1, FileAccess.WRITE, KEY)
	
	var data: Dictionary = {
		"player_name": "",
		"unlocked_level": 1,
		"is_first_time": true
	}
	
	var json: String = JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()
