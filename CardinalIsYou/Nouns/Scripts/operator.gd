class_name Operator
extends Noun

enum OPTYPE {
	NONE, IS, OR, AND
}

@export var operatorType : OPTYPE

var topText : Noun
var botText : Noun
var leftText : Noun
var rightText : Noun

var nounText : NounText # noun that is receiving property
var secNounText : NounText # noun that receiving noun turns into
var rule : Rule # rule that is being applied to noun
var partnerIs : Operator

var prevRule : Rule
var prevNounText : NounText
var prevSecNounText : NounText
func _ready() -> void:
	super._ready()
	
	await get_tree().create_timer(.25).timeout
	apply_rules()
	if !Global.noun_text_moved.is_connected(on_noun_text_moved): 
		Global.noun_text_moved.connect(on_noun_text_moved)

func apply_rules() -> void:
	find_receivers()
	find_rule()
	print(Global.RULES)
	
	if (!rule and !secNounText) or !nounText:
		if !prevRule : return
		print("ok")
		# unset rule
		Global.RULES[prevRule.string].clear()
		# unlight
		prevRule.modulate = Color(0.735, 0.735, 0.735, 1.0)
		if prevNounText: prevNounText.modulate = Color(0.735, 0.735, 0.735, 1.0)
		self.modulate = Color(0.735, 0.735, 0.735, 1.0)
		if prevRule.ruleType == Rule.RULETYPE.YOU:
			set_controlled_noun_to_you()
		return # if proposition incomplete, stop
		
	# light up since valid
	nounText.modulate = Color(1.5,1.5,1.5, 1.0)
	self.modulate = Color(1.5,1.5,1.5, 1.0)
	
	# proposition is valid
	match operatorType:
		OPTYPE.IS:
			apply_is_operator()

func apply_and_operator() -> void:
	find_is()
	
	nounText = partnerIs.nounText
	nounText.match_nouns()
	
	pass

func apply_is_operator() -> void:
	nounText.match_nouns()
	if rule:
		# set rule for every noun
		Global.RULES[rule.string] = nounText.nounArray
		rule.modulate = Color(1.5,1.5,1.5, 1.0)
		# if rule is 'you', allow player to control noun
		if rule.ruleType == Rule.RULETYPE.YOU:
			set_controlled_noun_to_you()
	elif secNounText:
		# make every noun on left the as the same noun on the right
		secNounText.modulate = Color(1.5,1.5,1.5, 1.0)
		var nouns = get_tree().get_nodes_in_group("NOUN")
		for n : Noun in nouns:
			if n.type != nounText.type: continue
			n.type = secNounText.type
			n.match_type()
			secNounText.match_nouns()
	
func set_controlled_noun_to_you() -> void:
	if !rule: return
	world.controlled_nouns = Global.RULES[rule.string]
	print(Global.RULES[rule.string])
	for n : Noun in world.controlled_nouns:
		n.top_level = true

func find_receivers() -> void:
	nounText = null
	var topPos = grid_pos + Vector2(0,-1)
	var leftPos = grid_pos + Vector2(-1,0)
	
	var nounTexts = get_tree().get_nodes_in_group("NOUNTEXT")
	for nt : NounText in nounTexts :
		if nt.grid_pos == topPos:
			rightText = nt
			
			nounText = nt
			prevNounText = nounText
		if nt.grid_pos == leftPos:
			leftText = nt
			
			nounText = nt
			prevNounText = nounText
		
func find_rule() -> void:
	rule = null
	var botPos = grid_pos + Vector2(0,1)
	var rightPos = grid_pos + Vector2(1,0)
	
	var texts = get_tree().get_nodes_in_group("RULE")
	texts.append_array(get_tree().get_nodes_in_group("NOUNTEXT"))
	# check for both nountexts and ruletexts
	for t : Noun in texts:
		if t.grid_pos == botPos or t.grid_pos == rightPos:
			if t is Rule:
				rule = t
				prevRule = rule
			elif t is NounText:
				secNounText = t
				prevSecNounText = secNounText
			
func find_is() -> void:
	var ops = get_tree().get_nodes_in_group("OPERATOR")
	var appliedRules : Array
	for o : Operator in ops:
		if o.type != OPTYPE.IS: continue
		if o.grid_pos == grid_pos - Vector2(0,2) and o.grid_pos == grid_pos - Vector2(2,0):
			partnerIs = o

func match_type() -> void:
	match operatorType:
		OPTYPE.IS:
			sprite_2d.frame = 1
		OPTYPE.AND:
			sprite_2d.frame = 15
	pass

func on_noun_text_moved() -> void:
	apply_rules()
