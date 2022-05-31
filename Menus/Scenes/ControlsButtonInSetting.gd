extends TextureButton

var controller_mode =  false

func _input(_event):
	if self.get_focus_owner() == self:
		if _event is InputEventJoypadMotion || _event is InputEventJoypadButton:
			controller_mode = true
		elif _event is InputEventKey || _event is InputEventMouseButton:
			controller_mode = false
		if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_super_left"):
			left_pressed_action()
		elif Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_super_right"):
			right_pressed_action()
		

func left_pressed_action():
	open_controls(false)
	
func right_pressed_action():
	open_controls(true)
	
func _pressed():
	open_controls()

func open_controls(open_with_controller_mode = controller_mode):
	# pass the controller_mode when opening
	SceneChanger.change_scene_controller_mode("res://Menus/Scenes/ControlsMenu.tscn", 0, false, open_with_controller_mode)
