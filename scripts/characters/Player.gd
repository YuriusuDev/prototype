extends CharacterBody3D


var camera_sensitivity = 0.25
var camera_zoom_sensitivity = 0.5
var camera_direction = Vector2.ZERO

var character_movement_speed = 10.0
var character_movement_acceleration = 5.0
var character_rotation_speed = 10.0
var character_rotation_angle = Vector3.BACK
var character_direction = Vector3.ZERO
var character_last_direction = Vector3.BACK

@onready var camera_pivot = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var character_avatar = $Swat
@onready var character_animation = $Swat/AnimationPlayer


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_direction.x = event.relative.x * camera_sensitivity
		camera_direction.y = event.relative.y * camera_sensitivity
	if event.is_action_pressed("zoom_in"):
		camera_pivot.spring_length += camera_zoom_sensitivity
	if event.is_action_pressed("zoom_out"):
		camera_pivot.spring_length -= camera_zoom_sensitivity


func _physics_process(delta):
	camera_pivot.rotation.x += camera_direction.y * delta
	camera_pivot.rotation.x = clamp(rotation.x, -PI / 6, PI / 3)
	camera_pivot.rotation.y -= camera_direction.x * delta
	camera_direction = Vector2.ZERO

	character_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	character_direction = camera.global_basis.z * character_direction.y + camera.global_basis.x * character_direction.x
	character_direction.y = 0.0
	character_direction = character_direction.normalized()

	velocity = velocity.move_toward(character_direction * character_movement_speed, character_movement_acceleration * delta)

	move_and_slide()

	if character_direction.length() > 0.0:
		character_last_direction = character_direction
	character_rotation_angle = Vector3.BACK.signed_angle_to(character_last_direction, Vector3.UP)
	character_avatar.global_rotation.y = lerp_angle(character_avatar.rotation.y, character_rotation_angle, character_rotation_speed * delta)

	if is_on_floor() and not character_animation.current_animation == "pistol_whip":
		if velocity.length() > 0.0:
			character_animation.play("pistol_walk")
		else:
			character_animation.play("pistol_idle")

	if Input.is_action_just_pressed("trigger"):
		character_animation.play("pistol_whip")
