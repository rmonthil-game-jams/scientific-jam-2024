extends Node2D

class_name IceCore2

signal selected

const Y_FACTOR_TEMPERATURE: float = 0.0238931498339 * 0.125
const Y_MINUS_TEMPERATURE: float = 184
const Y_FACTOR_RADIOACTIVITY: float = 0.05059668132491 * 6e-2
const Y_FACTOR_POLLEN: float = 0.02083333333333

func _on_texture_button_pressed():
	selected.emit()

func _ready():
	_plot($Plots/Line2DTemperature, "res://remi/data_plot/data/co2_data.txt", Y_FACTOR_TEMPERATURE, Y_MINUS_TEMPERATURE)
	_plot($Plots/Line2DRadioactivity, "res://remi/data_plot/data/36cl_data.txt", Y_FACTOR_RADIOACTIVITY, 0.0)
	_plot($Plots/Line2DBiodiversity, "res://remi/data_plot/data/pollen_data.txt", Y_FACTOR_POLLEN, 0.0)

func _plot(line_2d: Line2D, filename: String, factor: float, minus: float):
	# read
	var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
	var content: String = file.get_as_text()
	var lines: PackedStringArray = content.split("\n")
	lines.reverse()
	var x: Array[float] = []
	x.resize(1.1*lines.size()/4)
	var y: Array[float] = []
	y.resize(1.1*lines.size()/4)
	for index in range(1.1*lines.size()/4):
		x[index] = float(lines[index + 1.95*lines.size()/4].split(',')[0])
		y[index] = float(lines[index + 1.95*lines.size()/4].split(',')[1])
	# post_processing
	## reverse
	var x_0: float = x[0]
	var x_max: float = x.max() - x_0
	## center
	for index in range(1.1*lines.size()/4):
		x[index] = (x[index] - x_0) / x_max
		y[index] = factor * (y[index] - minus)
	# plot
	LibPlot.plot_data(line_2d, x, y, 3*128.0, 2.5*128.0, "")
