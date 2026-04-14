extends World

@onready var layout: TileMapLayer = $layout
@onready var player : Player = get_tree().get_first_node_in_group("PLAYER")

func _ready() -> void:
	super._ready()
	var walls = layout.get_used_cells_by_id(0,Vector2i(2,2))
	for w in walls:
		var noun : Noun = load("res://Nouns/Scenes/noun.tscn").instantiate()
		noun.type = Noun.TYPE.WALL
		noun.grid_pos = w
		add_child(noun)
	
	var rocks = layout.get_used_cells_by_id(0,Vector2i(1,2))
	for r in rocks:
		var noun : Noun = load("res://Nouns/Scenes/noun.tscn").instantiate()
		noun.type = Noun.TYPE.ROCK
		noun.grid_pos = r
		add_child(noun)
	
	layout.hide()
