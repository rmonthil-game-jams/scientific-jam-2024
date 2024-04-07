extends CharacterBody2D

var fall : bool = false
var gravity : int = 100
var fall_speed : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var random = RandomNumberGenerator.new()
	random.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 100*(1 + GlobalTemp.temperature/16) * (2 * randf() - 1)
	velocity.y = 100*(1 + GlobalTemp.temperature/16) * (2 * randf() - 1)
	move_and_slide()
	if fall:
		fall_speed += gravity * delta
		position.y += fall_speed * delta


func fall_enable():
	fall = true
