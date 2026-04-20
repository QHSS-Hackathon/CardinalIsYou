extends Node

signal noun_text_moved
signal open_or_shut_moved

var nounTileDict : Dictionary = {
	Vector2(0,2) : Noun.TYPE.CARDINAL,
	Vector2(1,2) : Noun.TYPE.ROCK,
	Vector2(2,2) : Noun.TYPE.WALL,
	Vector2(3,2) : Noun.TYPE.FLAG,
	Vector2(0,3) : Noun.TYPE.BOMB,
	Vector2(1,3) : Noun.TYPE.KEY
}

var nounTextTileDict : Dictionary = {
	Vector2(0,0) : Noun.TYPE.CARDINAL,
	Vector2(3,0) : Noun.TYPE.WALL,
	Vector2(0,1) : Noun.TYPE.ROCK,
	Vector2(0,2) : Noun.TYPE.FLAG,
	Vector2(2,2) : Noun.TYPE.BOMB,
	Vector2(1,3) : Noun.TYPE.KEY
	
}
var opTileDict : Dictionary = {
	Vector2(1,0) : Operator.OPTYPE.IS,
	Vector2(3,3) : Operator.OPTYPE.AND,
}
var ruleTileDict : Dictionary = {
	Vector2(2,0) : Rule.RULETYPE.YOU,
	Vector2(1,1) : Rule.RULETYPE.STOP,
	Vector2(2,1) : Rule.RULETYPE.PUSH,
	Vector2(3,1) : Rule.RULETYPE.WIN,
	Vector2(1,2) : Rule.RULETYPE.LOSE,
	Vector2(3,2) : Rule.RULETYPE.OPEN,
	Vector2(0,3) : Rule.RULETYPE.SHUT
}

var RULES : Dictionary =  {
}

func _ready() -> void:
	noun_text_moved.connect(on_noun_text_moved)
	
func on_noun_text_moved() -> void:
	# reset rules
	for k in Rule.RULETYPE:
		var key = k.to_lower()
		Global.RULES[key] = []

func make_everything_dark() -> void:
	var nouns = []
	nouns.append_array(get_tree().get_nodes_in_group("NOUNTEXT"))
	nouns.append_array(get_tree().get_nodes_in_group("RULE"))
	nouns.append_array(get_tree().get_nodes_in_group("OPERATOR"))
	for n : Noun in nouns:
		n.modulate = Color(0.735, 0.735, 0.735, 1.0)
