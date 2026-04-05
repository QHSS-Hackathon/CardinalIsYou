class_name Operator
extends Noun

enum OPTYPE {
	NONE, IS, OR, AND
}

@export var operatorType : OPTYPE

var nounText : NounText # noun that is receiving property
var rule : Rule # rule that is being applied to noun

var prevRule : Rule

func _ready() -> void:
	super._ready()
	apply_rules()
	Global.noun_text_moved.connect(on_noun_text_moved)

func apply_rules() -> void:
	print("p")
	find_noun()
	find_rule()
	
	if !rule or !nounText: return # if proposition incomplete, stop
	nounText.match_nouns()
	Global.RULES[rule.string] = nounText.nounArray
	
	if rule.ruleType == Rule.RULETYPE.YOU:
		world.controlled_nouns = Global.RULES[rule.string]
	pass

func find_noun() -> void:
	var topPos = grid_pos + Vector2(0,-1)
	var leftPos = grid_pos + Vector2(-1,0)
	
	var nounTexts = get_tree().get_nodes_in_group("NOUNTEXT")
	for nt : NounText in nounTexts :
		if nt.grid_pos == topPos or nt.grid_pos == leftPos:
			nounText = nt
		
func find_rule() -> void:
	if rule: prevRule = rule
	var botPos = grid_pos + Vector2(0,1)
	var rightPos = grid_pos + Vector2(1,0)
	
	var ruleTexts = get_tree().get_nodes_in_group("RULE")
	for rt : Rule in ruleTexts:
		if rt.grid_pos == botPos or rt.grid_pos == rightPos:
			rule = rt
	
	pass

func match_type() -> void:
	match operatorType:
		OPTYPE.IS:
			sprite_2d.frame = 1
	pass

func on_noun_text_moved() -> void:
	apply_rules()
