class_name Operator
extends Noun

enum OPTYPE {
	NONE, IS, OR, AND
}

@export var operatorType : OPTYPE

var nounText : NounText # noun that is receiving property
var rule : Rule # rule that is being applied to noun

var prevRule : Rule
var prevNounText : NounText

func _ready() -> void:
	super._ready()
	
	await get_tree().create_timer(.25).timeout
	apply_rules()
	Global.noun_text_moved.connect(on_noun_text_moved)

func apply_rules() -> void:
	find_noun()
	find_rule()
	
	if !rule or !nounText:
		# unset rule
		Global.RULES[prevRule.string] = []
		# unlight
		if prevRule: prevRule.modulate = Color(0.735, 0.735, 0.735, 1.0)
		if prevNounText: prevNounText.modulate = Color(0.735, 0.735, 0.735, 1.0)
		self.modulate = Color(0.735, 0.735, 0.735, 1.0)
		if prevRule.ruleType == Rule.RULETYPE.YOU:
			set_controlled_noun_to_you()
		return # if proposition incomplete, stop
		
	# proposition is valid
	nounText.match_nouns()
	Global.RULES[rule.string] = nounText.nounArray
	# light up since valid
	rule.modulate = Color(1.5,1.5,1.5, 1.0)
	nounText.modulate = Color(1.5,1.5,1.5, 1.0)
	self.modulate = Color(1.5,1.5,1.5, 1.0)
	
	# if rule is 'you', allow player to control noun
	if rule.ruleType == Rule.RULETYPE.YOU:
		set_controlled_noun_to_you()
func set_controlled_noun_to_you() -> void:
	world.controlled_nouns = Global.RULES[rule.string]
	print(Global.RULES[rule.string])
	for n : Noun in world.controlled_nouns:
		n.top_level = true

func find_noun() -> void:
	nounText = null
	var topPos = grid_pos + Vector2(0,-1)
	var leftPos = grid_pos + Vector2(-1,0)
	
	var nounTexts = get_tree().get_nodes_in_group("NOUNTEXT")
	for nt : NounText in nounTexts :
		if nt.grid_pos == topPos or nt.grid_pos == leftPos:
			nounText = nt
			prevNounText = nounText
		
func find_rule() -> void:
	rule = null
	var botPos = grid_pos + Vector2(0,1)
	var rightPos = grid_pos + Vector2(1,0)
	
	var ruleTexts = get_tree().get_nodes_in_group("RULE")
	for rt : Rule in ruleTexts:
		if rt.grid_pos == botPos or rt.grid_pos == rightPos:
			rule = rt
			prevRule = rule
			
	pass

func match_type() -> void:
	match operatorType:
		OPTYPE.IS:
			sprite_2d.frame = 1
	pass

func on_noun_text_moved() -> void:
	apply_rules()
