extends CharacterBody2D

@onready var tilemap : TileWorld = get_tree().get_first_node_in_group("TILEMAP")
@onready var tile_size = tilemap.floor.tile_set.tile_size.x

var grid_pos : Vector2
var input_queue : Array
var dir : Vector2
var tween_playing : bool

func _ready() -> void:
	grid_pos = Vector2(0,0)
	global_position = tilemap.floor.map_to_local(grid_pos)

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if tween_playing:return
	if event.is_action_pressed("ui_up",true):
		dir = Vector2(0,-1)
	elif event.is_action_pressed("ui_down",true):
		dir = Vector2(0,1)
	elif event.is_action_pressed("ui_left",true):
		dir = Vector2(-1,0)
	elif event.is_action_pressed("ui_right",true):
		dir = Vector2(1,0)
		
	if dir == Vector2.ZERO: return
	
	move(grid_pos + dir)
	
func move(new_pos: Vector2) -> void:
	var direction: Vector2 = new_pos - grid_pos
	
	grid_pos += direction
	var target_position: Vector2 = (Vector2(grid_pos) + Vector2.ONE * 1/2) * tile_size
	
	#tween_playing = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.2).set_ease(Tween.EASE_IN_OUT)
	tween_playing = true
	
	await tween.finished
	dir = Vector2.ZERO
	await get_tree().create_timer(.1).timeout
	tween_playing = false
