class_name World
extends Node2D


@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")

var dir : Vector2

var controlled_nouns : Noun

func _ready() -> void:
	set_default_rules()

func set_default_rules() -> void:
	var nouns = get_tree().get_nodes_in_group("NOUN")
	# the player
	Global.RULES["you"] = get_tree().get_first_node_in_group("PLAYER")
	controlled_nouns = Global.RULES["you"]
	
	Global.RULES["stop"] = nouns.filter(func(n:Noun):return n.type == Noun.TYPE.WALL)
	Global.RULES["push"] = nouns.filter(func(n:Noun):return n.type == Noun.TYPE.ROCK)
	
func _input(event: InputEvent) -> void:
	if controlled_nouns.tween_playing:return
	if event.is_action_pressed("ui_up",true):
		dir = Vector2(0,-1)
	elif event.is_action_pressed("ui_down",true):
		dir = Vector2(0,1)
	elif event.is_action_pressed("ui_left",true):
		dir = Vector2(-1,0)
	elif event.is_action_pressed("ui_right",true):
		dir = Vector2(1,0)
		
	if dir == Vector2.ZERO: return
	
	controlled_nouns.move(controlled_nouns.grid_pos + dir)
	
	dir = Vector2.ZERO
