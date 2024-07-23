extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _animation_player = $AnimatedSprite2D/AnimationPlayer
#@onready var _sword_shape = $AnimatedSprite2D/Sword/CollisionShape2D
#@onready var jumper = $"../Jumper/CollisionShape2D"
	
const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const FLOOR_NORMAL = Vector2.UP
var last_movement = 0
var last_animation = ""
var has_double_jump = false
var jumps = 0
var sit_cooldown = 500
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 800


func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	#var DownPressed = Input.is_action_pressed("ui_down", true)
	#var DownReleased = Input.is_action_just_released("ui_down", true)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta


	idle(direction)
	
	wall_collision(direction)
	handle_jump(direction)
	on_floor_and_down(direction)
	attack_left(direction)
	attack_right(direction)
	on_floor_and_jump(direction)
	move_and_jump_left(direction)
	move_and_jump_right(direction)
	move_character(direction)
	save_last_movement(direction)
	box_collision()


			
func idle(direction):
	var animation_type = _animated_sprite.animation
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	
	if(is_playing_by_name("sit_up")):
		return #
		
	if is_on_floor() and direction == 0 and !button_down_pressed:
		if animation_type.contains("jump") :
			stand(direction)
				
		if !animation_type.contains("attack"):
			stand(direction)
				
		if !is_playing_by_name("attack"):
			stand(direction)

func cancel_attack_animation():
		#Cancela animación despues de atacar
	if is_playing_by_name("attack"):
		_animated_sprite.stop()
		
		if last_movement == 1:
			_animated_sprite.play("stand_right")
		if last_movement == -1:
			_animated_sprite.play("stand_left")
	
func on_floor_and_down(direction):
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	var button_down_released = Input.is_action_just_released("ui_down", true)

	var button_jump_just_pressed = Input.is_action_just_pressed("ui_accept")
	
	if is_on_floor() and button_down_pressed:
		if button_jump_just_pressed:

			if last_movement == 1:
				velocity.x += 1000
				velocity.y = JUMP_VELOCITY*2
				_animated_sprite.play("floor_slide_right")
				_animation_player.play("floor_slide_right")
				
			if last_movement == -1:
				velocity.x += -1000
				velocity.y = JUMP_VELOCITY *2
				_animated_sprite.play("floor_slide_left")
				_animation_player.play("floor_slide_left")
				
		if button_down_released:
			if last_movement == 1: _animated_sprite.play("sit_up_right")
			else: _animated_sprite.play("sit_up_left")
			
		if button_down_pressed and !is_playing_by_name("floor_slide"):	
				if last_movement == 1: _animated_sprite.play("sit_down_right")
				if last_movement == -1: _animated_sprite.play("sit_down_left")

func on_floor_and_jump(direction):
	if direction == 0 and !is_on_floor():
		if last_movement == -1:
			_animated_sprite.play("jump_left")
		if last_movement == 1:
			_animated_sprite.play("jump_right")
	
func move_and_jump_left(direction):
	if !is_on_wall():
		if direction == -1 and !is_on_floor():
			_animated_sprite.play("jump_left")

	
func move_and_jump_right(direction):
	if !is_on_wall():
		if direction == 1 and !is_on_floor():
			_animated_sprite.play("jump_right")
	#if is_on_wall():
		#var shape = $CollisionShape2D
		#shape.appl
	
func attack_right(direction):
	#Mover y saltar a la derecha
	if Input.is_action_pressed("ui_attack"):
		if last_movement == 1 and direction == 0 and is_on_floor():
			_animated_sprite.play("attack_right")
			_animation_player.play("attack_right")

			#move boxes
			var overlapping = $AnimatedSprite2D/Sword.get_overlapping_bodies()
			for rigid_body in overlapping:
				if rigid_body is RigidBody2D:
					if rigid_body.name.contains("Dummy"): 
						rigid_body.queue_free()
					rigid_body.apply_central_impulse(Vector2(90, 0))
					
func attack_left(direction):
	#Mover y saltar a la izquierda
	if Input.is_action_pressed("ui_attack"):
		if last_movement == -1 and direction == 0 and is_on_floor():
			_animated_sprite.play("attack_left")
			_animation_player.play("attack_left")
			
			var overlapping = $AnimatedSprite2D/Sword.get_overlapping_bodies()
			for rigid_body in overlapping:
				if rigid_body is RigidBody2D:
					if rigid_body.name.contains("Dummy"): rigid_body.queue_free()
					rigid_body.apply_central_impulse(Vector2(-90, 0))
		#else:
			#if _animated_sprite.animation != "attack_left":
				#_animated_sprite.play("stand_left")
				
func handle_jump(direction):	# Handle jump.
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	
	if is_on_floor():
		jumps = 0
		has_double_jump = true
		
	if !is_on_floor() and jumps > 1:
		has_double_jump = false
		
	if is_on_wall():
		velocity = velocity / 2
		has_double_jump = true
		jumps = 1

	if Input.is_action_just_pressed("ui_accept") and has_double_jump and !button_down_pressed:
		jumps = jumps + 1
		velocity.y = JUMP_VELOCITY
			
		if is_on_wall():
			jumps = jumps + 2
		
		if direction == 1:
			_animated_sprite.play("jump_right")
		if direction == -1:
			_animated_sprite.play("jump_left")
			
		has_double_jump = true
		# Double jump
		if jumps < 1:
			jumps = jumps + 1
			velocity.y = JUMP_VELOCITY
	

func move_character(direction):
		if direction:
			velocity.x = (direction * SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
			
		if Input.is_action_pressed("ui_right") and is_on_floor():
			_animated_sprite.play("run_right")
			
		if Input.is_action_pressed("ui_left") and is_on_floor():
			_animated_sprite.play("run_left")
		
		move_and_slide()


func save_last_movement(direction):
	#Guarda el último movimiento si fue derecha o izquierda
	if(direction != 0):
		last_movement = direction		


func box_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var impulse = -collision.get_normal()
			collider.apply_central_impulse(impulse)
			
			if collider.name.contains("Jumper"): velocity.y = JUMP_VELOCITY * 2

func wall_collision(direction):
	if is_on_wall():
		velocity = velocity / 3
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

	if direction == 0:
		if is_on_wall() and direction == 0 and last_movement == 1:
			_animated_sprite.play("wall_slide_right")
		if is_on_wall() and direction == 0 and last_movement == -1:
			_animated_sprite.play("wall_slide_left")
	else:	
		if is_on_wall() and direction == 1:
			_animated_sprite.play("wall_slide_right")
		if is_on_wall() and direction == -1:
			_animated_sprite.play("wall_slide_left")
	
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		body.get_tree().call_deferred("reload_current_scene")
		
func stand(direction):
	if direction == 0 and last_movement == 1:
		_animated_sprite.play("stand_right")
		_animation_player.play("stand_right")
	if direction == 0 and last_movement == -1:
		_animated_sprite.play("stand_left")
		_animation_player.play("stand_right")

		
func is_playing_by_name(animation_type):
	return _animated_sprite.is_playing() == true and _animated_sprite.animation.contains(animation_type)
