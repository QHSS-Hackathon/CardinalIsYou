class_name UI
extends CanvasLayer

@export var puzzles : Array
@export var current_level : int = 1 # will always be current puzzle index + 1

@onready var game = get_tree().get_first_node_in_group("GAME")
@onready var main_menu: Control = $MainMenu
@onready var timer: Control = %Timer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $PauseMenu
@onready var win_menu: Control = $WinMenu
@onready var time_report: Label = %TimeReport

var minutes : int = 0
var seconds : int = 0

func _ready() -> void:
	timer.hide()
	pause_menu.hide()
	win_menu.hide()
	%PuzzleLabel.hide()
	puzzles = [
		load("res://Puzzles/Scenes/puzzle5.tscn").instantiate(), # 1
		load("res://Puzzles/Scenes/puzzle1.tscn").instantiate(), # 2
		load("res://Puzzles/Scenes/puzzle0.tscn").instantiate(), # 3
		load("res://Puzzles/Scenes/puzzle2.tscn").instantiate(), # 4
		load("res://Puzzles/Scenes/puzzle6.tscn").instantiate(), # 5
		load("res://Puzzles/Scenes/puzzle4.tscn").instantiate(), # 6
		load("res://Puzzles/Scenes/puzzle7.tscn").instantiate(), # 7
		load("res://Puzzles/Scenes/puzzle3.tscn").instantiate(), # 8
	]
	%PuzzleLabel.text = "Puzzle      " + str(current_level)

func load_level(index : int) -> void:
	# go to win screen
	if index > puzzles.size() - 1:
		%TimerNode.stop()
		win_menu.show()
		%TimeReport.text = "You     beat   the   game  in\n" + %TimeLabel.text + "\nWell    Done"
		return
	
	# clear puzzles
	var puzzleNodes = get_tree().get_nodes_in_group("PUZZLE")
	for p : Puzzle in puzzleNodes:
		p.process_mode = Node.PROCESS_MODE_DISABLED
		p.queue_free()
		p.controlled_nouns.clear()
	
	var nextPuzzle = puzzles[index]
	game.add_child(nextPuzzle)
	nextPuzzle.load_default()
	
	var nouns = get_tree().get_nodes_in_group("NOUN")
	nouns.append_array(get_tree().get_nodes_in_group("NOUNTEXT"))
	nouns.append_array(get_tree().get_nodes_in_group("RULE"))
	nouns.append_array(get_tree().get_nodes_in_group("OPERATOR"))
	for n : Noun in nouns:
		n.world = get_tree().get_first_node_in_group("WORLD")
	#await get_tree().create_timer(2).timeout
	#game.process_mode = Node.PROCESS_MODE_DISABLED
	#game.add_child(puzzles[index])
	%PuzzleLabel.text = "Puzzle      " + str(current_level)
	anim.play("flash_timer")
	
	

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		handle_pause()
	if event.is_action_released("ui_text_caret_line_end"):
		current_level += 1
		load_level(current_level - 1)
	
func handle_pause() -> void:
	%PauseTitle.text = "Pause"
	pause_menu.visible = !pause_menu.visible

func _on_start_pressed() -> void:
	handle_pause()
	%PauseTitle.text = ""
	main_menu.hide()
	timer.show()
	game.add_child(puzzles[current_level - 1])
	anim.play("flash_timer")


func _on_timer_timeout() -> void:
	seconds += 1
	if seconds >= 60:
		seconds = 0
		minutes += 1
	var secString = str(seconds)
	if seconds < 10 : secString = "0" + secString
	
	
	var minString = str(minutes)
	if minutes < 10 : minString = "0" + minString
	%TimeLabel.text = minString + ":" + secString


func _on_timer_mouse_entered() -> void:
	anim.stop()
	anim.play("RESET")
	%TimeLabel.show()
	%PuzzleLabel.show()
	%PuzzleLabel.text = "Puzzle      " + str(current_level)
func _on_timer_mouse_exited() -> void:
	%TimeLabel.hide()
	%PuzzleLabel.hide()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flash_timer":
		return

func _on_quit_pressed() -> void:
	get_tree().quit()
