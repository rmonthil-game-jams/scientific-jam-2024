extends Control

const top_left_spawn_point : Vector2 = Vector2(250, 130)
const spawn_width : int = 500
const spawn_height : int = 400
const molecule_number : int = 10
var clicks : int = 0
var was_inside_before : bool = false
var inside_target_1 : bool = false
var inside_target_2 : bool = false
var inside_target_3 : bool = false
var ch4_fallen : bool = false
var n2o_fallen : bool = false
var co2_fallen : bool = false
var co2_array = []
var ch4_array = []
var n2o_array = []
var co2_scene : PackedScene = preload("res://louis/co2/co_2_molecule.tscn")
var ch4_scene : PackedScene = preload("res://louis/co2/ch_4_molecule.tscn")
var n2o_scene : PackedScene = preload("res://louis/co2/n_2o_molecule.tscn")
@onready var molecules = $Molecules
@onready var temperature = $Tube/Node2D/Temperature
@onready var timer_decrease = $TimerDecrease
@onready var timer_inside_target = $TimerInsideTarget


func generate_molecules(molecule_scene, number, array):
	for i in range(number):
		var molecule = molecule_scene.instantiate() as CharacterBody2D
		molecule.position = top_left_spawn_point + Vector2(randf() * spawn_width, randf() * spawn_height)
		molecule.rotation = randf() * 2 * PI
		molecules.add_child(molecule)
		array += [molecule]
	return array

# Called when the node enters the scene tree for the first time.
func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()
	co2_array = generate_molecules(co2_scene, molecule_number, co2_array)
	ch4_array = generate_molecules(ch4_scene, molecule_number, ch4_array)
	n2o_array = generate_molecules(n2o_scene, molecule_number, n2o_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		$AudioStreamPlayerChargeUp.play()
		clicks += 1
	
	if clicks == 3:
		temperature.value = min(32, temperature.value + 1)
		clicks = 0
		timer_decrease.start()
	
	if !(inside_target_1 || inside_target_2 || inside_target_3) && timer_inside_target.time_left > 0 && timer_inside_target.time_left < 2:
		timer_inside_target.stop()



func _on_timer_decrease_timeout():
	temperature.value = max(temperature.value - 1, 1)


func _on_temperature_value_changed(value):
	GlobalTemp.temperature = value
	if value < 11:#before end of target 1
		timer_decrease.wait_time = 1
		was_inside_before = inside_target_1
		inside_target_1 = value >= 7
		inside_target_2 = false
		inside_target_3 = false
	elif value < 21:#before end of target 2
		timer_decrease.wait_time = 0.8
		was_inside_before = inside_target_2
		inside_target_2 = value >= 18
		inside_target_1 = false
		inside_target_3 = false
	else:#before end of target 3
		timer_decrease.wait_time = 0.5
		was_inside_before = inside_target_3
		inside_target_3 = value >= 26 && value < 28
		inside_target_1 = false
		inside_target_2 = false
	
	if (inside_target_1 || inside_target_2 || inside_target_3) && !was_inside_before:
		timer_inside_target.start()
		print("start")


func _on_timer_inside_target_timeout():
	print("to")
	if inside_target_1 && !ch4_fallen:
		ch4_fallen = true
		for e in ch4_array:
			e.fall_enable()
			e.collision_mask = 2
			e.collision_layer = 2
			$AudioStreamPlayerSuccess1.play()
	if inside_target_2 && !n2o_fallen && ch4_fallen:
		n2o_fallen = true
		for e in n2o_array:
			e.fall_enable()
			e.collision_mask = 4
			e.collision_layer = 4
			$AudioStreamPlayerSuccess1.play()
	if inside_target_3 && !co2_fallen && ch4_fallen && n2o_fallen:
		co2_fallen = true
		for e in co2_array:
			e.fall_enable()
			e.collision_mask = 8
			e.collision_layer = 8
		# we succeeded
		LabState.cuve_done = true
		$AudioStreamPlayerSuccess1.play()
		$AudioStreamPlayerSuccess2.play()
		# transition
		await get_tree().create_timer(2.0).timeout
		var tween_transition: Tween = create_tween()
		tween_transition.tween_property(self, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
		await tween_transition.finished
		get_tree().change_scene_to_file("res://remi/lab/lab.tscn")
