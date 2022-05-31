extends TextureButton

var control_name
var controller_mode = false
var listening = false

onready var new_controls_keyboard
onready var new_controls_controller

func _input(_event):
	if listening:
		if self.get_focus_owner() == self:
			if _event.is_action_type():
				if _event.is_action("ui_cancel") || \
					_event.is_action("ui_accept") || \
					_event.is_action("ui_select") || \
					(_event is InputEventMouseButton && _event.button_index==BUTTON_LEFT):
					$Warning.show()
					$Key_value.hide()
					$Warning/Timer.start()
					yield($Warning/Timer, "timeout")
					$Warning.hide()
					$Key_value.show()
				elif !_event.is_pressed():
					change_control(_event)
					listen(false)
	else:
		if Input.is_action_just_pressed("ui_left") || \
			Input.is_action_just_pressed("ui_super_left") || \
			Input.is_action_just_pressed("ui_right") || \
			Input.is_action_just_pressed("ui_super_right"):
			listen(false)

func _unhandled_input(_event):
	# to prevent ui_cancel to triger back button
	if _event.is_action("ui_cancel"):
		if Input.is_action_just_released("ui_cancel"):
			listen(false)

func _pressed():
	listen(!listening)

func change_control(input):
	print(input.as_text())
	if !controller_mode:
		if input.get_class() == "InputEventKey":
			new_controls_keyboard[control_name] = [input.get_class(),input.scancode]
		elif input.get_class() == "InputEventMouseButton":
			new_controls_keyboard[control_name] = [input.get_class(),input.button_index]
	else:
		if input.get_class() == "InputEventJoypadButton":
			new_controls_controller[control_name] = [input.get_class(),input.button_index]
		elif input.get_class() == "InputEventJoypadMotion":
			new_controls_controller[control_name] = [input.get_class(),input.axis,sign(input.axis_value)]

func listen(new_listening = false):
	if new_listening != listening:
		if new_listening:
			# remove neighbours so no focus lost
			_lost_focus_neighbours()
			listening = true
			$Key_value.text = "?"
			$Key_value.set("custom_colors/font_color", Color(1,1,1))
			get_tree().current_scene.listening = true
		else:
			# get back the neighbours so no focus work again
			_regain_focus_neighbours()
			get_tree().current_scene.listening = false
			listening = false
			$Key_value.set("custom_colors/font_color", Color(0,0,0))
			update_input_name()

func init(control, nck, ncc, controller=false):
	new_controls_keyboard = nck
	new_controls_controller = ncc
	control_name = control
	controller_mode = controller
	$Control_text.text = control.trim_prefix("ui_").capitalize()
	$Icon.texture = load("res://Menus/assets/control_icons/"+control+".png")
	$Warning.hide()
	$Key_value.show()
	update_input_name()


# TODO TODO get X box controller buttons name
func get_input_name(controller=controller_mode):
	var actionlist = InputMap.get_action_list(control_name)
	if actionlist.empty():
		print("MISSING INPUT IN INPUTMAP: ", control_name)
	# add the keyboard key
	if !controller:
		if new_controls_keyboard[control_name][0] == "InputEventKey":
			return OS.get_scancode_string(new_controls_keyboard[control_name][1])
		elif new_controls_keyboard[control_name][0] == "InputEventMouseButton":
			var new_control = InputEventMouseButton.new()
			new_control.set_button_index(new_controls_keyboard[control_name][1])
			return new_control.as_text().split("button_index=")[1].split(',')[0].capitalize()
	# add the controllers button
	else:
		if new_controls_controller[control_name][0] == "InputEventJoypadMotion":
			var direction_sign = ""
			var input_name = Input.get_joy_axis_string(abs(new_controls_controller[control_name][1]))
			if input_name != "R2" && input_name != "L2":
				if new_controls_controller[control_name][1] % 2 == 0:
					if new_controls_controller[control_name][2] > 0:
						direction_sign = " Right"
					else:
						direction_sign = " Left"
				else:
					if new_controls_controller[control_name][2] > 0:
						direction_sign = " Down"
					else:
						direction_sign = " Up"
			return input_name + direction_sign
		elif new_controls_controller[control_name][0] == "InputEventJoypadButton":
			return Input.get_joy_button_string(new_controls_controller[control_name][1])

func update_input_name(controller=controller_mode):
	controller_mode = controller
	var input_name = get_input_name(controller_mode)
	if input_name.begins_with("Face Button"):
		if input_name.ends_with("Top"):
			input_name = "Y"
		else:
			input_name = "X"
	$Key_value.text = "["+input_name+"]"
	

func _on_ControlButton_focus_exited():
	listen(false)
	
func _lost_focus_neighbours():
	focus_neighbour_top = get_path()
	focus_neighbour_bottom = get_path()
	focus_previous = get_path()
	focus_next = get_path()

func _regain_focus_neighbours():
	var currentButtonIndex = get_index()
	var buttonList =  get_parent().get_children()
	var prev_neighbour = get_tree().current_scene.backButton
	var next_neighbour = buttonList[currentButtonIndex+1]
	if currentButtonIndex > 0 :
		prev_neighbour = buttonList[currentButtonIndex-1]
	focus_neighbour_top = prev_neighbour.get_path()
	focus_neighbour_bottom = next_neighbour.get_path()
	focus_previous = prev_neighbour.get_path()
	focus_next = next_neighbour.get_path()
