class_name World
extends Node2D


@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")

var dir : Vector2
var borders : Array

var controlled_nouns : Array

func _ready() -> void:
	set_default_rules()
	
	for k in Rule.RULETYPE:
		var key = k.to_lower()
		Global.RULES[key] = []

func set_default_rules() -> void:
	var nouns = get_tree().get_nodes_in_group("NOUN")
	var nounsText = get_tree().get_nodes_in_group("NOUNTEXT")
	var rules = get_tree().get_nodes_in_group("RULE")
	var operators = get_tree().get_nodes_in_group("OPERATOR")
	# the player
	#Global.RULES["you"] = get_tree().get_first_node_in_group("PLAYER")wd
	#controlled_nouns = Global.RULES["you"]
	
	#Global.RULES["stop"] = nouns.filter(func(n:Noun):return n.type == Noun.TYPE.WALL)
	#Global.RULES["push"] = nouns.filter(func(n:Noun):return n.type == Noun.TYPE.ROCK)
	Global.RULES["pushAlways"] = nounsText
	Global.RULES["pushAlways"].append_array(rules)
	Global.RULES["pushAlways"].append_array(operators)
	
func _input(event: InputEvent) -> void:
	if controlled_nouns.is_empty() or controlled_nouns.front().tween_playing:return
	if event.is_action_pressed("ui_up",true):
		dir = Vector2(0,-1)
	elif event.is_action_pressed("ui_down",true):
		dir = Vector2(0,1)
	elif event.is_action_pressed("ui_left",true):
		dir = Vector2(-1,0)
	elif event.is_action_pressed("ui_right",true):
		dir = Vector2(1,0)
		
	if dir == Vector2.ZERO: return
	
	for n : Noun in controlled_nouns:
		n.move(n.grid_pos + dir)
	
	dir = Vector2.ZERO
