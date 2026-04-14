extends Node

signal noun_text_moved

var nounTileDict : Dictionary = {
	Vector2(0,0) : Noun.TYPE.CARDINAL,
	Vector2(3,0) : Noun.TYPE.WALL,
	Vector2(0,1) : Noun.TYPE.ROCK,
	Vector2(0,2) : Noun.TYPE.FLAG,
	Vector2(2,2) : Noun.TYPE.BOMB
	
}
var opTileDict : Dictionary = {
	Vector2(1,0) : Operator.OPTYPE.IS,
}
var ruleTileDict : Dictionary = {
	Vector2(2,0) : Rule.RULETYPE.YOU,
	Vector2(1,1) : Rule.RULETYPE.STOP,
	Vector2(2,1) : Rule.RULETYPE.PUSH,
	Vector2(3,1) : Rule.RULETYPE.WIN,
	Vector2(1,2) : Rule.RULETYPE.BOOM
}

var RULES : Dictionary =  {
}
