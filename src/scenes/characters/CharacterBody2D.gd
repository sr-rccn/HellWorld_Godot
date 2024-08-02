extends CharacterBody2D


@onready var _animation_tree = $AnimationTree
@onready var _state_machine = $AnimationTree.get("parameters/playback")

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const FLOOR_NORMAL = Vector2.UP
var last_movement = 0
var last_animation = ""
var attacks = 0
var sliding = false
var sliding_cool_down = 0.5
var jumps = 2
var have_double_jump = true
var jumping = false
var sitting = false
var gravity = 800


func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	add_gravity(delta)
	move_character(direction)
	on_air()
	on_ground(direction)
	handle_jump()
	handle_down()
	on_floor_and_down()
	attack(direction)
	save_last_movement(direction)
	box_collision()
			
func add_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		

func on_floor_and_down():
	var button_down_pressed = Input.is_action_pressed("ui_down", true)
	var button_down_released = Input.is_action_just_released("ui_down", true)
		
	if is_on_floor() and button_down_pressed and !sitting:
		sitting = true
				
	if !button_down_pressed or button_down_released:
		sliding = false
		sitting = false

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
	last_animation = _state_machine.get_current_node()
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
			
func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		body.get_tree().call_deferred("reload_current_scene")

func on_air():
	_animation_tree.set("parameters/jump/blend_position", last_movement)
	if is_playing_by_name("sit"): return #
	if is_on_wall():
		_state_machine.travel("wall_slide")
		return #
	
	#if !is_on_floor() and !jumping:
		#_state_machine.travel("")
		#animate_air(last_movement)
	
	if !is_on_floor() and !is_on_wall_only():
		if sliding: 
			_state_machine.travel("floor_slide")
			#velocity.y = 0
			if last_movement == 1: velocity.x = 200.0
			elif last_movement == -1: velocity.x = -200.0
					
			await get_tree().create_timer(sliding_cool_down).timeout
			sliding = false	
		_state_machine.travel("jump")


func attack(direction):
	if Input.is_action_just_pressed("ui_attack"):
	#Mover y saltar a la derecha	
		if direction == 0 and is_on_floor():
			attacks = attacks + 1
			var animation_name = "attack_" + str(attacks)
			_state_machine.travel(animation_name)
			if attacks == 3: attacks = 0


func on_ground(direction):
	_animation_tree.set("parameters/idle/blend_position", last_movement)
	_animation_tree.set("parameters/crounch/blend_position", last_movement)
	_animation_tree.set("parameters/stand_up/blend_position", last_movement)
	_animation_tree.set("parameters/floor_slide/blend_position", last_movement)	
	
	_animation_tree.set("parameters/run/blend_position", direction)
	_animation_tree.set("parameters/wall_slide/blend_position", direction)
	_animation_tree.set("parameters/jump/blend_position", last_movement)

	
	_animation_tree.set("parameters/attack_1/blend_position", last_movement)
	_animation_tree.set("parameters/attack_2/blend_position", last_movement)
	_animation_tree.set("parameters/attack_3/blend_position", last_movement)

	if !sliding: velocity.x = 0
	
	if is_playing_by_name("attack"):
		var overlapping = $AnimatedSprite2D/Sword.get_overlapping_bodies()
		for body in overlapping:
			if body.name == "Rat":
				var health = body.get_tree().get_root().get_node("Game/Rat").get("health")
				var damaged_health = int(health) - 1
				body.get_tree().get_root().get_node("Game/Rat").set("health", damaged_health)

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
		_state_machine.travel("floor_slide")
		if last_movement == 1: velocity.x = 200.0
		elif last_movement == -1: velocity.x = -200.0

		await get_tree().create_timer(sliding_cool_down).timeout
		sliding = false	

	# Sitting
	if sitting and is_on_floor():
		if direction == 0:
			_state_machine.travel("crounch")
	else:
		if is_on_floor() and direction == 0 and !sitting and !is_playing_by_name("idle"):
			_state_machine.travel("idle")
		if is_on_floor() and direction != 0:
			_state_machine.travel("run")

func is_playing_by_name(animation_type):
	return _state_machine.get_current_node().contains(animation_type)
