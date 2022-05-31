extends RigidBody2D

signal touch
signal exit_screen

export(int, 0, 1000) var falling_speed = 60  # How fast the pieces will descend (pixels/sec).
export var gravity_once_touched = Vector2.DOWN * 9.8  # How fast the pieces will fall by gravity(pixels/sec).
export(float, 0, 100) var rotation_speed = 1 #base rotation speed

var screen_size  # Size of the game window.
export(int) var block_size =  GVar.BLOCK_SIZE
var half_block_size =  GVar.HALF_BLOCK_SIZE
var subCellsColliding = []
var DELTA_ROT = PI / 64

var controllable = false
var rotating = false
var touched = false
var in_control = false
var last_pressed = ""
var in_animation = false
var velocity = Vector2.ZERO
var threads = {}
var previous_mode = mode
var previous_controllable = false
var previous_inertia = inertia
var previous_linear_velocity = linear_velocity
var previous_applied_torque = applied_torque
var previous_angular_velocity = angular_velocity

func _ready():
	screen_size = get_viewport_rect().size
	set_process_input(true)

func _input(_event):
	if controllable:
		if Input.is_action_just_pressed("ui_super_left") && !last_pressed:
			last_pressed = "ui_super_left"
			rotating = false
			superSlide(Vector2.LEFT)
		elif Input.is_action_just_pressed("ui_super_right") && !last_pressed:
			last_pressed = "ui_super_right"
			rotating = false
			superSlide(Vector2.RIGHT)
		elif Input.is_action_just_pressed("ui_super_down") && !last_pressed:
			last_pressed = "ui_super_down"
			rotating = false
			slideDown(block_size)
		elif Input.is_action_just_pressed("ui_left") && !last_pressed:
			last_pressed = "ui_left"
			rotating = false
			slide(Vector2.LEFT,half_block_size)
		elif  Input.is_action_just_pressed("ui_right") && !last_pressed:
			last_pressed = "ui_right"
			rotating = false
			slide(Vector2.RIGHT,half_block_size)
		elif  Input.is_action_just_pressed("ui_down") && !last_pressed:
			last_pressed = "ui_down"
			rotating = false
			slideDown(half_block_size)
		if Input.is_action_just_released("ui_left") && last_pressed == "ui_left":
			last_pressed = ""
		elif  Input.is_action_just_released("ui_right") && last_pressed == "ui_right":
			last_pressed = ""
		elif  Input.is_action_just_released("ui_down") && last_pressed == "ui_down":
			last_pressed = ""
		elif Input.is_action_just_released("ui_super_left") && last_pressed == "ui_super_left":
			last_pressed = ""
		elif Input.is_action_just_released("ui_super_right") && last_pressed == "ui_super_right":
			last_pressed = ""
		elif Input.is_action_just_released("ui_super_down") && last_pressed == "ui_super_down":
			last_pressed = ""
		if Input.is_action_just_pressed("rotate_right"):
			rotating = true
		elif Input.is_action_just_pressed("rotate_left"):
			rotating = true
		elif Input.is_action_just_released("rotate_right"):
			rotating = false
			rotation += - fmod(rotation+DELTA_ROT,  PI/2) + DELTA_ROT
#			rotate(- fmod(rotation+DELTA_ROT,  PI/2) + DELTA_ROT)
		elif Input.is_action_just_released("rotate_left"):
			rotating = false
			rotation += - fmod(rotation-DELTA_ROT, -PI/2) - DELTA_ROT
#			rotate(- fmod(rotation-DELTA_ROT, -PI/2) - DELTA_ROT)


func slide(Vector2Direction, moveSize):
	var out = true	
	if Vector2Direction == Vector2.LEFT:
		out = position.x < moveSize
	elif Vector2Direction == Vector2.RIGHT:
		out = position.x > screen_size.x - moveSize
	var move = Vector2Direction * moveSize
	if out || test_motion(move,false):
		$AnimationPlayer.play("impossible_move")
	else:
		position += move

func slideDown(moveSize):
	if !in_control:
		in_control = true
		var oldPos = position
		var move = Vector2.DOWN * moveSize
		if test_motion(move,false):
			while test_motion(move,false) && move.y > 0:
				move -= Vector2.DOWN * 0.1 * moveSize
			_on_touched()
		position = oldPos + move
		in_control = false
	
func superSlide(Vector2Direction):
	if !in_control:
		in_control = true
		var oldPos = position
		var squeezValue = 0.95 #pixel to squeez
		squeez(squeezValue)
		var sum = 0
		var microDownMoveValue = 0.01#0.005
		var microDownMove = Vector2.DOWN * microDownMoveValue
		var move = Vector2Direction * block_size
		while sum < half_block_size :
			if test_motion(move,false):
				if test_motion(move/2,false):
					if test_motion(microDownMove,false):
						_on_touched()
						break
					else:
						position += microDownMove
						sum += microDownMoveValue
				else:
					$AnimationPlayer.play("shake")
					slide(Vector2Direction, half_block_size)
					break
			else:
				$AnimationPlayer.play("shake")
				slide(Vector2Direction, block_size)
				break
		unsqueez()
		if sum > half_block_size:
			position = oldPos
			$AnimationPlayer.play("impossible_move")
		in_control = false

func squeez(squeezValue):
	self.scale = Vector2.ONE * squeezValue
	
func unsqueez():
	squeez(1)
	
func _process(delta):
	if controllable:
		if Input.is_action_pressed("rotate_right") and rotating:
			rotate( delta *  rotation_speed * PI )
		elif Input.is_action_pressed("rotate_left") and rotating:
			rotate( delta * -rotation_speed * PI )
		if !in_control:
			var move = Vector2.DOWN * falling_speed * delta
			if test_motion(move,false):
				_on_touched()
			else:
				position += move

#return if the piece spawned successfuly or not
func start(pos, custom_falling_speed=falling_speed):
	position = pos
	falling_speed = custom_falling_speed
	var move = Vector2(0,half_block_size)
	# detect if the piece can spawn
	if test_motion(move,false):
		queue_free()
	else:
		controllable = true
		show()
		return true

func _on_touched():
	if controllable && not touched:
		touched = true
		controllable = false
		mass = 1000
		emit_signal("touch",false)
		if $AnimationPlayer.current_animation != "":
			yield( $AnimationPlayer, "animation_finished" )
		$AnimationPlayer.play("reset")
		becomeNonStaticMode(RigidBody2D.MODE_RIGID)

func becomeStaticMode():
	previous_mode = mode
	for body in subCellsColliding:
		if body.is_in_group("SubCells"):
			body.piece_will_become_static(self)
	mode = RigidBody2D.MODE_STATIC

func becomeNonStaticMode(bodyMode):
	previous_mode = mode
	if(mode == RigidBody2D.MODE_STATIC):
		for body in subCellsColliding:
			if body.is_in_group("SubCells"):
				body.piece_will_stop_being_static(self)
	mode = bodyMode

func has_entered(subCell):
	subCellsColliding.append(subCell)
	
func has_exited(subCell):
	subCellsColliding.erase(subCell)

func immobilize():
	previous_inertia = inertia
	previous_linear_velocity = linear_velocity
	previous_applied_torque = applied_torque
	previous_angular_velocity = angular_velocity
	previous_controllable = controllable
	controllable = false
	becomeStaticMode()
	
func unimmobilize():
	controllable = previous_controllable
	if previous_mode == RigidBody2D.MODE_STATIC:
		becomeStaticMode()
	else:
		becomeNonStaticMode(previous_mode)
		inertia = previous_inertia
		linear_velocity = previous_linear_velocity
		applied_torque = previous_applied_torque
		angular_velocity = previous_angular_velocity

func _on_screen_exited():
	emit_signal("exit_screen",touched)
	queue_free()
