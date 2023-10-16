class_name Player
extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var _animation_player = $AnimationPlayer

enum States { STANDING, FALLING, SLIDING, JUMPING, SWIMMING }
var current_state : States = States.STANDING
var walk_speed : float = 150
var start_slide_speed : float = 60
var fall_speed : float = 120
var gravity : float = 150.0
var jump_speed : float = 75
# TODO need to check if player is in water tile eventually
var is_in_water : bool = false
var is_input_available : bool = true

func _physics_process(delta: float) -> void:

	# Move us downward by gravity per second
	velocity.y += gravity *  delta

	# Get sprite flip state
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	if current_state == States.SLIDING:
		velocity.x = lerp(velocity.x, 0.0, 0.05)
		if velocity.x < 0.4 and velocity.x > -0.4:
			is_input_available = false
			velocity.x = 0
			change_state(States.STANDING)


	# State update based on player interaction
	if is_in_water and current_state != States.SWIMMING:
		change_state(States.SWIMMING)
	elif is_on_floor() and current_state != States.STANDING and current_state != States.SWIMMING and current_state != States.SLIDING:
		change_state(States.STANDING)
	elif !is_on_floor() and current_state != States.FALLING and current_state != States.SWIMMING:
		change_state(States.FALLING)

	if is_input_available:
		# Position updates based on player input
		if Input.is_action_pressed("ui_right"):
			move(delta)
		elif Input.is_action_pressed("ui_left"):
			move(delta, -1)
		elif (Input.is_action_just_released("ui_right") || Input.is_action_just_released("ui_left")) and (current_state == States.STANDING):
			velocity.x = 0
			idle()

		if Input.is_action_just_pressed("ui_up") and current_state == States.STANDING:
			jump()

		# Sliding can happen at multiple times regardless of movement so we check outside of our original loop
		if Input.is_action_just_pressed("ui_select") and !is_in_water and (current_state == States.STANDING || current_state == States.SLIDING):
			toggle_slide()

	move_and_slide()

func move(delta : float, direction : int = 1):
	match current_state:
		States.STANDING:
			walk(delta, direction)
		States.SWIMMING:
			swim(delta, direction)
		States.FALLING:
			fall(delta, direction)

func walk(delta : float, direction : int = 1):
	_animation_player.play("player_walk")
	velocity.x = lerp(0.0, walk_speed * direction, 0.2)
	velocity.y += gravity * delta

func fall(delta : float, direction : int = 1):
	velocity.x = lerp(0.0, fall_speed * direction, 0.2)

func swim(delta : float, direction : int = 1):
	pass

func idle():
	# Get the current state and determine the appropriate idle animation
	var idle_anim : String
	if current_state == States.SLIDING:
		idle_anim = "player_sliding_idle"
	else:
		idle_anim = "player_standing_idle"

	_animation_player.play(idle_anim)
	pass

func jump():
	_animation_player.play("player_jump")
	velocity.y = -jump_speed

func toggle_slide():
	if current_state == States.STANDING:
		change_state(States.SLIDING)
		velocity.x = start_slide_speed * (-1 if sprite.flip_h else 1)

		_animation_player.play("player_start_slide")
		await _animation_player.animation_finished
		idle()

	elif current_state == States.SLIDING:
		change_state(States.STANDING)
	pass

func change_state(new_state : States):
	var prev_state : States = current_state
	if new_state == States.STANDING:
		match prev_state:
			States.SLIDING:
				velocity.x = 0
				_animation_player.play("player_stop_sliding")
				await _animation_player.animation_finished
			States.FALLING:
				velocity.x = 0
				idle()

	current_state = new_state
	is_input_available = true
