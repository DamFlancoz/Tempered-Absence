# teleport_projectile.gd
extends Area2D
class_name TeleportProjectile

@export var speed: float = 800.0
@export var max_flight_time: float = 0.8
@export var collision_mask_value: int = 1 # Example: Collide with World/Ground layer

var direction: Vector2 = Vector2.ZERO
var owner_component: Node = null # Reference back to the TeleportComponent

# --- Initialization ---

func _ready() -> void:
	# Set up collision based on export variable
	set_collision_mask_value(collision_mask_value, true)
	
	# Start timer for auto-destruction
	$LifeTimer.start(max_flight_time)
	speed = 300

# --- Physics & Movement ---

func _physics_process(delta: float) -> void:
	print(speed)
	print(direction)
	global_position += direction * speed * delta

# --- Signal Handling ---

func _on_life_timer_timeout() -> void:
	# Tell the component this projectile is finished
	if is_instance_valid(owner_component):
		owner_component.projectile_expired()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Because of our Mask settings, 'body' will only be the World/Ground.
	# We stop the projectile so it stays at the wall for the player to TP to.
	speed = 0
	
	# Optional: Move it slightly back from the wall so the player 
	# doesn't get stuck inside the collision geometry when teleporting.
	var wall_normal = (global_position - body.global_position).normalized()
	global_position += wall_normal * 2.0
	
	# Disable collision so it doesn't trigger again
	$CollisionShape2D.set_deferred("disabled", true)
