extends CanvasLayer

signal scene_changed()
signal controller_mode(new_mode)

onready var animation_player = $AnimationPlayer
onready var color_rect = $Control/ColorRect
var previous_scene
var controller_mode = false

func _input(_event):
	if _event is InputEventJoypadMotion || _event is InputEventJoypadButton:
		controller_mode = true
		emit_signal("controller_mode",controller_mode)
	elif _event is InputEventKey || _event is InputEventMouseButton:
		controller_mode = false
		emit_signal("controller_mode",controller_mode)
		

func change_scene(path, delay =  0.5, save_previous_scene = true):
	$Control.show()
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	if save_previous_scene:
		previous_scene = get_tree().current_scene.filename
#	print(path)
	assert(get_tree().change_scene(path) == OK)
	get_tree().paused = false
	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	$Control.hide()
	emit_signal("scene_changed")

func change_scene_controller_mode(path, delay, save_previous_scene, save_controller_mode):
	controller_mode = save_controller_mode
	change_scene(path, delay, save_previous_scene)
