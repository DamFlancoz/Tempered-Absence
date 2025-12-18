extends CharacterBody2D

const AIR_RESISTANCE_SPEED = 1.0
const WALK_SPEED = 300.0

@onready var dash_component: Node = $HDashComponent
@onready var slam_component: Node = $SlamComponent
@onready var health_component: Node = $HealthComponent
@onready var jump_component: Node = $JumpComponent
@onready var teleport_component: Node = $TeleportComponent

func _ready() -> void:
	dash_component.dash_started.connect(_on_dash_started)
	dash_component.dash_finished.connect(_on_dash_finished)
	slam_component.dash_started.connect(_on_dash_started)
	slam_component.dash_finished.connect(_on_dash_finished)
	health_component.died.connect(_on_died)
	jump_component.jump_initiated.connect(_on_jump_initiated)
	jump_component.jump_ended.connect(_on_jump_ended)
	teleport_component.teleport_executed.connect(_on_teleport_executed)

func _physics_process(delta: float) -> void:
	# 1. Continuous Jump Force Application (NEW LOGIC)
	if jump_component.is_in_jump_phase:
		velocity = jump_component.get_jump_velocity(velocity, delta)
	
	# 2. Gravity applied only if NOT actively holding jump AND not dashing
	if not dash_component.is_dashing() and not slam_component.is_dashing() and not jump_component.is_in_jump_phase: # <-- UPDATED CHECK
		velocity += get_gravity() * delta

	handle_movement_input()

	if dash_component.is_dashing():
		velocity = dash_component.get_dash_velocity()
	if slam_component.is_dashing():
		velocity = slam_component.get_dash_velocity()
	move_and_slide()

func handle_movement_input() -> void:
	# Only allow movement/jump if not dashing
	if (
		dash_component.is_dashing()
		or slam_component.is_dashing()
		or jump_component.is_restricting()
		):
		return

	var input_x: float = Input.get_axis("move_left", "move_right")
	var input_y: float = Input.get_axis("move_up", "move_down")
	if Input.is_action_just_pressed("teleport"): # Assuming an "teleport" input action exists
		teleport_component.try_teleport(Vector2(input_x, input_y))
		return
	elif Input.is_action_just_pressed("dash"):
		if input_x:
			dash_component.try_dash(Vector2(input_x, 0).normalized())
			return
		elif input_y:
			slam_component.try_dash(Vector2(0, input_y).normalized())
			return
	elif Input.is_action_just_pressed("jump"):
		if jump_component.try_wall_jump():
			return
		elif jump_component.try_jump() :
			return
	elif Input.is_action_just_released("jump"): # <-- CHECK RELEASE
		jump_component.release_jump_input() # Tell component to end the phase
	
	if input_x:
		# Apply normal horizontal movement
		velocity.x = input_x * WALK_SPEED
	elif is_on_floor():
		# Come to a stop on ground
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
	elif not is_on_floor():
		# Come to a stop in air more slowly
		velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE_SPEED)

func _on_dash_started(direction: Vector2, speed: float) -> void:
	print("Dash started! Play sound effect.")

func _on_dash_finished() -> void:
	# Restore normal horizontal movement based on current input
	velocity.x = Input.get_axis("move_left", "move_right") * WALK_SPEED

func _on_slam_started(direction: Vector2, speed: float) -> void:
	print("Slam started! Play sound effect.")

func _on_slam_finished() -> void:
	print("Slam finished! Resume control.")
	velocity.y = 0

func _on_died():
	print("Player has died!")
	queue_free()
	get_tree().change_scene_to_file("res://main.tscn")

func _on_jump_initiated(jump_velocity: Vector2) -> void:
	# Apply the velocity received from the component
	velocity = jump_velocity
	
	# Wall jump applies X-velocity, Ground jump applies current X-velocity.
	# The continuous velocity.y application is handled in _physics_process
	print("Jump initiated!")

func _on_jump_ended() -> void: # <-- NEW CALLBACK
	# This function is called when the max hold time is reached OR the button is released.
	# Crucially, we MUST ensure the character starts falling immediately (applies gravity).
	
	# By letting the velocity.y drop out of the JUMP_VELOCITY loop in _physics_process, 
	# and letting gravity take over, the jump naturally begins to decay.
	pass
	
func _on_teleport_executed(target_position: Vector2) -> void:
	# Execute the instantaneous movement
	global_position = target_position
	
	# Crucial: Reset velocity upon teleport to prevent slide/fall from old position's velocity
	velocity = Vector2.ZERO
	
	print("Player instantly teleported to ", target_position)
