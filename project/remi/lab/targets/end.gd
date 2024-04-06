extends Node2D

signal selected

const Y_FACTOR_TEMPERATURE: float = 0.0238931498339 * 0.125
const Y_MINUS_TEMPERATURE: float = 184
const Y_FACTOR_RADIOACTIVITY: float = 0.05059668132491 * 6e-2
const Y_FACTOR_POLLEN: float = 0.02083333333333

func activate():
	$Plots.show()
	$Plots2.show()

func _on_texture_button_pressed():
	selected.emit()

func model_biodiversity(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_POLLEN * ((atan((-x + 2250 - 230 * deforestation_intensity) * pow(deforestation_intensity, 3))/(PI/2))*47/2+47/2)

func model_temperature(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_TEMPERATURE * ( -fossil_fuel_intensity * pow((-x + 2500)/100, 3) + fossil_fuel_intensity * pow((-x + 2250)/100, 2) + ((-x + 2250)/100) + 418 - (-2020 + 2250)/100 - fossil_fuel_intensity * pow((-2020 + 2250)/100, 2) + fossil_fuel_intensity * pow((-2020 + 2500)/100, 3)  - Y_MINUS_TEMPERATURE )

func model_radioactivity(t: float, nuclear_war_intensity: float, fossil_fuel_intensity: float, deforestation_intensity: float) -> float:
	var x: float = t * (2500 - 2020) + 2020
	return Y_FACTOR_RADIOACTIVITY * (5.0 * exp(-(pow((x - 2250)/1000, 2))/(2*0.00005))/sqrt(2*PI*0.00005)+2.8) * nuclear_war_intensity

func _ready():
	LibPlot.plot_func($Plots/Line2DBiodiversity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_biodiversity(x, 0.0, 0.0, 0.0), 200.0, 120.0, "biodiversity")
	LibPlot.plot_func($Plots/Line2DRadioactivity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_radioactivity(x, 0.0, 0.0, 0.0), 200.0, 120.0, "radioactivity")
	LibPlot.plot_func($Plots/Line2DTemperature, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_temperature(x, 0.0, 0.0, 0.0), 200.0, 120.0, "temperature")
	# more
	LibPlot.plot_func($Plots2/Line2DBiodiversity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_biodiversity(x, 1.0, 0.5, 0.22), 200.0, 120.0, "biodiversity")
	LibPlot.plot_func($Plots2/Line2DRadioactivity, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_radioactivity(x, 1.0, 0.5, 0.22), 200.0, 120.0, "radioactivity")
	LibPlot.plot_func($Plots2/Line2DTemperature, LibPlot.generate_x(0.0, 1.0, 64), func(x): return model_temperature(x, 1.0, 0.5, 0.22), 200.0, 120.0, "temperature")
