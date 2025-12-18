# teleport_component.gd
extends Node
class_name TeleportComponent

# --- Constants & Exports ---

@export var projectile_scene: PackedScene = preload("res://Characters/Components/teleport_projectile.tscn")  # Must be set in Inspector
@export var launch_offset: Vector2 = Vector2(15, 0) # Offset from player to launch projectile
@export var launch_speed_factor: float = 1.0 # Multiplier for player's facing direction

# --- Signals ---

signal teleport_executed(target_position: Vector2)

# --- State Variables ---

var owner_character: CharacterBody2D = null
var active_projectile: TeleportProjectile = null

# --- Initialization ---

func _ready() -> void:
	if not get_parent() is CharacterBody2D:
		push_error("TeleportComponent must be a child of a CharacterBody2D.")
		set_process(false)
		return
		
	owner_character = get_parent()

# --- Public API ---

func is_projectile_active() -> bool:
	return is_instance_valid(active_projectile)

## Handles the initial throw or the teleport execution
func try_teleport(direction: Vector2) -> bool:
	if is_projectile_active():
		# SECOND PRESS: Teleport!
		
		var target_position = active_projectile.global_position
		
		# Clean up the projectile
		active_projectile.queue_free()
		active_projectile = null
		
		# Notify the owner script of the teleport (will update owner_character.global_position)
		teleport_executed.emit(target_position)
		return true
		
	else:
		# FIRST PRESS: Launch the projectile
		if not projectile_scene:
			push_error("TeleportComponent: Projectile scene not set!")
			return false
			
		var projectile = projectile_scene.instantiate() as TeleportProjectile
		active_projectile = projectile
		
		# Determine facing direction (e.g., based on horizontal velocity or sprite flip)
		var facing_direction = Vector2(1, 0)
		if direction.x < 0:
			facing_direction.x = -1
		
		# Set launch parameters
		projectile.direction = facing_direction
		projectile.owner_component = self
		
		# Calculate launch position
		var launch_pos = owner_character.global_position + (launch_offset * facing_direction)
		projectile.global_position = launch_pos
		
		# Add to the scene (usually to the root or a dedicated layer)
		owner_character.get_parent().add_child(projectile)
		return true
		
	return false

## Called by the projectile when its LifeTimer runs out or it hits a wall
func projectile_expired() -> void:
	active_projectile = null
