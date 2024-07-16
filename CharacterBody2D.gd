extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
var last_movement = 0
var has_double_jump = false
var jumps = 0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_floor():
		jumps = 0
		has_double_jump = true
		
	if !is_on_floor() and jumps > 1:
		has_double_jump = false
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and has_double_jump :
		jumps = jumps + 1
		velocity.y = JUMP_VELOCITY
		
		
		if direction == 1:
			_animated_sprite.play("jump_right")
		if direction == -1:
			_animated_sprite.play("jump_left")
		# Double jump
		if jumps < 1:
			jumps = jumps + 1
			velocity.y = JUMP_VELOCITY
	
	
	#Controla animación al caer del salto
	
	#Mover y saltar a la derecha
	if last_movement == 1 and direction == 0 and is_on_floor():
		_animated_sprite.play("stand_right")
	if direction == 1 and !is_on_floor():
		_animated_sprite.play("jump_right")
		
	#Mover y saltar a la izquierda
	if last_movement == -1 and direction == 0 and is_on_floor():
		_animated_sprite.play("stand_left")
	if direction == -1 and !is_on_floor():
		_animated_sprite.play("jump_left")
	
	if direction == 0 and !is_on_floor():
		if last_movement == -1:
			_animated_sprite.play("jump_left")
		if last_movement == 1:
			_animated_sprite.play("jump_right")
	


	
	if Input.is_action_pressed("ui_right") and is_on_floor():
		_animated_sprite.play("run_right")
	if Input.is_action_pressed("ui_left") and is_on_floor():
		_animated_sprite.play("run_left")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if(direction != 0):
		last_movement = direction
		
	print(last_movement)
	move_and_slide()
