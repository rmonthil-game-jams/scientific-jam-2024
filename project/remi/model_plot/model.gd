extends Node

# interface

func model_biodiversity(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	return 1.0

func model_temperature(t: float, nuclear_war_start: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	return 1.0

func model_radioactivity(t: float, nuclear_war_start: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	return 1.0

# ready
func _ready():
	_update_data_plots()
	_update_model_plots()

func _on_nuclear_war_start_value_changed(value: float):
	_update_model_plots()

func _update_model_plots():
	LibPlot.plot_func($ModelGraph/Line2DTemperature, LibPlot.generate_x(0.0, 4.0, 128), func(x): return model_temperature(x, $Input/Control/GridContainer/NuclearWarStart.value, $Input/Control/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/GridContainer/DeforestationRate.value), 128.0, 128.0, "temperature")
	LibPlot.plot_func($ModelGraph/Line2DRadioactivity, LibPlot.generate_x(0.0, 4.0, 128), func(x): return model_radioactivity(x, $Input/Control/GridContainer/NuclearWarStart.value, $Input/Control/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/GridContainer/DeforestationRate.value), 128.0, 128.0, "radioactivity")
	LibPlot.plot_func($ModelGraph/Line2DBiodiversity, LibPlot.generate_x(0.0, 4.0, 128), func(x): return model_biodiversity(x, $Input/Control/GridContainer/NuclearWarStart.value, $Input/Control/GridContainer/FossilFuelConsumptionRate.value, $Input/Control/GridContainer/DeforestationRate.value), 128.0, 128.0, "biodiversity")

func _update_data_plots():
	pass
	# TODO
