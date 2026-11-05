extends RefCounted
## Shared by the arcade games and the educational practice bank.
const BANK = preload("res://resources/education/bncc_lessons.gd")
const SAVE := "user://education_demo_v1.cfg"

static func saved_grade() -> int:
	var config := ConfigFile.new()
	config.load(SAVE)
	return clampi(int(config.get_value("preferences", "grade", 1)), 1, 9)

static func save_grade(grade: int) -> void:
	var config := ConfigFile.new()
	config.load(SAVE)
	config.set_value("preferences", "grade", clampi(grade, 1, 9))
	config.save(SAVE)

static func calibration(grade: int) -> Dictionary:
	if grade <= 3: return {"speed": 125.0, "move": 220.0, "seconds": 50.0, "spawn": 6.0, "choices": 3}
	if grade <= 5: return {"speed": 160.0, "move": 270.0, "seconds": 38.0, "spawn": 5.0, "choices": 4}
	return {"speed": 195.0, "move": 320.0, "seconds": 28.0, "spawn": 4.2, "choices": 4}

static func build(subject: String, grade: int) -> Array:
	var questions: Array = []
	for lesson in BANK.LESSONS:
		if lesson.subject != subject or int(lesson.grade) != grade: continue
		for original in lesson.questions:
			var question: Dictionary = original.duplicate(true)
			question.lesson = lesson.id
			question.skill = lesson.skill
			question.title = lesson.title
			question.intro = lesson.intro
			var correct: String = question.answers[int(question.correct)]
			var wrong: Array = question.answers.duplicate()
			wrong.erase(correct)
			wrong.shuffle()
			question.options = [correct]
			question.options.append_array(wrong.slice(0, int(calibration(grade).choices) - 1))
			question.options.shuffle()
			question.correct = question.options.find(correct)
			questions.append(question)
	questions.shuffle()
	return questions
