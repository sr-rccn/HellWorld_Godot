extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _animation_player = $AnimatedSprite2D/AnimationPlayer
@onready var _sword_shape = $AnimatedSprite2D/Area2D/CollisionShape2D

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const FLOOR_NORMAL = Vector2.UP
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
		if Input.is_action_just_pressed("ui_attack"):
			_animated_sprite.play("attack_right")
			_animation_player.play("attack_right")

			#move boxes
			var overlapping = $AnimatedSprite2D/Area2D.get_overlapping_bodies()
			for rigid_body in overlapping:
				if rigid_body is RigidBody2D:
					rigid_body.apply_central_impulse(Vector2(90, 0))

					#rigid_body.queue_free()
					print(rigid_body.mass)
			#move boxes

			#for area in overlapping:
				#var parent = area.get_parent()
				#parent.queue_free()

		else:
			if _animated_sprite.animation != "attack_right":
				_animated_sprite.play("stand_right")	
				
	if direction == 1 and !is_on_floor():
		_animated_sprite.play("jump_right")

		
	#Mover y saltar a la izquierda
	if last_movement == -1 and direction == 0 and is_on_floor():
		if Input.is_action_just_pressed("ui_attack"):
			_animated_sprite.play("attack_left")
			_animation_player.play("attack_left")
			
			var overlapping = $AnimatedSprite2D/Area2D.get_overlapping_bodies()
			for rigid_body in overlapping:
				if rigid_body is RigidBody2D:
					rigid_body.apply_central_impulse(Vector2(-90, 0))

					#rigid_body.queue_free()
					print(rigid_body.mass)
			#for area in overlapping:
				#var parent = area.get_parent()
				#parent.queue_free()
			#
		else:
			if _animated_sprite.animation != "attack_left":
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


	#Cancela animación despues de atacar
	if _animated_sprite.is_playing() == false and _animated_sprite.animation.contains("attack"):
		_animated_sprite.stop()
		if last_movement == 1:
			_animated_sprite.play("stand_right")
		if last_movement == -1:
			_animated_sprite.play("stand_left")


	#Guarda el último movimiento si fue derecha o izquierda
	if(direction != 0):
		last_movement = direction
		

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var impulse = -collision.get_normal()
			print(impulse)
			collider.apply_central_impulse(impulse)
			
	move_and_slide()


