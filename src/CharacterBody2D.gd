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

var attacks = 0

var sliding = false
var sliding_time = 0
var sliding_cool_down = 0.5

var jumps = 2
var have_double_jump = true
var jumping = false

var sitting = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 800


func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_character(direction)
	on_air(direction)
	on_ground(direction)
	wall_collision()
	handle_jump()
	handle_down()
	on_floor_and_down()
	attack_left(direction)
	attack_right(direction)
	save_last_movement(direction)
	box_collision()
			
			
			
func idle(direction, last_direction):
	if direction == 0:
		animate_stand(last_direction)

func on_floor_and_down():
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	var button_down_released = Input.is_action_just_released("ui_down", true)
		
	if is_on_floor() and button_down_pressed and !sitting:
		sitting = true
				
	if !button_down_pressed or button_down_released:
		sliding = false
		sitting = false

func attack_right(direction):
	#Mover y saltar a la derecha	
	if Input.is_action_just_pressed("ui_attack"):
		if last_movement == 1 and direction == 0 and is_on_floor():
			attacks = attacks + 1
			animate_attack(last_movement, attacks)
			if attacks == 3: attacks = 0
			
			#move boxes
	
			

func attack_left(direction):
	#Mover y saltar a la izquierda
	if Input.is_action_just_pressed("ui_attack"):
		if last_movement == -1 and direction == 0 and is_on_floor():
			attacks = attacks + 1
			animate_attack(last_movement, attacks)
			if attacks == 3: attacks = 0

func handle_jump():	# Handle jump.
	var button_jump_pressed = Input.is_action_just_pressed("ui_accept") 
	
	var button_down_pressed = Input.is_action_pressed("ui_down", true)


	if is_on_floor():
		jumps = 2
		have_double_jump = true
		
	if !is_on_floor() and jumps == 2:
		jumps = jumps - 1

	if is_on_wall(): 
		jumps = 1
		
	
	if button_down_pressed and Input.is_action_just_pressed("ui_accept"):
		sitting = false
		sliding = true

	if button_jump_pressed and !button_down_pressed and jumps > 0:
		jumping = true
		jumps = jumps - 1
		velocity.y = JUMP_VELOCITY
	if is_playing_by_name("jump"): jumping = true
	else: jumping = false

func handle_down():	# Handle jump.
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	var button_jump_just_pressed = Input.is_action_just_pressed("ui_accept", true)
	
	if button_down_pressed and button_jump_just_pressed:
		sliding = true
	if button_down_pressed: 
		sitting = true
	else: 
		sitting = false
	
			
func move_character(direction):	
	if sliding or sitting: 
		move_and_slide()
		return #

	if direction:
		if is_playing_by_name("attack"):
			velocity.x = (direction * SPEED) / 5
		else:
			velocity.x = (direction * SPEED)
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()

func save_last_movement(direction):
	#Guarda el último movimiento si fue derecha o izquierda
	last_animation = _animation_player.current_animation
	if(direction != 0):
		last_movement = direction		

func box_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var impulse = -collision.get_normal()
			collider.apply_central_impulse(impulse)
			$SlidingCollision.disabled = true
			if collider.name.contains("Jumper"): velocity.y = JUMP_VELOCITY * 2
			
func wall_collision():
	if is_on_wall() and !is_on_floor():
		velocity = velocity / 3
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

		
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		body.get_tree().call_deferred("reload_current_scene")

func animate_air(direction):		
	if direction > 0:
		_animation_player.play("falling_down_right")
	elif direction < 0:
		_animation_player.play("falling_down_left")

func on_air(direction):
	
	if is_playing_by_name("sit"): return #
	
	if is_on_wall():
		if direction == 1:
			_animation_player.play("wall_slide_right")
		if direction == -1:
			_animation_player.play("wall_slide_left")	
		return #
		
	if !is_on_floor() and !jumping:
		animate_air(last_movement)
	
	if !is_on_floor() and !is_on_wall_only():
		if sliding: 
			animate_sliding(last_movement)
			#velocity.y = 0
			if last_movement == 1: velocity.x = 200.0
			elif last_movement == -1: velocity.x = -200.0
					
			await get_tree().create_timer(sliding_cool_down).timeout
			sliding = false	

		if direction == 0 and jumping:
			animate_jump(last_movement)
		else:
			animate_jump(direction)
	
func animate_run(direction):
	if direction > 0:
		_animation_player.play("run_right")
	elif direction < 0:
		_animation_player.play("run_left")
		
func animate_stand(direction):
	if direction > 0:
		_animation_player.play("stand_right")
	elif direction < 0:
		_animation_player.play("stand_left")

func animate_jump(direction):
	if direction > 0:
		_animation_player.play("jump_right")

	elif direction < 0:
		_animation_player.play("jump_left")

func animate_sit(direction):
	if !sliding and !last_animation.contains("sit_down") and !is_playing_by_name("sit_down"):
		if direction > 0:
			_animation_player.play("sit_down_right")
		elif direction < 0:
			_animation_player.play("sit_down_left")

func animate_sliding(direction):
	if direction > 0:
		_animation_player.play("floor_slide_right")
	elif direction < 0:
		_animation_player.play("floor_slide_left")
		
func animate_attack(direction, attack_number):
	var attack_right_animation = "attack_right_" + str(attack_number)
	var attack_left_left = "attack_left_" + str(attack_number)
	
	if direction > 0:
		_animation_player.play(attack_right_animation)
			
	elif direction < 0:
		_animation_player.play(attack_left_left)

			

func on_ground(direction):
	if !sliding: velocity.x = 0
	
	if is_playing_by_name("attack"):
		var overlapping = $AnimatedSprite2D/Sword.get_overlapping_bodies()
		print($AnimatedSprite2D/Sword.get_overlapping_areas(),"areas")
		print($AnimatedSprite2D/Sword.get_overlapping_bodies(),"bodies")
		var enemy_layer_collision = $AnimatedSprite2D/Sword.get_collision_mask_value(7)
		
		#print(overlapping)
		for body in overlapping:
			print(body.name)
			if body.name == "Rat":
				var health = body.get_tree().get_root().get_node("Game/Rat").get("health")
				print(body.get_tree().get_root().get_node("Game/Rat").get("health"))
				var demaged_health = int(health) - 1
				if(_animation_player.current_animation_length > 0.4):
					body.get_tree().get_root().get_node("Game/Rat").set("health", demaged_health)
				print(body.get_tree().get_root().get_node("Game/Rat").get("health"))

			if body.name.contains("Dummy"): 
				body.queue_free()
			var impulse = 0
			if last_movement == 1: impulse = 60
			if last_movement == -1: impulse = -60		
			
			if body is RigidBody2D: body.apply_central_impulse(Vector2(impulse, 0))
	
	if not is_playing_by_name("attack"): attacks = 0

	if is_playing_by_name("attack"): #importante
		return #

	# Sliding
	if sliding and is_on_floor():
		animate_sliding(last_movement)
		if last_movement == 1: velocity.x = 200.0
		elif last_movement == -1: velocity.x = -200.0

		await get_tree().create_timer(sliding_cool_down).timeout
		sliding = false	

	# Sitting
	if sitting and is_on_floor():
		if direction == 0:
			animate_sit(last_movement)
	else:
		if is_on_floor() and direction == 0 and !sitting:
			animate_stand(last_movement)
					
		if is_on_floor() and direction != 0:
			animate_run(direction)

func is_playing_by_name(animation_type):
	return _animation_player.is_playing() == true and (_animated_sprite.animation.contains(animation_type) or _animation_player.current_animation.contains(animation_type))
