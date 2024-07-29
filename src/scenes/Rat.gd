extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var animation_tree = $AnimationTree	
@export var health = 300
@export var damage_cooldown = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attack = false
var patrol_count = 0

var moving = -1
var last_movement

func _process(delta: float) -> void:
	set_process(false) # Stop the _process() function
	
	await get_tree().create_timer(1).timeout # wait 1 second
	var negative = -1
	last_movement = moving
	moving = moving * negative
	patrol_count = patrol_count + 1
	set_process(true) # start again the _process() function


	if patrol_count == 3:
		moving = 0
		patrol_count = 0
		set_process(false) 
		await get_tree().create_timer(5).timeout 
		#animation_tree.set("parameters/idle/blend_position", last_movement)
		moving = last_movement * (-1)
		set_process(true) 
	

func _physics_process(delta):
	var label = $Label
	print(velocity.x,"****" , last_movement)

	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if velocity.x == 0:
		animation_tree.set("parameters/conditions/is_running", false)
		animation_tree.set("parameters/conditions/idle", true)

	else:
		animation_tree.set("parameters/conditions/is_running", true)
		animation_tree.set("parameters/conditions/idle", false)

	
	velocity.x = (moving * SPEED)
	
	animation_tree.set("parameters/idle/blend_position", last_movement)
	animation_tree.set("parameters/run/blend_position", velocity.x)
	
	label.text = str(health)

	if health == 0:	
		queue_free()

	move_and_slide()


