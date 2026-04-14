class_name Noun
extends Node2D


static var occupied_tiles = []

enum TYPE {
	NONE, CARDINAL, WALL, ROCK, FLAG, BOMB
}

@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")
@onready var tile_size = tilemap.floor.tile_set.tile_size.x
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var world : World = get_tree().get_first_node_in_group("WORLD")

@export var grid_pos : Vector2
@export var part_of_layout : bool = false
@export var type : TYPE
@export var blocked : bool = false

var dir : Vector2
var tween_playing : bool

var default_grid_pos : Vector2
var default_type : Noun.TYPE


func _ready() -> void:
	default_grid_pos = grid_pos
	default_type = type
	set_grid_position(grid_pos)
	match_type()
	modulate = Color(0.997, 0.997, 0.997, 1.0)

func set_grid_position(newGridPos : Vector2) -> void:
	grid_pos = newGridPos
	global_position = tilemap.floor.map_to_local(grid_pos)
	occupied_tiles.append(grid_pos)
	pass

func on_moved() -> void:
	occupied_tiles.append(grid_pos)
	pass

func move(new_pos: Vector2, pusher : Noun = null) -> void:
	blocked = false
	var direction: Vector2 = new_pos - grid_pos
	
	# make check for if target position is a stopping obstacle
	var obstacles = Global.RULES["stop"].map(func(e : Noun):return e.grid_pos)
	if obstacles.has(grid_pos + direction):
		blocked = true
		play_blocked_animation(direction) 
		return
	
	# make check for push
	var push = Global.RULES["push"]
	push.append_array(Global.RULES["pushAlways"])
	# put on top
	z_index = 1 if push.has(self) else 0
	# check if pushing / can move 
	for p : Noun in push:
		if p.grid_pos == grid_pos + direction:
			p.move(p.grid_pos + direction, self)
			if p.blocked: 
				blocked = true
				play_blocked_animation(direction) 
				return
	
	# change grid positon data
	occupied_tiles.remove_at(occupied_tiles.find(self.grid_pos))
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	play_movement_animation(target_position)
	
	# emit signal if nountext
	if self is NounText : Global.noun_text_moved.emit()
	if self is Rule : Global.noun_text_moved.emit()
	
func play_movement_animation(target_position : Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.15).set_ease(Tween.EASE_IN_OUT)
	tween_playing = true
	
	await tween.finished
	dir = Vector2.ZERO
	
	await get_tree().create_timer(.025).timeout
	tween_playing = false
	occupied_tiles.append(grid_pos)

func play_blocked_animation(direction : Vector2) -> void:
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	
	# go towards target
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween_playing = true
	
	# go back to original position cuz its blocked dumbahh
	grid_pos -= direction
	var tween2: Tween = create_tween()
	target_position = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	tween2.tween_property(self, "global_position", target_position, 0.2).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	dir = Vector2.ZERO
	tween_playing = false
	pass

func match_type() -> void:
	match type:
		TYPE.CARDINAL:
			sprite_2d.texture = load("res://Nouns/Assets/uzu.jpg")
			sprite_2d.scale = Vector2(0.02,0.02)
		TYPE.WALL:
			sprite_2d.texture = load("res://Nouns/Assets/ampersands.jpg")
			sprite_2d.scale = Vector2(0.018,0.018)
		TYPE.ROCK:
			sprite_2d.texture = load("res://Nouns/Assets/psyduck.png")
			sprite_2d.scale = Vector2(.060,.060)
		TYPE.FLAG:
			sprite_2d.texture = load("res://Nouns/Assets/flag.png")
			sprite_2d.scale = Vector2(1,1)
			sprite_2d.modulate = Color(1.5,1.5,1.5)
		TYPE.BOMB:
			sprite_2d.texture =load("res://Nouns/Assets/bomb.png")
			sprite_2d.scale = Vector2(1,1)
