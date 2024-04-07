extends RigidBody2D


const SPEED = 200
var moving_dir : int = 1
var t : float = 0.7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	t += delta
	if position.x >= 350:
		moving_dir = -1
	if position.x <= -350:
		moving_dir = 1
	linear_velocity.x = moving_dir * SPEED
	linear_velocity.y = sin(t) * 50
