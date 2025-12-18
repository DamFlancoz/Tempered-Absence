extends CharacterBody2D

const SPEED = 50
var player
var death = false
#@onready var animation = get_node("AnimatedSprite2D")
@onready var attack_component: Node = $AttackComponent

#func _ready() -> void:
	#animation.play("Idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if death == true:
		return
	
	player = get_node("../Player")
	
	attack_component.perform_attack("QuickJabAttack")
		# If the attack was successfully started (i.e., not already attacking)
		#print("Executing Quick Jab...")
		
		# Optional: Lock movement or trigger a character animation here 
		# while the attack animation plays.
		
		# Since the attack component uses AnimationPlayer, it handles its own timing
		# and cleanup.
		#pass
	#var direction = (player.position - self.position).normalized()
	##animation.play("Jump")
	#if direction.x > 0:
		#pass
		##animation.flip_h = true
	#else:
		#pass
		##animation.flip_h = false
			#
	#velocity.x = direction.x * SPEED
	move_and_slide()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		die()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#body.health -= 3
		pass
		die()

func die():
	pass
	#animation.play("Death")
	#death = true
	#get_node("CollisionShape2D").disabled = true
	#await animation.animation_finished
	#self.queue_free()
