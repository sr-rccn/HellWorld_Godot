extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")
@onready var state_machine2 = $AnimationTree.get("tree_root")

@export var health = 20
@export var damage_cooldown = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false
var patrol_count = 0

var moving = -1
var last_movement

func _process(delta: float) -> void:
	set_process(false) # Stop the _process() function
	await wait_one_secs_move()
	set_process(true) # start again the _process() function
	
	set_process(false) 
	await wait_five_secs_move()
	set_process(true) 
	delta = delta

func _physics_process(delta):
	var label = $Label

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = (moving * SPEED)
	
	label.text = str(health)

	#if health <= 0:	
		#state_machine.travel("death")
		
	animate(velocity)
	move_and_slide()

func animate(new_velocity):
	if health <= 0:
		queue_free()
	else:
		animation_tree.set("parameters/run/blend_position", new_velocity.x)
	state_machine.travel("run")


func wait_one_secs_move():
	await get_tree().create_timer(1).timeout
	var negative = -1
	last_movement = moving
	moving = moving * negative
	patrol_count = patrol_count + 1
	
func wait_five_secs_move():
	if patrol_count == 3:
		moving = 0
		patrol_count = 0

		await get_tree().create_timer(5).timeout 
		moving = last_movement * (-1)
