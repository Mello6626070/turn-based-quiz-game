extends VBoxContainer

signal answered(is_correct: bool)

@onready var question_text_label: Label = %QuestionTextLabel
@onready var answer_text_label: Label = %AnswerTextLabel

@export var questions: Array[Question]

var current_question: Question

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func select_question() -> void:
	current_question = questions[0]
	display_question()

func display_question() -> void:
	question_text_label.text = current_question.get_text()
	var answers: Array[Answer] = current_question.get_answers()
	var answer_text: String = str("[A. ", answers[0].text, "] ", "[B. ", answers[1].text, "] ", "[C. ", answers[2].text, "]" )
	answer_text_label.text = answer_text

func check_answer(letter: String) -> void:
	var is_correct: bool = current_question.is_answer_correct(letter)
	answered.emit(is_correct)

func _on_answer_a_button_pressed() -> void:
	check_answer("A")


func _on_answer_b_button_pressed() -> void:
	check_answer("B")


func _on_answer_c_button_pressed() -> void:
	check_answer("C")


func _on_visibility_changed() -> void:
	if visible:
		select_question()
	else:
		return
