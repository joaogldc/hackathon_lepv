extends SceneTree

func _initialize() -> void:
	call_deferred("check")

func check() -> void:
	seed(20261031)
	var service := root.get_node("Duel")
	for level in range(3):
		var samples := {}
		for index in range(1000):
			var question: Dictionary = service.generate_question(level)
			var operands: PackedStringArray = question.question.split(" ")
			var expected := int(operands[0])*int(operands[2])
			assert(question.answer==expected,"Incorrect product")
			assert(question.options.size()==4,"Four alternatives required")
			var unique := {}
			var correct := 0
			for value in question.options:
				assert(value>0,"Answers must be positive")
				unique[value]=true
				if value==expected: correct+=1
			assert(unique.size()==4 and correct==1,"Exactly one correct answer and no duplicates")
			assert(expected>60,"Old single-digit questions must not return")
			samples[question.question]=true
		assert(samples.size()>100,"Question variety is too low")
	print("MATH PASS: 3000 questions, accurate products, distinct alternatives and variety")
	quit()
