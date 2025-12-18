# jump_component.gd
extends Node
class_name JumpComponent

# --- Constants & Configuration ---

# Base vertical speed (e.g., -600.0)
@export var jump_velocity: float = -250.0 
@export var jump_max_hold_time: float = 0.5 # Max time (in seconds) the upward force can be applied

@export var wall_jump_angle_degrees: float = 45.0 
@export var wall_jump_velocity: float = -300
@export var wall_jump_duration: float = 0.15 

@export var max_jumps: int = 2

# --- Signals ---

signal jump_initiated(jump_velocity: Vector2) 
signal jump_ended # Signal to notify the Player to stop applying continuous force

# --- State Variables ---

var owner_character: CharacterBody2D = null
var is_restricting_movement: bool = false
var is_in_jump_phase: bool = false # NEW: Tracks if upward force is actively being applied
var time_held: float = 0.0 # Tracks current jump time
var jumps_performed: int = 0
@onready var restriction_timer: Timer = $RestrictionTimer

# --- Initialization ---

func _ready() -> void:
	if not get_parent() is CharacterBody2D:
		push_error("JumpComponent must be a child of a CharacterBody2D.")
		set_process(false)
		return
		
	owner_character = get_parent()
	restriction_timer.timeout.connect(_on_restriction_timer_timeout)

# --- Process Loop (NEW) ---

func _process(delta: float) -> void:
	if is_in_jump_phase:
		time_held += delta
		
		# Check for max hold time limit
		if time_held >= jump_max_hold_time:
			end_jump_phase()

# --- Internal Methods (NEW) ---

func end_jump_phase() -> void:
	if is_in_jump_phase:
		is_in_jump_phase = false
		time_held = 0.0
		jump_ended.emit() # Tell the Player script to stop setting velocity.y

# --- Public API (Checks and Execution) ---

## Attempts a standard ground jump.
func try_jump() -> bool:
	if owner_character.is_on_floor():
		jumps_performed = 0 # Safety reset
	
	if jumps_performed < max_jumps:
		print("Jump: " + str(jumps_performed))
		jumps_performed += 1
		is_in_jump_phase = true
		time_held = 0.0
		jump_initiated.emit(Vector2(owner_character.velocity.x, jump_velocity))
		return true

	return false

## Attempts a wall jump.
func try_wall_jump() -> bool:
	if not can_wall_jump():
		return false

	# Wall jump is usually a fixed vector, so it can exit the jump phase immediately
	if is_in_jump_phase:
		end_jump_phase() 

	var wall_normal: Vector2 = owner_character.get_wall_normal()
	var wall_jump_angle_radians = deg_to_rad(wall_jump_angle_degrees)
	
	var h_force = abs(wall_jump_velocity) * cos(wall_jump_angle_radians)
	var v_force = wall_jump_velocity # We use the negative velocity directly for the vertical component

	var jump_velocity_vector = Vector2(h_force * wall_normal.x, v_force)
	
	
	is_in_jump_phase = true
	time_held = 0.0
	jump_initiated.emit(jump_velocity_vector)
	
	is_restricting_movement = true
	restriction_timer.start(wall_jump_duration)
	
	return true

## Checks if movement input is being restricted (after a wall jump).
func is_restricting() -> bool:
	return is_restricting_movement

## Checks wall jump conditions.
func can_wall_jump() -> bool:
	if owner_character.is_on_floor():
		return false
	if not owner_character.is_on_wall():
		return false
	if is_restricting_movement:
		return false
	# Optional: Add check for input direction away from the wall here if desired
	return true
	
func get_jump_velocity(velocity: Vector2, delta: float) -> Vector2:
	if velocity.y != 0:
		return Vector2(velocity.x, jump_velocity)
	
	end_jump_phase()
	return velocity

# --- Input Handling (NEW) ---
func release_jump_input() -> void:
	# Called by the Player script when the jump button is released
	if is_in_jump_phase:
		end_jump_phase()

func _on_restriction_timer_timeout() -> void:
	is_restricting_movement = false
