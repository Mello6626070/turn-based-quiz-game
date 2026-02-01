class_name PlayerMovementController extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var wall_ray_cast: RayCast2D = $WallRayCast
@onready var dash_timer: Timer = $DashTimer
@onready var camera_container: Node2D = $CameraContainer
@onready var camera_2d: Camera2D = $CameraContainer/Camera2D
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

@export var player_class_data: PlayerClass
@export var walking_sfx: AudioStream
@export var jumping_sfx: AudioStream
@export var dash_sfx: AudioStream
@export var falling_sfx: AudioStream

enum STATE {
	FALL,
	GROUND,
	JUMP,
	DOUBLE_JUMP,
	WALL_SLIDE,
	WALL_JUMP,
	DASH,
	BATTLE
}

const FALL_GRAVITY: float =  1500.0
const FALL_VELOCITY: float = 500.0
const WALK_VELOCITY: float = 300.0
const JUMP_VELOCITY: float = -500.0
const JUMP_DECELERATION: float = 1500.0
const DOUBLE_JUMP_VELOCITY: float = -450.0
const WALL_SLIDE_GRAVITY: float = 300.0
const WALL_SLIDE_VELOCITY: float = 500.0
const WALL_JUMP_LENGHT: float = 30.0
const WALL_JUMP_VELOCITY: float = -500.0
const DASH_LENGHT: float = 150.0
const DASH_VELOCITY: float = 600.0

var current_state: STATE = STATE.FALL
var previous_state: STATE
var can_double_jump: bool = false
var facing_direction: float
var saved_position: Vector2 = Vector2.ZERO
var can_dash: bool = false
var dash_jump_buffer: bool = false
var button_direction: float
var jump_button: bool = false
var dash_button: bool = false

func _ready() -> void:
	set_state(current_state)

func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func set_state(to_state: STATE) -> void:
	previous_state = current_state
	current_state = to_state
	sfx_player.stop()
	match current_state:
		STATE.FALL: init_fall()
		STATE.GROUND: init_ground()
		STATE.JUMP: init_jump()
		STATE.DOUBLE_JUMP: init_double_jump()
		STATE.WALL_SLIDE: init_wall_slide()
		STATE.WALL_JUMP: init_wall_jump()
		STATE.DASH: init_dash()

func process_state(delta: float) -> void:
	match current_state:
		STATE.FALL: fall(delta)
		STATE.GROUND: ground()
		STATE.JUMP, STATE.DOUBLE_JUMP, STATE.WALL_JUMP: jump(delta)
		STATE.WALL_SLIDE: wall_slide(delta)
		STATE.DASH: dash()

func fall(delta: float) -> void:
	if animated_sprite_2d.animation == "flip" and animated_sprite_2d.frame == 3:
		animated_sprite_2d.play("fall")
	velocity.y = move_toward(velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
	handle_movement()
	if is_on_floor():
		set_state(STATE.GROUND)
	elif Input.is_action_just_pressed("jump") or jump_button:
		if coyote_timer.time_left > 0:
			set_state(STATE.JUMP)
		elif can_double_jump:
			set_state(STATE.DOUBLE_JUMP)
	elif is_input_toward_facing() and can_wall_slide():
		set_state(STATE.WALL_SLIDE)
	elif Input.is_action_just_pressed("dash") and can_dash:
		set_state(STATE.DASH)

func init_fall() -> void:
	sfx_player.stop()
	sfx_player.stream = falling_sfx
	sfx_player.play()
	if previous_state != STATE.DOUBLE_JUMP:
		animated_sprite_2d.play("fall")
	if previous_state == STATE.GROUND:
		coyote_timer.start()
	print("FALL")

func handle_movement(input_direction: float = 0) -> void:
	if input_direction == 0:
		if button_direction != 0:
			input_direction = button_direction
		else:
			input_direction = signf(Input.get_axis("left", "right"))
	set_facing_direction(input_direction)
	velocity.x = input_direction * WALK_VELOCITY

func set_facing_direction(direction: float) -> void:
	if direction:
		animated_sprite_2d.flip_h = direction < 0
		facing_direction = direction
		wall_ray_cast.position.x = direction * absf(wall_ray_cast.position.x)
		wall_ray_cast.target_position.x = direction * abs(wall_ray_cast.target_position.x)
		wall_ray_cast.force_raycast_update()

func init_ground() -> void:
	jump_button = false
	print("GROUND")
	sfx_player.stop()
	can_double_jump = true
	can_dash = true

func ground() -> void:
	if (Input.get_axis("left", "right") or button_direction != 0) and velocity.x != 0:
		animated_sprite_2d.play("run")
		if !sfx_player.playing:
			sfx_player.stream = walking_sfx
			sfx_player.play()
	else:
		sfx_player.stop()
		animated_sprite_2d.play("idle")
	handle_movement()
	
	if not is_on_floor():
		set_state(STATE.FALL)
	elif Input.is_action_just_pressed("jump") or jump_button:
		set_state(STATE.JUMP)
	elif Input.is_action_just_pressed("dash"):
		set_state(STATE.DASH)

func jump(delta: float) -> void:
	velocity.y = move_toward(velocity.y, 0, JUMP_DECELERATION * delta)
	if current_state == STATE.WALL_JUMP:
		var distance: float = abs(position.x - saved_position.x)
		if distance >= WALL_JUMP_LENGHT or can_wall_slide():
			current_state = STATE.JUMP
		else:
			handle_movement(facing_direction)
	
	if current_state != STATE.WALL_JUMP:
		handle_movement()
	
	if (Input.is_action_just_released("jump") or velocity.y >= 0):
		velocity.y = 0
		set_state(STATE.FALL)
	elif Input.is_action_just_pressed("jump") or jump_button:
		set_state(STATE.DOUBLE_JUMP)
	elif Input.is_action_just_pressed("dash") and can_dash:
		set_state(STATE.DASH)

func init_jump() -> void:
	jump_button = false
	animated_sprite_2d.play("jump")
	sfx_player.stop()
	sfx_player.stream = jumping_sfx
	sfx_player.play(0.38)
	velocity.y = JUMP_VELOCITY
	coyote_timer.stop()

func init_double_jump() -> void:
	animated_sprite_2d.play("flip")
	sfx_player.stop()
	sfx_player.stream = jumping_sfx
	sfx_player.play(0.38)
	velocity.y = DOUBLE_JUMP_VELOCITY
	can_double_jump = false

func init_wall_slide() -> void:
	animated_sprite_2d.play("wall_slide")
	velocity.y = 0
	can_double_jump = true
	can_dash = true

func wall_slide(delta: float) -> void:
	velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, WALL_SLIDE_GRAVITY * delta)
	handle_movement()
	
	if is_on_floor():
		set_state(STATE.GROUND)
	elif not can_wall_slide():
		set_state(STATE.FALL)
	elif Input.is_action_just_pressed("jump"):
		set_state(STATE.WALL_JUMP)
	elif Input.is_action_just_pressed("dash"):
		set_facing_direction(-facing_direction)
		set_state(STATE.DASH)

func init_dash() -> void:
	if dash_timer.time_left > 0:
		current_state = previous_state
		return
	animated_sprite_2d.play("dash")
	sfx_player.stop()
	sfx_player.stream = dash_sfx
	sfx_player.play(0.38)
	velocity.y = 0
	var input: float
	
	if button_direction != 0:
		input = signf(button_direction)
	else:
		input = signf(Input.get_axis("left", "right"))
	
	if previous_state != STATE.WALL_SLIDE:
		set_facing_direction(input)
	velocity.x = facing_direction * DASH_VELOCITY
	saved_position = position
	can_dash = previous_state == STATE.GROUND or previous_state == STATE.WALL_SLIDE
	dash_jump_buffer = false

func dash() -> void:
	dash_timer.start()
	if is_on_floor():
		coyote_timer.start()
	if Input.is_action_just_pressed("jump"):
		dash_jump_buffer = true
	var distance: float = absf(position.x - saved_position.x)
	if distance >= DASH_LENGHT or signf(get_last_motion().x) != facing_direction:
		if dash_jump_buffer and coyote_timer.time_left > 0:
			set_state(STATE.JUMP)
		elif is_on_floor():
			set_state(STATE.GROUND)
		else:
			set_state(STATE.FALL)
	elif can_wall_slide():
		set_state(STATE.WALL_SLIDE)

func can_wall_slide() -> bool:
	return is_on_wall_only() and wall_ray_cast.is_colliding()

func init_wall_jump() -> void:
	animated_sprite_2d.play("jump")
	velocity.y = WALL_JUMP_VELOCITY
	set_facing_direction(-facing_direction)
	saved_position = position

func is_input_toward_facing() -> bool:
	return sign(Input.get_axis("left", "right")) == facing_direction

func _on_sfx_player_finished() -> void:
	if current_state == STATE.GROUND:
		if velocity.x != 0:
			sfx_player.stream = walking_sfx
			sfx_player.play()
	elif current_state == STATE.FALL:
		sfx_player.stream = falling_sfx
		sfx_player.play()

func _on_right_button_button_down() -> void:
	button_direction = 1.0


func _on_left_button_button_down() -> void:
	button_direction = -1.0


func _on_left_button_button_up() -> void:
	button_direction = 0


func _on_right_button_button_up() -> void:
	button_direction = 0


func _on_jump_button_button_down() -> void:
	jump_button = true

func _on_jump_button_button_up() -> void:
	jump_button = false

func _on_dash_button_pressed() -> void:
	if can_dash:
		set_state(STATE.DASH)
