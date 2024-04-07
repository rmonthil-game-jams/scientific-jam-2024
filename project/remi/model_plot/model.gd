extends Node

const Y_FACTOR_TEMPERATURE: float = 0.0238931498339 * 0.125
const Y_MINUS_TEMPERATURE: float = 184
const Y_FACTOR_RADIOACTIVITY: float = 0.05059668132491 * 6e-2
const Y_FACTOR_POLLEN: float = 0.02083333333333

# interface

func model_biodiversity(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_POLLEN * ((atan((-x + 2250 - 230 * deforestation_intensity) * pow(deforestation_intensity, 3))/(PI/2))*47/2+47/2)

func model_temperature(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_TEMPERATURE * ( -fossil_fuel_intensity * pow((-x + 2500)/100, 3) + fossil_fuel_intensity * pow((-x + 2250)/100, 2) + ((-x + 2250)/100) + 418 - (-2020 + 2250)/100 - fossil_fuel_intensity * pow((-2020 + 2250)/100, 2) + fossil_fuel_intensity * pow((-2020 + 2500)/100, 3)  - Y_MINUS_TEMPERATURE )

func model_radioactivity(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_RADIOACTIVITY * (5.0 * exp(-(pow((x - 2250)/1000, 2))/(2*0.00005))/sqrt(2*PI*0.00005)+2.8) * nuclear_war_intensity

# ready
func _ready():
	_update_data_plots()
	_update_model_plots()
	# fade in animation
	for child in get_children():
		if child is Node2D:
			child.modulate = Color.BLACK
			var tween: Tween = create_tween()
			tween.tween_property(child, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)

func _on_nuclear_war_start_value_changed(value: float):
	$AudioStreamPlayerClickDefault.play()
	_update_model_plots()

func _update_model_plots():
	LibPlot.plot_func($ModelGraph/Line2DBiodiversity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_biodiversity(x, $Input/Control/HBoxContainer/GridContainer/NuclearWarStart.value, $Input/Control/HBoxContainer/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/HBoxContainer/GridContainer/DeforestationRate.value), 700.0, 400.0, "biodiversity")
	LibPlot.plot_func($ModelGraph/Line2DRadioactivity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_radioactivity(x, $Input/Control/HBoxContainer/GridContainer/NuclearWarStart.value, $Input/Control/HBoxContainer/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/HBoxContainer/GridContainer/DeforestationRate.value), 700.0, 400.0, "radioactivity")
	LibPlot.plot_func($ModelGraph/Line2DTemperature, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_temperature(x, $Input/Control/HBoxContainer/GridContainer/NuclearWarStart.value, $Input/Control/HBoxContainer/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/HBoxContainer/GridContainer/DeforestationRate.value), 700.0, 400.0, "temperature")

func _update_data_plots():
	LibPlot.plot_func($DataGraph/Line2DBiodiversity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_biodiversity(x, 1.0, 0.5, 0.22), 700.0, 400.0, "biodiversity")
	LibPlot.plot_func($DataGraph/Line2DRadioactivity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_radioactivity(x, 1.0, 0.5, 0.22), 700.0, 400.0, "radioactivity")
	LibPlot.plot_func($DataGraph/Line2DTemperature, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_temperature(x, 1.0, 0.5, 0.22), 700.0, 400.0, "temperature")

func _on_fossil_fuel_consumption_rate_value_changed(value: float):
	$AudioStreamPlayerClickDefault.play()
	_update_model_plots()

func _on_deforestation_rate_value_changed(value: float):
	$AudioStreamPlayerClickDefault.play()
	_update_model_plots()

func _on_button_pressed():
	$AudioStreamPlayerClickDefault.play()
	if abs($Input/Control/HBoxContainer/GridContainer/NuclearWarStart.value - 1.0) + abs($Input/Control/HBoxContainer/GridContainer/FossilFuelConsumptionRate.value - 0.5) + abs($Input/Control/HBoxContainer/GridContainer/DeforestationRate.value - 0.22) < 0.15:
		$AudioStreamPlayerSuccess2.play()
		print("Success")
	else:
		$AudioStreamPlayerFail.play()
		print("Fail")
