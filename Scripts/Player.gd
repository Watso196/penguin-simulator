class_name Player
extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var _animation_player = $AnimationPlayer

enum States { STANDING, FALLING, SLIDING, JUMPING, SWIMMING }
var current_state : States = States.STANDING
var walk_speed : float = 150
var start_slide_speed : float = 60
var gravity : float = 150.0
var jump_speed : float = 150
# TODO need to check if player is in water tile eventually
var is_in_water : bool = false

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		# Move us downward by gravity per second
		velocity.y += gravity *  delta

	if current_state == States.SLIDING:
		velocity.x = lerp(velocity.x, 0.0, 0.05)
		if velocity.x < 0.4 and velocity.x > -0.4:
			velocity.x = 0
			change_state(States.STANDING)


	# State update based on player interaction
	if is_in_water and current_state != States.SWIMMING:
		change_state(States.SWIMMING)
	elif is_on_floor() and current_state != States.STANDING and current_state != States.SWIMMING and current_state != States.SLIDING:
		change_state(States.STANDING)
	elif !is_on_floor() and current_state != States.FALLING and current_state != States.SWIMMING:
		change_state(States.FALLING)

	# Position updates based on player input
	if Input.is_action_pressed("ui_right"):
		move(delta, false)
	elif Input.is_action_pressed("ui_left"):
		move(delta, true)
	elif Input.is_action_just_released("ui_right") || Input.is_action_just_released("ui_left"):
		velocity.x = 0
		idle()

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		jump()

	# Sliding can happen at multiple times regardless of movement so we check outside of our original loop
	if Input.is_action_just_pressed("ui_select") and !is_in_water and (current_state == States.STANDING || current_state == States.SLIDING):
		toggle_slide()

	move_and_slide()

func move(delta : float, flip_sprite : bool):
	if current_state == States.STANDING:
		walk(delta, flip_sprite)
	elif current_state == States.SWIMMING:
		swim(delta, flip_sprite)
	elif current_state == States.FALLING:
		#TODO need to figure out how being in the air changes movement
		pass

func walk(delta : float, flip_sprite : bool):
	sprite.flip_h = flip_sprite
	_animation_player.play("player_walk")
	velocity.x = lerp(0.0, walk_speed * (-1 if flip_sprite else 1), 0.2)
#	velocity.x = walk_speed * (-1 if flip_sprite else 1)
	velocity.y += gravity * delta

func swim(delta : float, flip_sprite : bool):
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
	velocity.y = lerp(0.0, -jump_speed, 0.4)

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

# TODO need to update get_state to actually find appropriate state to use? do we need this?
func get_state():
	pass

func change_state(new_state : States):
	var prev_state : States = current_state
	if new_state == States.STANDING:
		if prev_state == States.SLIDING:
			_animation_player.play("player_stop_sliding")
			await _animation_player.animation_finished
			idle()
	# Failover in case state doesn't have transition
	current_state = new_state
