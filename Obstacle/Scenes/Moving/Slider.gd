extends KinematicBody2D

export(float, 0, 200) var speed = 2 #cases per second
var moving = false
var frozen = false
var direction = 1 #1 for forward, -1 for backward
var starting_position = Vector2.ZERO
var starting_scale_x = 1
var starting_direction = 1
export(float, 0, 100) var move_forward = 3 #number of cases move in frontward of starting position
export(float, 0, 100) var move_backward = 1 #number of cases move in backward of starting position
var local_axe_position = 0
var max_forward_local_axe setget , _max_forward_local_axe_get 
var max_backward_local_axe setget , _max_backward_local_axe_get 
var module_length = 2 #length of the module in block
export(float, 0, 100) var idle_time = 0.5 #time stopping when arriving at an edge
export(bool) var flipping = true
export(bool) var Flip_H = false setget _flip_h_set
var Vector_Dir setget , _vector_dir_get
#add variable collision obstacle make switch direction, var switch_on_collision = false

func _ready():
	starting_position = position
	starting_scale_x = scale.x
	starting_direction = direction

func _process(delta):
	if moving && !frozen:
		var moveDistance = direction * speed * GVar.BLOCK_SIZE * delta
		var expected_local_axe_position = local_axe_position + moveDistance #TODO
		if(expected_local_axe_position>=self.max_forward_local_axe):
			swich_direction()
			moveDistance = moveDistance - 2 * (expected_local_axe_position - self.max_forward_local_axe)
		elif(expected_local_axe_position<=self.max_backward_local_axe):
			swich_direction()
			moveDistance = moveDistance - 2 * (expected_local_axe_position - self.max_backward_local_axe)
		local_axe_position += moveDistance
		var move = self.Vector_Dir * moveDistance
		position += move

func swich_direction():
	direction = -direction
	if(flipping):
		if(module_length>1):
			var repositioningDistance = direction * GVar.BLOCK_SIZE * (module_length-1)
			var repositioning = self.Vector_Dir * repositioningDistance
			position += repositioning
			local_axe_position += repositioningDistance
		scale.x = -scale.x
	if(idle_time>0):
		stop()
		yield(get_tree().create_timer(idle_time), "timeout")
		start(speed,false)
	
func start(custom_speed=speed,reset=true):
	if reset:
		reset()
	speed = max(0,custom_speed)
	moving = true
	
func stop():
	moving = false

func unstop():
	moving = true
	
func freeze():
	frozen = true

func unfreeze():
	frozen = false

func reset():
	scale.x = starting_scale_x
	local_axe_position = 0
	position = starting_position
	direction = starting_direction

func _flip_h_set(value):
	Flip_H = value
	if Flip_H:
		direction = - 1
		scale.x = - abs(scale.x)
	else:
		direction = 1
		scale.x = - abs(scale.x)

func _vector_dir_get():
	return Vector2.RIGHT.rotated(rotation).normalized()
	
func _max_forward_local_axe_get():
	return max(0,move_forward*GVar.BLOCK_SIZE)
	
func _max_backward_local_axe_get():
	return min(0,-move_backward*GVar.BLOCK_SIZE)
