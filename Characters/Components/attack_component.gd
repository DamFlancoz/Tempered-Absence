# AttackComponent.gd (Manager)
extends Node
class_name AttackComponent

# Dictionary to hold all specific attack nodes (e.g., {"QuickJabAttack": QuickJabAttackNode})
var active_attacks: Dictionary = {}

@onready var owner_node: Node = get_parent()

func _ready() -> void:
	# This loop correctly finds and stores the instantiated child nodes.
	for child in get_children():
		# Check if the child is a valid attack node instance
		if child is Node and child.has_method("perform_attack"):
			# The child's NODE NAME (e.g., "QuickJabAttack") becomes the dictionary key
			active_attacks[child.name] = child
			
			# Initialization steps...
			if child.has_method("set_owner_reference"):
				child.set_owner_reference(owner_node)

	if active_attacks.is_empty():
		print("AttackComponent: No specific attack scenes found as children.")

## --- Public API (Called by Player Input) ---

func perform_attack(attack_name: String) -> bool:
	if active_attacks.has(attack_name):
		return active_attacks[attack_name].perform_attack()
	
	print("Attack '%s' not found in AttackComponent." % attack_name)
	return false
