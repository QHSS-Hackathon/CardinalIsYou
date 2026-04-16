class_name Rule
extends Noun

enum RULETYPE {
	NONE, YOU, PUSH, STOP, WIN, LOSE, OPEN, SHUT
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
		RULETYPE.WIN:
			sprite_2d.frame = 7
		RULETYPE.LOSE:
			sprite_2d.frame = 9
		RULETYPE.OPEN:
			sprite_2d.frame = 11
		RULETYPE.SHUT:
			sprite_2d.frame = 12
	
	string = RULETYPE.keys()[ruleType].to_lower()
