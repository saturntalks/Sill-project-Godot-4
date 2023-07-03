extends CharacterBody3D


const SPEED = 1.5
const JUMP_VELOCITY = 3
const SENSITIVITY = 0.002
var gravity = 10
const BOB_FREQ = 2.0
const BOB_AMP = 0.06
var t_bob = 0.0
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var floorcast = $FloorDetect
@onready var footstepSound = $Footstep
func _ready():
		#Hide cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 6.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 6.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
	#Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	move_and_slide()
func _process(delta):
	if floorcast.is_colliding():
		var walkingSurface = floorcast.get_collider()#.get_parent()
		if walkingSurface != null:
			var terraingroup = walkingSurface.get_groups()[0]
			processFloorSound(terraingroup)

var distanceFootstep := 0.0
var playFootstep := 4


func processFloorSound(group : String):
	if playFootstep != 100 and (int(velocity.x) !=0) || int(velocity.z) !=0:
		distanceFootstep += .1
	else:
		footstepSound.stop()
	if distanceFootstep > playFootstep and is_on_floor():
		match group:
			"Floor":
				footstepSound.play() #= load("res://Project files/FX/step/Step.ogg")
				
		footstepSound.pitch_scale = randf_range(.5, .9)
		footstepSound.play()
		distanceFootstep = 0.0
	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
