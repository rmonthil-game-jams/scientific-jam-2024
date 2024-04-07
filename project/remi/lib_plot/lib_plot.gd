extends Node

func _ready():
	randomize()

## plot
func generate_x(bound_inf: float, bound_sup: float, number: int) -> Array[float]:
	var output: Array[float]
	output.resize(number)
	for index in range(number):
		output[index] = bound_inf + (bound_sup - bound_inf) * index / (number - 1)
	return output

func plot_func(line: Line2D, x: Array[float], f: Callable, factor_x: float = 1.0, factor_y: float = 1.0, label: String = ""):
	line.clear_points()
	for index in x.size():
		line.add_point(Vector2(factor_x * x[index], -factor_y * f.call(x[index])))

func plot_data(line: Line2D, x: Array[float], y: Array[float], factor_x: float = 1.0, factor_y: float = 1.0, label: String = ""):
	assert(x.size() == y.size())
	line.clear_points()
	for index in x.size():
		line.add_point(Vector2(factor_x * x[index], -factor_y * y[index]))
