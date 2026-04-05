class_name Rule
extends Noun

enum RULETYPE {
	NONE, YOU, PUSH, STOP
}

@export var ruleType : RULETYPE
@export var string : String

func match_type() -> void:
	match ruleType:
		RULETYPE.YOU:
			sprite_2d.frame = 2
		RULETYPE.PUSH:
			sprite_2d.frame = 6
		RULETYPE.STOP:
			sprite_2d.frame = 5
	
	string = RULETYPE.keys()[ruleType].to_lower()
