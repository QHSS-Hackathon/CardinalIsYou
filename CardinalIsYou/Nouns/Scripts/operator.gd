class_name Operator
extends Noun

enum OPTYPE {
	NONE, IS, OR, AND
}
enum ORTNT {
	NONE, LEFT, RIGHT, BOT, TOP
}

@export var operatorType : OPTYPE
@export var orientation : ORTNT
@export var valid : bool

var topText : Noun
var botText : Noun
var leftText : Noun
var rightText : Noun

var partnerIs : Operator

#var prevRule : Rule
#var prevNounText : NounText
#var prevSecNounText : NounText

func _ready() -> void:
	super._ready()
	
	await get_tree().create_timer(.25).timeout
	apply_rules()
	if !Global.noun_text_moved.is_connected(on_noun_text_moved): 
		Global.noun_text_moved.connect(on_noun_text_moved)

func apply_rules() -> void:
	reset_rule()
	find_receivers()
	find_ends()
	
	var can_run : bool = false
	
	if leftText:
		if !rightText: 
			can_run = false
		else:
			can_run = true
	if topText:
		if !botText and !can_run:
			can_run = false
		else:
			can_run = true
	if !topText and !leftText or !can_run:
		run_condition_invalid()
		return
	
	
	#if (rightText and !leftText) or (!rightText and leftText):

	# light up since valid
	if leftText: leftText.modulate = Color(1.5,1.5,1.5, 1.0)
	if topText: topText.modulate = Color(1.5,1.5,1.5, 1.0)
	self.modulate = Color(1.5,1.5,1.5, 1.0)
	valid = true
	
	# proposition is valid
	match operatorType:
		OPTYPE.IS:
			if leftText and rightText:
				if !(leftText is NounText): 
					run_condition_invalid()
					return
				apply_is_operator(leftText,rightText)
			if topText and botText:
				if !(topText is NounText): 
					run_condition_invalid()
					return
				apply_is_operator(topText,botText)
				
		OPTYPE.AND:
			apply_and_operator()
func reset_rule() -> void:
	if leftText and rightText:
		if !(leftText is NounText): 
			run_condition_invalid()
			return
		if operatorType == OPTYPE.IS: apply_is_operator(leftText,rightText, false)
	if topText and botText:
		if !(topText is NounText): 
			run_condition_invalid()
			return
		if operatorType == OPTYPE.IS: apply_is_operator(topText,botText, false)
	pass
func run_condition_invalid() -> void:
	if rightText : rightText.modulate = Color(0.735, 0.735, 0.735, 1.0)
	if leftText : leftText.modulate = Color(0.735, 0.735, 0.735, 1.0)
	if topText : topText.modulate = Color(0.735, 0.735, 0.735, 1.0)
	if botText : botText.modulate = Color(0.735, 0.735, 0.735, 1.0)
	self.modulate = Color(0.735, 0.735, 0.735, 1.0)
	
	valid = false
	return # if proposition incomplete, stop
		
var at_end : bool
func apply_and_operator() -> void:
	at_end = find_is()
	if !partnerIs:
		run_condition_invalid()
		return
	#await get_tree().process_frame
	if !partnerIs.valid:
		run_condition_invalid()
		return
	
	if at_end:
		if partnerIs.leftText:
			apply_is_operator(partnerIs.leftText, rightText)
			apply_is_operator(partnerIs.leftText, leftText)
		if partnerIs.topText:
			apply_is_operator(partnerIs.topText, botText)
			apply_is_operator(partnerIs.topText, topText)
	pass

func apply_is_operator(textOne : NounText, textTwo : Noun, condition : bool = true) -> void:
	textOne.match_nouns()
	if textTwo is Rule:
		# set rule for every noun
		Global.RULES[textTwo.string] = textOne.nounArray if condition else []
		textTwo.modulate = Color(1.5,1.5,1.5, 1.0) if condition else Color(0.735, 0.735, 0.735, 1.0)
		# if rule is 'you', allow player to control noun
		if textTwo.ruleType == Rule.RULETYPE.YOU:
			set_controlled_noun_to_you(textTwo)
	elif textTwo is NounText:
		# make every noun on left the as the same noun on the right
		textTwo.modulate = Color(1.5,1.5,1.5, 1.0) if condition else Color(0.735, 0.735, 0.735, 1.0)
		var nouns = get_tree().get_nodes_in_group("NOUN")
		for n : Noun in nouns:
			if n.type != textOne.type: continue
			n.type = textTwo.type
			n.match_type()
			textTwo.match_nouns()
	
func set_controlled_noun_to_you(textTwo : Noun) -> void:
	if !textTwo: return
	world.controlled_nouns = Global.RULES[textTwo.string]
	for n : Noun in world.controlled_nouns:
		n.top_level = true

func find_receivers() -> void:
	topText = null
	leftText = null
	var topPos = grid_pos + Vector2(0,-1)
	var leftPos = grid_pos + Vector2(-1,0)
	
	var texts = get_tree().get_nodes_in_group("NOUNTEXT")
	texts.append_array(get_tree().get_nodes_in_group("RULE"))
	for nt : Noun in texts :
		if nt is Operator: continue
		if nt.grid_pos == topPos:
			topText = nt
		if nt.grid_pos == leftPos:
			leftText = nt
			
		
func find_ends() -> void:
	rightText = null
	botText = null
	var botPos = grid_pos + Vector2(0,1)
	var rightPos = grid_pos + Vector2(1,0)
	
	var texts = get_tree().get_nodes_in_group("RULE")
	texts.append_array(get_tree().get_nodes_in_group("NOUNTEXT"))
	# check for both nountexts and ruletexts
	for t : Noun in texts:
		if t is Operator: continue
		if t.grid_pos == botPos:
			botText = t
		if t.grid_pos == rightPos:
			rightText = t
			
func find_is() -> bool:
	partnerIs = null
	var ops = get_tree().get_nodes_in_group("OPERATOR")
	for o : Operator in ops:
		if o.operatorType != OPTYPE.IS: continue
		if o.grid_pos == grid_pos - Vector2(0,2) or  o.grid_pos == grid_pos - Vector2(2,0):
			partnerIs = o
			return true
		elif o.grid_pos == grid_pos + Vector2(0,2) or  o.grid_pos == grid_pos + Vector2(2,0):
			partnerIs = o
			return false
	return false

func match_type() -> void:
	match operatorType:
		OPTYPE.IS:
			sprite_2d.frame = 1
		OPTYPE.AND:
			sprite_2d.frame = 15
	pass

func on_noun_text_moved() -> void:
	apply_rules()
