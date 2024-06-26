extends Node

# parameters
const ALEXIA_WALKING_SPEED: float = 4e2
const ALEXIA_SWICTH_DURATION: float = 0.25

# output
var is_moving: bool = false

# internal
var tween_moving: Tween = null
var tween_switching: Tween = null

var current_ice_core: Node2D = null

# interface
## move
func play_move_alexia_animation_to_target(global_target: Vector2):
	# switch
	if global_target.x > $World/YSort/Alexia.global_position.x:
		if $World/YSort/Alexia/Anchor.scale.x != -1.0:
			if tween_switching:
				tween_switching.stop()
			tween_switching = create_tween()
			tween_switching.tween_property($World/YSort/Alexia/Anchor, "scale:x", -1.0, ALEXIA_SWICTH_DURATION).set_trans(Tween.TRANS_QUAD)
	elif global_target.x < $World/YSort/Alexia.global_position.x:
		if $World/YSort/Alexia/Anchor.scale.x != 1.0:
			if tween_switching:
				tween_switching.stop()
			tween_switching = create_tween()
			tween_switching.tween_property($World/YSort/Alexia/Anchor, "scale:x", 1.0, ALEXIA_SWICTH_DURATION).set_trans(Tween.TRANS_QUAD)
	else:
		return
	# stop tween
	$World/YSort/Alexia.stop_walking_animation()
	if tween_moving:
		tween_moving.stop()
	# tween
	is_moving = true
	tween_moving = create_tween()
	tween_moving.tween_callback($World/YSort/Alexia.play_walking_animation)
	tween_moving.tween_property($World/YSort/Alexia, "global_position:x", global_target.x, abs($World/YSort/Alexia.global_position.x - global_target.x)/ALEXIA_WALKING_SPEED).set_trans(Tween.TRANS_QUAD) 
	tween_moving.tween_callback($World/YSort/Alexia.play_idle_animation)
	await tween_moving.finished
	is_moving = false

# internal
func _ready():
	match LabState.alexia_state:
		"ams":
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Ams.global_position.x
			$Node/AudioStreamPlayerImagineMolecules.play()
			TextStack.push_line("J'aime bien imaginer les molécules se ballader dans l'accelerateur,")
			await get_tree().create_timer(3.0).timeout
			TextStack.push_line("ça me rappelle les jeux de tir de mon enfance *piou piou*.")
		"cuve":
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Cuve.global_position.x
			$Node/AudioStreamPlayerAvecImagination.play()
			TextStack.push_line("Avec un peu d'imagination,")
			await get_tree().create_timer(3.0).timeout
			TextStack.push_line("les molécules ressemblent à des bonbons !")
			await get_tree().create_timer(4.0).timeout
			TextStack.push_line("Mais un bonbon fait de CO2 ne doit pas avoir bon goût...")
		"microscope":
			$Node/AudioStreamPlayerDroleImagination.play()
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Microscope.global_position.x
			TextStack.push_line("C'est toujours drole d'imaginer que les pollens")
			await get_tree().create_timer(3.0).timeout
			TextStack.push_line("ne s'entendent pas avec le micro-plastique.")
			await get_tree().create_timer(4.0).timeout
			TextStack.push_line("Je crois que je commence à perdre la raison ahaha.")
	# connect
	if not LabState.ams_done:
		$World/YSort/DeskAnchor/Ams.selected.connect(_on_ams_selected.bind($World/YSort/DeskAnchor/Ams))
	else:
		$World/YSort/DeskAnchor/Ams/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Ams/TextureButton.focus_mode = Control.FOCUS_NONE
	if not LabState.cuve_done:
		$World/YSort/DeskAnchor/Cuve.selected.connect(_on_cuve_selected.bind($World/YSort/DeskAnchor/Cuve))
	else:
		$World/YSort/DeskAnchor/Cuve/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Cuve/TextureButton.focus_mode = Control.FOCUS_NONE
	if not LabState.microscope_done:
		$World/YSort/DeskAnchor/Microscope.selected.connect(_on_microscope_selected.bind($World/YSort/DeskAnchor/Microscope))
	else:
		$World/YSort/DeskAnchor/Microscope/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Microscope/TextureButton.focus_mode = Control.FOCUS_NONE
	if LabState.ams_done and LabState.cuve_done and LabState.microscope_done and LabState.remaining_ice_cores_in_the_fridge == 5:
		await get_tree().create_timer(3.0).timeout
		$Node/AudioStreamPlayerVoilaFait.play()
		TextStack.push_line("Super maintenant que j'ai récolté toutes les données !")
		await get_tree().create_timer(3.0).timeout
		TextStack.push_line("Je vais pouvoir récupéré les carotte au frigo.")
		await get_tree().create_timer(3.0).timeout
		TextStack.push_line("Ca donne faim de parler de carottes !")
		$World/YSort/Desk1Anchor/Label6.show()
		$World/YSort/Fridge.selected.connect(_on_fridge_selected)
		$World/YSort/Desk1Anchor/IceCoreHolder.selected.connect(_on_ice_core_holder_selected.bind($World/YSort/Desk1Anchor/IceCoreHolder))
		$World/YSort/Desk1Anchor/IceCoreHolder2.selected.connect(_on_ice_core_holder_selected.bind($World/YSort/Desk1Anchor/IceCoreHolder2))
		$World/YSort/Desk1Anchor/IceCoreHolder3.selected.connect(_on_ice_core_holder_selected.bind($World/YSort/Desk1Anchor/IceCoreHolder3))
		$World/YSort/Desk1Anchor/IceCoreHolder4.selected.connect(_on_ice_core_holder_selected.bind($World/YSort/Desk1Anchor/IceCoreHolder4))
		$World/YSort/Desk1Anchor/IceCoreHolder5.selected.connect(_on_ice_core_holder_selected.bind($World/YSort/Desk1Anchor/IceCoreHolder5))
		$World/YSort/Fridge.open()
	else:
		$World/YSort/Fridge/TextureButton.disabled = true
		$World/YSort/Fridge/TextureButton.focus_mode = Control.FOCUS_NONE
	# fade in animation
	$World.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property($World, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)
	# test text
	if not LabState.alexia_state:
		$Node/AudioStreamPlayerJeDoisFaireQuoi.play()
		await get_tree().create_timer(0.5).timeout
		TextStack.push_line("Bon maintenant que les carottes sont au frigo,")
		await get_tree().create_timer(3.0).timeout
		TextStack.push_line("je peux les analyser!")
		await get_tree().create_timer(4.0).timeout
		TextStack.push_line("Utilisons les instruments sur la table !")

# input
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			$AudioStreamPlayerClickDefault.play()
			play_move_alexia_animation_to_target($World.get_global_mouse_position())

# signals
func _on_ams_selected(target: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# set lab state
	LabState.alexia_state = "ams"
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://remi/ams/ams.tscn")

func _on_cuve_selected(target: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# set lab state
	LabState.alexia_state = "cuve"
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	# change scene
	get_tree().change_scene_to_file("res://louis/co2/co_2.tscn")

func _on_microscope_selected(target: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# set lab state
	LabState.alexia_state = "microscope"
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	# change scene
	get_tree().change_scene_to_file("res://louis/microscope_game/microscope.tscn")

func _on_fridge_selected():
	if not $World/YSort/Alexia.is_carrying:
		$AudioStreamPlayerClickTarget.play()
		# wait animation end
		play_move_alexia_animation_to_target($World/YSort/Fridge.global_position)
		await tween_moving.finished
		$World/YSort/Alexia.stop_idle_animation()
		await $World/YSort/Alexia.tween_idle.finished
		# set lab state
		if LabState.remaining_ice_cores_in_the_fridge > 0:
			LabState.remaining_ice_cores_in_the_fridge -= 1
			# create new ice_core
			$World/YSort/Alexia.carry_ice_core()
			$World/YSort/Fridge.take()
			# dialogue
			$Node/AudioStreamPlayerBrrr.play()
			TextStack.push_line("Brrrr ... C'est vraiment gelé.")
			await get_tree().create_timer(3.0).timeout
			TextStack.push_line("Posons vite cette carotte sur une table.")
			# pomme
			if (LabState.remaining_ice_cores_in_the_fridge == 0):
				$World/YSort/Fridge/TextureButton.disabled = true
				$World/YSort/Fridge/TextureButton.focus_mode = Control.FOCUS_NONE

func _on_ice_core_selected(equipement: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(equipement.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# drop ice core
	if current_ice_core:
		current_ice_core.position = Vector2.ZERO
		equipement.get_parent().add_child(current_ice_core)
		current_ice_core = null
	elif $World/YSort/Alexia.is_carrying:
		$World/YSort/Alexia.drop_ice_core(equipement.get_parent())
	# grab ice core
	$World/YSort/Alexia.carry_ice_core()
	# set current
	current_ice_core = equipement
	current_ice_core.get_parent().remove_child(current_ice_core)

func _on_ice_core_holder_selected(target: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# then go
	if $World/YSort/Alexia.is_carrying:
		if current_ice_core:
			current_ice_core.position = Vector2.ZERO
			target.add_child(current_ice_core)
			current_ice_core = null
			$World/YSort/Alexia.drop_ice_core(target, false)
		else:
			$World/YSort/Alexia.drop_ice_core(target)
		await get_tree().process_frame
		if (LabState.remaining_ice_cores_in_the_fridge == 0):
			if ($World/YSort/Desk1Anchor/IceCoreHolder.get_child(1) is IceCore0
				and $World/YSort/Desk1Anchor/IceCoreHolder2.get_child(1) is IceCore1
				and $World/YSort/Desk1Anchor/IceCoreHolder3.get_child(1) is IceCore2
				and $World/YSort/Desk1Anchor/IceCoreHolder4.get_child(1) is IceCore3
				and $World/YSort/Desk1Anchor/IceCoreHolder5.get_child(1) is IceCore4):
				$AudioStreamPlayerSuccess2.play()
				$World/YSort/EndDeskAnchor/End.activate()
				$World/YSort/EndDeskAnchor/End/TextureButton.disabled = false
				$World/YSort/EndDeskAnchor/End/TextureButton.focus_mode = Control.FOCUS_ALL
				$World/YSort/EndDeskAnchor/End.selected.connect(_on_end_selected.bind($World/YSort/EndDeskAnchor/End))
				$World/YSort/Desk1Anchor/Label7.show()
				$Node/AudioStreamPlayerCarotteFutur.play()
				TextStack.push_line("Les données correspondent !")
				await get_tree().create_timer(3.0).timeout
				TextStack.push_line("Les carottes sont dans le bon ordre !")
				await get_tree().create_timer(3.0).timeout
				TextStack.push_line("Passons à la modélisation !")
			else:
				$AudioStreamPlayerFail.play()
				$Node/AudioStreamPlayerNonPasBon.play()
				TextStack.push_line("Hmmm ... Non, ca ne semble pas bon. !")
				await get_tree().create_timer(3.0).timeout
				TextStack.push_line("Les données ne sont pas continues.")
				await get_tree().create_timer(3.0).timeout
				TextStack.push_line("Essayons d'échanger des carottes !")

func _on_end_selected(target: Node2D):
	$AudioStreamPlayerClickTarget.play()
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	# change scene
	get_tree().change_scene_to_file("res://remi/model_plot/model.tscn")
