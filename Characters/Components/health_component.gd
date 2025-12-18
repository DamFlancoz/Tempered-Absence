# HealthComponent.gd
extends Node

## --- Constants & Exports ---

@export var max_health: int = 100
@export var is_invulnerable: bool = false

## --- State Variables ---

var current_health: int = 0

## --- Signals ---

signal health_changed(new_health: int, old_health: int)
signal took_damage(amount: int, hit_source: Node)
signal died

## --- Node References ---

@onready var hurt_box: Area2D = $HurtBox

############### Warning when using the compoenent:
# 1. Access CollisionShape2D by right clicking and enabling editable child components.
# 2. Make sure to Click on Shape drop down arrow and make it unique so the common component
#    and the used instance are not connected.

func _ready() -> void:
	current_health = max_health
	
	# 1. Connect the HurtBox to the damage handler
	# The HurtBox checks if it overlaps with an AttackComponent's HitBox
	hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	
	# 2. Set up collision layers (Crucial for filtering)
	# The HurtBox should be on the 'HurtBox' layer and check the 'HitBox' mask.
	# You must configure these layers in Project Settings -> Layer Names -> 2D Physics
	# For example: Layer 2 = HurtBox, Layer 4 = HitBox
	hurt_box.set_collision_layer_value(3, true)  # Set on HurtBox Layer
	hurt_box.set_collision_mask_value(4, true)   # Check HitBox Mask

## --- Public API ---

func take_damage(amount: int, hit_source: Node) -> void:
	if is_invulnerable:
		return

	var old_health = current_health
	current_health = max(0, current_health - amount)

	health_changed.emit(current_health, old_health)
	took_damage.emit(amount, hit_source)

	if current_health <= 0:
		died.emit()
	
	# Optional: Start invulnerability timer here

## --- Component Callback ---

func _on_hurt_box_area_entered(area: Area2D) -> void:
	# Check if the colliding area is an AttackComponent's HitBox
	if area.has_meta("damage_amount"):
		print("Damaged")
		var damage = area.get_meta("damage_amount")
		var hit_source = area.get_meta("hit_source")
		
		take_damage(damage, hit_source)
		
		# Optional: Disable the HitBox immediately after hitting to prevent multi-hit
		if area.has_meta("one_time_hit"):
			area.set_deferred("monitoring", false) # Disables the HitBox
