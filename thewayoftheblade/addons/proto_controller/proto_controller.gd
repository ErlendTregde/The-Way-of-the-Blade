# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
@export var max_jumps : int = 2
@export var dash_speed : float = 20.0
@export var dash_duration : float = 0.2
@export var dash_cooldown : float = 0.5
@export var input_dash : String = "dash"
@export var dash_damage: int = 1

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var jump_count : int = 0
var is_dashing : bool = false
var dash_timer : float = 0.0
var dash_cooldown_timer : float = 0.0
var dash_direction : Vector3 = Vector3.ZERO
var dash_icon: TextureRect
var dash_label: Label
var already_hit: Array = []


## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var camera: Camera3D = $Head/Camera3D
@onready var sword_anim: AnimationPlayer = $Head/Camera3D/Sword/AnimationPlayer



func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	dash_icon = get_node("UI/DashIcon")
	dash_label = get_node("UI/DashIcon/Label")  # Make sure you have a Label inside DashIcon
	dash_label.visible = false
	dash_icon.modulate.a = 1.0
	add_to_group("players")

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	if not is_dashing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		sword_anim.play("slash")
		$Head/Camera3D/Sword.slash()


	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if is_on_floor():
			jump_count = 0  # <-- Reset jump count here
		else:
			velocity += get_gravity() * delta


	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and jump_count < max_jumps:
			velocity.y = jump_velocity
			jump_count += 1


	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		dash_icon.modulate.a = 0.4
		dash_label.visible = true
		dash_label.text = str(ceil(dash_cooldown_timer))
	else:
		dash_icon.modulate.a = 1.0
		dash_label.visible = false


	# Dash start
	if Input.is_action_just_pressed(input_dash) and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		$Head/Camera3D/Sword.slash()

		# Capture full 3D look direction at start of dash
		dash_direction = -camera.global_transform.basis.z.normalized()

	# Dash movement (locked direction)
	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * dash_speed

		# Dash damage detection (Godot 4.x style)
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = collider.shape
		query.transform = global_transform
		query.motion = velocity * delta
		query.collision_mask = 1  # Match this with your enemy layer

		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_shape(query)

		for hit in result:
			var body = hit.get("collider")
			if body and body.is_in_group("enemies") and not already_hit.has(body):
				if body.has_method("take_damage"):
					body.take_damage(dash_damage)
					already_hit.append(body)

		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector3.ZERO
			already_hit.clear()



	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func on_enemy_killed() -> void:
	print("Enemy killed. Resetting dash.")
	dash_cooldown_timer = 0.0


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
