class_name Question extends Resource
@export var text: String
@export var answers: Array[Answer]

func get_answers() -> Array[Answer]:
	answers.shuffle()
	return answers

func get_text() -> String:
	return text

func is_answer_correct(answer: String) -> bool:
	match answer:
		"A": 
			if answers[0].is_correct:
				return true
			else:
				return false
		"B":
			if answers[1].is_correct:
				return true
			else:
				return false
		"C":
			if answers[2].is_correct:
				return true
			else:
				return false
	return false
