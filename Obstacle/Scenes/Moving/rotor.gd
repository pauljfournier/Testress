extends KinematicBody2D

export(float, 0, 100) var rotating_speed = 1
export(bool) var weak = false
var rotating = false
var current_rotating_speed
var starting_angle = 0

func _ready():
	starting_angle = rotation_degrees
	current_rotating_speed = rotating_speed

func _process(delta):
	var transfo = Transform2D(delta*current_rotating_speed*PI, position)
#	print(test_move(transfo,Vector2.ZERO,false))
	if rotating:
#		if !test_move(transfo,Vector2.ZERO,false):
			rotate(delta*current_rotating_speed*PI)
			current_rotating_speed = rotating_speed
#		else:
#			current_rotating_speed = 0.99999*current_rotating_speed
			

func start(custom_rotating_speed=rotating_speed,reset=true):
	if reset:
		reset()
	rotating_speed = custom_rotating_speed
	current_rotating_speed = custom_rotating_speed
	rotating = true
	
func stop():
	rotating = false

func reset():
	rotation_degrees = starting_angle
