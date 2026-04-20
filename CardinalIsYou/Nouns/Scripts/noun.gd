class_name Noun
extends Node2D


static var occupied_tiles = []

enum TYPE {
	NONE, CARDINAL, WALL, ROCK, FLAG, BOMB, KEY
}

@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")
@onready var tile_size = tilemap.floor.tile_set.tile_size.x
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var world : World = get_tree().get_first_node_in_group("WORLD")
@onready var ui : UI = get_tree().get_first_node_in_group("UI")
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@export var grid_pos : Vector2
@export var part_of_layout : bool = false
@export var type : TYPE
@export var blocked : bool = false

var default_frame : int = 9999999
var dir : Vector2
static var tween_playing : bool

var default_grid_pos : Vector2
var default_type : Noun.TYPE


func _ready() -> void:
	animated_sprite_2d.hide()
	default_grid_pos = grid_pos
	default_type = type
	set_grid_position(grid_pos)
	match_type()
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	for i in range(5):
		await get_tree().process_frame
	default_frame = sprite_2d.frame

func _process(delta: float) -> void:
	if !world: 
		world = get_tree().get_first_node_in_group("WORLD") 
		return
	
	if check_lose() and world.controlled_nouns.has(self):
		remove_self()
		return
	if Global.RULES['win'].has(self):
		animated_sprite_2d.show()
		animated_sprite_2d.play("default")
		z_index = 10
		for n : Noun in world.controlled_nouns:
			if n.grid_pos == grid_pos and !tween_playing:
				ui.current_level += 1	
				ui.load_level(ui.current_level - 1)
	else:
		animated_sprite_2d.hide()
		animated_sprite_2d.stop()

func set_grid_position(newGridPos : Vector2) -> void:
	grid_pos = newGridPos
	global_position = tilemap.floor.map_to_local(grid_pos)
	occupied_tiles.append(grid_pos)
	pass

func on_moved() -> void:
	occupied_tiles.append(grid_pos)
	pass

func move(new_pos: Vector2, _pusher : Noun = null) -> void:
	blocked = false
	var direction: Vector2 = new_pos - grid_pos
	# check for lose before movement
	
	# check open
	if check_open(direction) : 
		remove_self()
		return
	# make check for push
	if check_push_is_blocked(direction) : return
	# make check for if target position is a stopping obstacle
	if check_blocked(direction): return
	
	
	
	# change grid positon data
	occupied_tiles.remove_at(occupied_tiles.find(self.grid_pos))
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	play_movement_animation(target_position)
	
	
	# emit signal if nountext
	if self is NounText : Global.noun_text_moved.emit()
	if self is Rule : Global.noun_text_moved.emit()
	if self is Operator : Global.noun_text_moved.emit()

func check_push_is_blocked(direction : Vector2) -> bool:
	var pushAlways = Global.RULES["pushAlways"]
	var push = []
	if Global.RULES.has("push") : push.append_array(Global.RULES["push"])
	# put on top
	#z_index = 1
	# check if pushing / can move 
	for p : Noun in push:
		if p.grid_pos == grid_pos + direction:
			p.move(p.grid_pos + direction, self)
			if p.blocked: 
				blocked = true
				play_blocked_animation(direction) 
				return true
				
	for p : Noun in pushAlways:
		if p.grid_pos == grid_pos + direction:
			p.move(p.grid_pos + direction, self)
			if p.blocked: 
				blocked = true
				play_blocked_animation(direction) 
				return true
				
	return false

func check_blocked(direction : Vector2) -> bool:
	var obstacles = Global.RULES["stop"].map(func(e : Noun):return e.grid_pos)
	if obstacles.has(grid_pos + direction) or world.borders.has(Vector2i(grid_pos + direction)):
		blocked = true
		play_blocked_animation(direction) 
		return true
	return false

func check_lose() -> bool:
	if !world.controlled_nouns.has(self): return false
	var obstacles = Global.RULES["lose"].map(func(e : Noun):return e.grid_pos)
	if obstacles.has(grid_pos):
		return true
	return false

func check_open(direction : Vector2) -> bool:
	grid_pos += direction
	
	if !Global.RULES['open'].has(self) : 
		grid_pos -= direction
		return false
	var nouns = get_tree().get_nodes_in_group("NOUN")
	var shut = nouns.filter(func(e:Noun): return Global.RULES['shut'].has(e))
	
	for n : Noun in shut:
		if n.grid_pos == grid_pos:
			n.remove_self()
			return true
	grid_pos -= direction
	return false

func play_movement_animation(target_position : Vector2) -> void:
	# walk anim
	if type == TYPE.CARDINAL and !(self is NounText):
		sprite_2d.flip_h = target_position.x < global_position.x
		if sprite_2d.frame < 3:
			sprite_2d.frame += 1
		else:
			sprite_2d.frame = 0
	
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.15).set_ease(Tween.EASE_IN_OUT)
	tween_playing = true
	
	await tween.finished
	dir = Vector2.ZERO
	
	#await get_tree().create_timer(.025).timeout
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
	sprite_2d.hframes = 1
	match type:
		TYPE.CARDINAL:
			sprite_2d.hframes = 4
			sprite_2d.texture = load("res://Nouns/Assets/bird.png")
			sprite_2d.scale = Vector2(1,1)
		TYPE.WALL:
			sprite_2d.texture = load("res://Nouns/Assets/fence.png")
			sprite_2d.scale = Vector2(1,1)
		TYPE.ROCK:
			sprite_2d.texture = load("res://Nouns/Assets/rock.png")
			sprite_2d.scale = Vector2(1,1)
		TYPE.FLAG:
			sprite_2d.texture = load("res://Nouns/Assets/flag.png")
			sprite_2d.scale = Vector2(1,1)
		TYPE.BOMB:
			sprite_2d.texture =load("res://Nouns/Assets/bomb.png")
			sprite_2d.scale = Vector2(1,1)
		TYPE.KEY:
			sprite_2d.texture =load("res://Nouns/Assets/key.png")
			sprite_2d.scale = Vector2(1,1)

func remove_self() -> void:
	tween_playing = false
	if world.controlled_nouns.has(self):
		world.controlled_nouns.remove_at(world.controlled_nouns.find(self))
		
	for key in Global.RULES:
		if Global.RULES[key].has(self):
			Global.RULES[key].remove_at(Global.RULES[key].find(self))
	queue_free()
