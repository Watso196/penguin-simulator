class_name Player
extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var _animation_player = $AnimationPlayer

var states = PackedStringArray(["standing", "falling", "sliding", "jumping", "swimming", "idle"])
var current_state : String = "standing"
var walk_speed : float = 500.0
var gravity : float = 150.0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if self.is_on_floor() and current_state != "standing":
		change_state("standing")

	if Input.is_action_pressed("ui_right"):
		move(delta, false)
	if Input.is_action_pressed("ui_left"):
		move(delta, true)
	if Input.is_action_pressed("ui_up"):
		jump()
	if Input.is_action_pressed("ui_select"):
		toggle_slide()
	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
		get_state()

	move_and_slide()

func move(delta : float, flip_sprite : bool):
	if current_state == "standing":
		walk(delta, flip_sprite)
	elif current_state == "swimming":
		swim(delta, flip_sprite)
	elif current_state == "sliding":
		slide()
	elif current_state == "falling":
		#TODO need to figure out how being in the air changes movement
		pass

func walk(delta : float, flip_sprite : bool):
	sprite.flip_h = flip_sprite
	_animation_player.play("player_walk")
	velocity.x = walk_speed * delta * (-1 if flip_sprite else 1)
	velocity.y += gravity * delta


func swim(delta : float, flip_sprite : bool):
	pass

func slide():
	pass

func idle():
	pass

func jump():
	pass

func toggle_slide():
	if current_state != "sliding":
		change_state("sliding")
	else:
		get_state()
	pass

# TODO need to update get_state to actually find appropriate state to use?
func get_state():
	change_state("idle")
	pass

func change_state(new_state : String):
	if states.has(new_state):
		current_state = new_state
	else:
		print("Error! New state is not a defined state: ", new_state)
		print("Available states:")
		for state in states:
			print(state)
