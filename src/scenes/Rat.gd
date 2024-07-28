extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var health = 300

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var label = $Label
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	var animation_tree = $AnimationTree
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/is_running", false)
	label.text = str(health)
	
	if health == 0:
		print(health)
	
		queue_free()
	#animation_tree["parameters/conditions/is_walking"] = false
	#animation_tree["parameters/conditions/idle"] = true	
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
