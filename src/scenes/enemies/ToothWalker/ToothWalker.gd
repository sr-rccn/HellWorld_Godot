extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = $AnimationTree.get("parameters/playback")

@export var health = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	var label = $Label
	label.text = str(health)
	
	if health <= 0:
		state_machine.travel("death")
		if state_machine.get_current_node() == "End":
			queue_free()
	else:
		state_machine.travel("idle")
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

