class_name NounText
extends Noun

var nounArray : Array

func _ready() -> void:
	super._ready()
	match_nouns()
	modulate = Color(0.735, 0.735, 0.735, 1.0)
	

func set_grid_position(newGridPos : Vector2) -> void:
	grid_pos = newGridPos
	global_position = tilemap.floor.map_to_local(grid_pos)
	occupied_tiles.append(grid_pos)

func match_nouns() -> void:
	var nouns = get_tree().get_nodes_in_group("NOUN")
	
	# find all nouns corresponding to this type and filter out text nouns
	nouns = nouns.filter(func(e : Noun):return e.type == type )
	nouns = nouns.filter(func(e : Noun):return !(e is NounText))
	
	nounArray = nouns 
	pass


func match_type() -> void:
	match type:
		Noun.TYPE.CARDINAL:
			sprite_2d.frame = 0
		Noun.TYPE.WALL:
			sprite_2d.frame = 3
		Noun.TYPE.ROCK:
			sprite_2d.frame = 4
		Noun.TYPE.FLAG:
			sprite_2d.frame = 8
		Noun.TYPE.BOMB:
			sprite_2d.frame = 10
		Noun.TYPE.KEY:
			sprite_2d.frame = 13
