extends Node

# parameters
const SOURCE_PARTICLE_INTERVAL: float = 1.0
const SOURCE_Y_VARIANCE: float = 64.0
const PARTICLE_INITIAL_VELOCITY: float = 64.0

const DEVIATOR_ACCELERATION: float = 2e3
const ACCELERATOR_ACCELERATION: float = 8e2

const ENERGY_INCREASE_FACTOR: float = 2e-2
const ENERGY_DECREASE_RATE: float = 2e1

const ParticleA = preload("res://remi/ams/particle_a.tscn")
const ParticleB = preload("res://remi/ams/particle_b.tscn")
const ParticleC = preload("res://remi/ams/particle_c.tscn")

const LED_NUMBER: int = 4
var current_led_on_number: int = 0

# output
var is_turning: bool = false

func _ready():
	await get_tree().create_timer(SOURCE_PARTICLE_INTERVAL).timeout
	_particle_source()

func _process(delta: float):
	if is_turning:
		var new_right: Vector2 = ($World.get_global_mouse_position() - $World/AcceleratorInput.global_position).normalized()
		var angle_diff: float = $World/AcceleratorInput.transform.x.angle_to(new_right)
		if angle_diff > 0:
			$World/ProgressBar/ProgressBar.value += ENERGY_INCREASE_FACTOR * angle_diff/TAU/delta
			$World/AcceleratorInput.rotation = new_right.angle()
	$World/ProgressBar/ProgressBar.value -= ENERGY_DECREASE_RATE * delta
	# update
	$World/Accelerator.gravity = ACCELERATOR_ACCELERATION * $World/ProgressBar/ProgressBar.value/100.0

func _particle_source():
	_spawn_particle()
	await get_tree().create_timer(SOURCE_PARTICLE_INTERVAL).timeout
	_particle_source()

func _spawn_particle():
	var new_particle: RigidBody2D = null
	match randi_range(0, 2):
		0:
			new_particle = preload("res://remi/ams/particle_a.tscn").instantiate()
		1:
			new_particle = preload("res://remi/ams/particle_b.tscn").instantiate()
		2:
			new_particle = preload("res://remi/ams/particle_c.tscn").instantiate()
	new_particle.position = $World/Source.position
	new_particle.position.y += randf_range(-1.0, 1.0) * SOURCE_Y_VARIANCE
	new_particle.linear_velocity = Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * PARTICLE_INITIAL_VELOCITY
	$World.add_child(new_particle)

# signals

func _on_boundaries_body_exited(body: RigidBody2D):
	body.queue_free()

func _on_deviator_input_button_down():
	$World/Deviator.gravity = DEVIATOR_ACCELERATION

func _on_deviator_input_button_up():
	$World/Deviator.gravity = 0.0

func _on_accelerator_input_button_down():
	is_turning = true

func _on_accelerator_input_button_up():
	is_turning = false

func _on_target_body_entered(body):
	if body is ParticleB:
		current_led_on_number += 1
		$World/Target/Leds.get_child(current_led_on_number-1).color.v = 1.0
		var tween: Tween = create_tween()
		tween.tween_property($World/Target/Leds.get_child(current_led_on_number-1), "modulate", Color.GREEN, 0.0625).set_trans(Tween.TRANS_QUAD)
		tween.tween_property($World/Target/Leds.get_child(current_led_on_number-1), "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
		tween.set_loops(3)
		if current_led_on_number == LED_NUMBER:
			# animation
			for index in range(current_led_on_number):
				tween = create_tween()
				tween.tween_property($World/Target/Leds.get_child(index), "modulate", Color.GREEN, 0.0625).set_trans(Tween.TRANS_QUAD)
				tween.tween_property($World/Target/Leds.get_child(index), "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
				tween.set_loops(3)
			tween = create_tween()
			tween.tween_property($World/Target, "modulate", Color.GREEN, 0.0625).set_trans(Tween.TRANS_QUAD)
			tween.tween_property($World/Target, "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
			tween.set_loops(3)
			# change state of game
			LabState.ams_done = true
			# transition
			var tween_transition: Tween = create_tween()
			tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
			await tween_transition.finished
			get_tree().change_scene_to_file("res://remi/lab/lab.tscn")
			return
	else:
		# reset ui
		for index in range(LED_NUMBER):
			$World/Target/Leds.get_child(index).color.v = 0.5
		# animation
		for index in range(current_led_on_number):
			var tween: Tween = create_tween()
			tween.tween_property($World/Target/Leds.get_child(index), "modulate", Color.RED, 0.0625).set_trans(Tween.TRANS_QUAD)
			tween.tween_property($World/Target/Leds.get_child(index), "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
			tween.set_loops(3)
		var tween: Tween = create_tween()
		tween.tween_property($World/Target, "modulate", Color.RED, 0.0625).set_trans(Tween.TRANS_QUAD)
		tween.tween_property($World/Target, "modulate", Color.WHITE, 0.0625).set_trans(Tween.TRANS_QUAD)
		tween.set_loops(3)
		# reset internal number
		current_led_on_number = 0
	body.queue_free() # TODO: Animate (particles ?)
	
