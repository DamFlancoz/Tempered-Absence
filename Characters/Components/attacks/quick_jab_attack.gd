# QuickJabAttack.gd
extends Node
class_name QuickJabAttack

@export var damage_value: int = 10 # Damage is configurable per attack scene instance
@onready var attack_animator: AnimationPlayer = $AttackAnimator
@onready var hitbox: Area2D = $HitBox

var owner_node: Node = null # Reference to the CharacterBody2D that owns this attack

signal attack_finished # Signal back to the manager/owner

func set_owner_reference(new_owner: Node) -> void:
	# Set the reference to the CharacterBody2D (Player)
	owner_node = new_owner
	hitbox.set_meta("hit_source", owner_node)

## Called by AttackComponent Manager
func perform_attack() -> bool:
	if attack_animator.is_playing():
		return false
		
	if not owner_node:
		push_error("QuickJabAttack owner_node not set!")
		return false

	# 1. Set damage metadata
	hitbox.set_meta("damage_amount", damage_value)
	hitbox.set_meta("hit_occurred", false)
	hitbox.set_meta("one_time_hit", true)
	
	# 2. Play the animation which handles timing, position, and shape
	attack_animator.play("attack") # Note the generic name "attack"
	
	return true

func _ready() -> void:
	attack_animator.animation_finished.connect(_on_attack_animation_finished)

func _on_attack_animation_finished(anim_name: StringName) -> void:
	# Ensure the hitbox is fully disabled
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox.set_meta("hit_occurred", false)
	
	attack_finished.emit()
