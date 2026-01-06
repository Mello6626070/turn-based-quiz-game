class_name SavedData extends Node

const SLOT1: String = "user://save1.json"
const SLOT2: String = "user://save2.json"
const SLOT3: String = "user://save3.json"
const KEY: String = "3.14159265"

enum SLOT{
	SLOT1,
	SLOT2,
	SLOT3
}



var selected_slot: SLOT

func save(slot: SLOT) -> void:
	var selected_slot: String
	match slot:
		SLOT.SLOT1:
			selected_slot = SLOT1
		SLOT.SLOT2:
			selected_slot = SLOT2
		SLOT.SLOT3:
			selected_slot = SLOT3
	var file: FileAccess = FileAccess.open_encrypted_with_pass(selected_slot, FileAccess.WRITE, KEY)
	
	
