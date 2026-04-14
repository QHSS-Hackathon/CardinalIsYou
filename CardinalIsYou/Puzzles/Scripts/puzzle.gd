class_name Puzzle
extends World

@onready var layout: TileMapLayer = $layout
@onready var player : Player = get_tree().get_first_node_in_group("PLAYER")

func _ready() -> void:
	var walls = layout.get_used_cells_by_id(0,Vector2i(2,2))
	for w in walls:
		create_noun(Noun.TYPE.WALL,w)
	
	var rocks = layout.get_used_cells_by_id(0,Vector2i(1,2))
	for r in rocks:
		create_noun(Noun.TYPE.ROCK,r)
		
	var player = layout.get_used_cells_by_id(0,Vector2i(0,2))
	for p in player:
		create_noun(Noun.TYPE.CARDINAL,p)
	
	var flags = layout.get_used_cells_by_id(0,Vector2i(3,2))
	for f in flags:
		create_noun(Noun.TYPE.FLAG,f)
	
	var bombs = layout.get_used_cells_by_id(0,Vector2i(0,3))
	for b in bombs:
		create_noun(Noun.TYPE.BOMB,b)
	
	create_nountext_objects()
	create_rule_objects()
	create_operator_objects()
	layout.hide()
	
	await get_tree().process_frame
	super._ready()

func _input(event: InputEvent) -> void:
	super._input(event)
	if event.is_action("ui_accept"):
		load_default()

func load_default() -> void:
	super._ready()
	var nouns = get_tree().get_nodes_in_group("NOUN")
	nouns.append_array(get_tree().get_nodes_in_group("NOUNTEXT"))
	nouns.append_array(get_tree().get_nodes_in_group("RULE"))
	nouns.append_array(get_tree().get_nodes_in_group("OPERATOR"))
	for n : Noun in nouns:
		n.grid_pos = n.default_grid_pos
		n.type = n.default_type
		n._ready()
	
	layout.hide()

func create_rule_objects() -> void:
	for key in Global.ruleTileDict:
		var tiles = layout.get_used_cells_by_id(1,Vector2i(key))
		for t in tiles:
			var rule : Rule = load("res://Nouns/Scenes/rule.tscn").instantiate()
			rule.ruleType = Global.ruleTileDict[key]
			rule.grid_pos = t
			add_child(rule)

func create_operator_objects() -> void:
	for key in Global.opTileDict:
		var tiles = layout.get_used_cells_by_id(1,Vector2i(key))
		for t in tiles:
			var op : Operator = load("res://Nouns/Scenes/operator.tscn").instantiate()
			op.operatorType = Global.opTileDict[key]
			op.grid_pos = t
			add_child(op)

func create_nountext_objects() -> void:
	for key in Global.nounTileDict:
		var tiles = layout.get_used_cells_by_id(1,Vector2i(key))
		for t in tiles:
			var nt : NounText = load("res://Nouns/Scenes/noun_text.tscn").instantiate()
			nt.type = Global.nounTileDict[key]
			nt.grid_pos = t
			add_child(nt)

func create_noun(type : Noun.TYPE, grid_pos : Vector2i) -> void:
	var noun : Noun = load("res://Nouns/Scenes/noun.tscn").instantiate()
	noun.type = type
	noun.grid_pos = grid_pos
	noun.part_of_layout = true
	add_child(noun)
	pass
