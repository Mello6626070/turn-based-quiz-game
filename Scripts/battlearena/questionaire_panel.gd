extends VBoxContainer

signal answered(is_correct: bool, modifier: float)
signal question_time_out()

@onready var question_text_label: Label = %QuestionTextLabel
@onready var answer_a_button: Button = %AnswerAButton
@onready var answer_b_button: Button = %AnswerBButton
@onready var answer_c_button: Button = %AnswerCButton

@export var questions: Array[Question]
@export var divisor: float = 2
@export var converter: float = 1000

var current_question: Question
var start_time: float
var end_time: float

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func select_question() -> void:
	start_time = Time.get_ticks_msec()
	current_question = questions[0]
	display_question()

func display_question() -> void:
	question_text_label.text = current_question.get_text()
	var answers: Array[Answer] = current_question.get_answers()
	answer_a_button.text = answers[0].text
	answer_b_button.text = answers[1].text
	answer_c_button.text = answers[2].text

func check_answer(letter: String) -> void:
	var is_correct: bool = current_question.is_answer_correct(letter)
	print(calculate_modifier())
	answered.emit(is_correct, calculate_modifier())

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

func calculate_modifier() -> float:
	end_time = Time.get_ticks_msec()
	var score: float = ((end_time - start_time)/converter)/divisor
	
	if score <= 1:
		return 1
	else:
		return score


func _on_question_timer_timeout() -> void:
	question_time_out.emit()
