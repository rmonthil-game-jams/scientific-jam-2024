extends Node

# parameters
const SOURCE_PARTICLE_INTERVAL: float = 1.0
const SOURCE_Y_VARIANCE: float = 16.0
const PARTICLE_INITIAL_VELOCITY: float = 64.0

const DEVIATOR_ACCELERATION: float = 2e3
const ACCELERATOR_ACCELERATION: float = 8e2

const ENERGY_INCREASE_FACTOR: float = 20
const ENERGY_DECREASE_RATE: float = 2e1

const ParticleA = preload("res://remi/ams/particle_a.tscn")

#const LED_NUMBER: int = 4
#var current_led_on_number: int = 0

const LED2_NUMBER: int = 5
var current_led2_on_number: int = 0

# output
var is_turning: bool = false

func _ready():
	_particle_source()
	# fade in animation
	$World.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property($World, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)

func _process(delta: float):
	if is_turning:
		var new_right: Vector2 = ($World.get_global_mouse_position() - $World/AcceleratorInput.global_position).normalized()
		var angle_diff: float = $World/AcceleratorInput.transform.x.angle_to(new_right)
		if angle_diff > 0:
			$World/ProgressBar/ProgressBar.value += ENERGY_INCREASE_FACTOR * angle_diff/TAU
			$World/AcceleratorInput.rotation = new_right.angle()
	$World/ProgressBar/ProgressBar.value -= ENERGY_DECREASE_RATE * delta
	# update
	$World/Accelerator.gravity_direction = Vector2.RIGHT.rotated(-0.5 * PI/2 * $World/ProgressBar/ProgressBar.value/100.0)

var is_sourcing: bool = true
func _particle_source():
	_spawn_particle()
	await get_tree().create_timer(SOURCE_PARTICLE_INTERVAL).timeout
	if is_sourcing:
		_particle_source()

func _spawn_particle():
	var new_particle: RigidBody2D = null
	new_particle = preload("res://remi/ams/particle_a.tscn").instantiate()
	new_particle.position = $World/Source.position
	new_particle.position.y += randf_range(-1.0, 1.0) * SOURCE_Y_VARIANCE
	$World.add_child(new_particle)

# signals

func _on_boundaries_body_exited(body: RigidBody2D):
	body.queue_free()
	$AudioStreamPlayerParticleFree.play()

func _on_accelerator_input_button_down():
	is_turning = true
	$AudioStreamPlayerManivelle.play()

func _on_accelerator_input_button_up():
	is_turning = false
	$AudioStreamPlayerManivelle.stop()

func _on_source_input_pressed():
	_spawn_particle()

func _on_target_body_entered(body):
	$AudioStreamPlayerSuccess2.play()
	# change state of game
	LabState.ams_done = true
	# transition
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://remi/lab/lab.tscn")

func _on_obstacles_body_entered(body):
	body.queue_free()
	$AudioStreamPlayerParticleFree.play()

func _on_target_2_body_entered(body):
	body.queue_free()
	# more
	if current_led2_on_number < LED2_NUMBER:
		$AudioStreamPlayerSuccess1.play()
		current_led2_on_number += 1
		$World/Leds2.get_child(current_led2_on_number).show()
		if current_led2_on_number == LED2_NUMBER:
			$AudioStreamPlayerSuccess2.play()
			is_sourcing = false
			# animation
			for index in range(current_led2_on_number):
				var tween: Tween = create_tween()
				tween.tween_property($World/Leds2.get_child(index), "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
				tween.tween_property($World/Leds2.get_child(index), "modulate", Color.GREEN, 0.0625).set_trans(Tween.TRANS_QUAD)
				tween.set_loops(3)
			$World/LauncherInput/TextureButton.disabled = false

func _on_launcher_input_pressed():
	$AudioStreamPlayerFire.play()
	var new_particle: RigidBody2D = null
	new_particle = preload("res://remi/ams/particle_a.tscn").instantiate()
	new_particle.position = $World/Source2.position
	$World.add_child(new_particle)
	# enable deviator
	is_charging = false
	$World/DeviatorInput/TextureButton.disabled = false
	$World/DeviatorInput/TextureButton.focus_mode = Control.FOCUS_ALL

var is_charging: bool = false
func _on_deviator_input_pressed():
	$AudioStreamPlayerChargeUp.play()
	$World/DeviatorInput/TextureButton.disabled = true
	$World/DeviatorInput/TextureButton.focus_mode = Control.FOCUS_NONE
	$World/LauncherInput/TextureButton.disabled = true
	$World/LauncherInput/TextureButton.focus_mode = Control.FOCUS_NONE
	is_charging = true
	# anim
	var tween: Tween = create_tween()
	tween.tween_property($World/ProgressBar2/ProgressBar, "value", 100.0, 0.5)
	await tween.finished
	$AudioStreamPlayerChargeDown.play()
	# effect
	$World/Deviator.gravity_direction = Vector2.DOWN
	$World/Deviator.gravity *= 2.0
	for body in $World/Deviator.get_overlapping_bodies():
		body.linear_velocity = Vector2.ZERO
	tween = create_tween()
	tween.tween_property($World/ProgressBar2/ProgressBar, "value", 0.0, 1.0)
	await tween.finished
	$World/Deviator.gravity_direction = Vector2.RIGHT
	$World/Deviator.gravity /= 2.0
	# re enable
	$World/LauncherInput/TextureButton.disabled = false
	$World/LauncherInput/TextureButton.focus_mode = Control.FOCUS_ALL
	is_charging = false
	$World/DeviatorInput/TextureButton.disabled = false
	$World/DeviatorInput/TextureButton.focus_mode = Control.FOCUS_ALL
