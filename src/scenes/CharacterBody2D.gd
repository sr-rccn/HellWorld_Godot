extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var _animation_player = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	#_animation_player.play("idle_right")
	if not is_on_floor():
		velocity.y += gravity * delta
	
	await get_tree().create_timer(3).timeout

	move_and_slide()
