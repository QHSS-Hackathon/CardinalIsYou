class_name Noun
extends Node2D

static var occupied_tiles = []

enum TYPE {
	NONE, CARDINAL, WALL, ROCK
}

@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")
@onready var tile_size = tilemap.floor.tile_set.tile_size.x
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var grid_pos : Vector2
@export var type : TYPE
var dir : Vector2
var tween_playing : bool

func _ready() -> void:
	set_grid_position(grid_pos)
	match_type()

func set_grid_position(newGridPos : Vector2) -> void:
	grid_pos = newGridPos
	global_position = tilemap.floor.map_to_local(grid_pos)
	occupied_tiles.append(grid_pos)
	pass

func on_moved() -> void:
	occupied_tiles.append(grid_pos)
	pass

func move(new_pos: Vector2, pusher : Noun = null) -> void:
	var direction: Vector2 = new_pos - grid_pos
	
	# make check for if target position is a stopping obstacle
	var obstacles = Global.RULES["stop"].map(func(e : Noun):return e.grid_pos)
	if obstacles.has(grid_pos + direction):
		if pusher : pusher.move(pusher.grid_pos - direction)
		return
	
	# make check for push
	var push = Global.RULES["push"]
	for p : Noun in push:
		if p.grid_pos == grid_pos + direction:
			p.move(p.grid_pos + direction, self)
	
	# change grid positon data
	occupied_tiles.remove_at(occupied_tiles.find(self.grid_pos))
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	
	#tween_playing = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween_playing = true
	
	await tween.finished
	dir = Vector2.ZERO
	
	await get_tree().create_timer(.05).timeout
	tween_playing = false
	occupied_tiles.append(grid_pos)

func match_type() -> void:
	match type:
		TYPE.WALL:
			sprite_2d.texture = load("res://Nouns/Assets/ampersands.jpg")
			sprite_2d.scale = Vector2(0.018,0.018)
		TYPE.ROCK:
			sprite_2d.texture = load("res://Nouns/Assets/psyduck.png")
			sprite_2d.scale = Vector2(.060,.060)
