extends Node

var settingsFilepath = GVar.SETTINGS_PATH
var settingsFile 

var default_controls_keyboard = {}
var default_controls_controller = {}
var controls_keyboard = {}
var controls_controller = {}
var controls_list_ref = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_super_down", "ui_super_left", "ui_super_right", "rotate_left", "rotate_right", "next_level", "pause", "reset", "submit_score", "ui_mute"]
var controls_list_ref_sorted = controls_list_ref.duplicate(true)

var volume = 100
var volume_mute = false

func _ready():
	controls_list_ref_sorted.sort()
	save_project_default_controlls_dict()
	settingsFile = ConfigFile.new()
	if settingsFile.load(settingsFilepath) == OK:
		var err = load_InputMap()
		if !err :
			set_game_bind()
		else:
			print("DEFAULT SETTINGS USED")
		load_volume()
	else:
		save_current_InputMap()
		save_volume()

func load_InputMap():
	#load settings file (add comparaison at the end that all key on both lists)
	for action in settingsFile.get_section_keys("keyboard"):
		var key_value = settingsFile.get_value("keyboard", action)
		controls_keyboard[action] = key_value
	for action in settingsFile.get_section_keys("controller"):
		var key_value = settingsFile.get_value("controller", action)
		controls_controller[action] = key_value
	# check all controls have been setup
	var controls_keyboard_key_list = controls_keyboard.keys()
	controls_keyboard_key_list.sort()
	if !(controls_keyboard_key_list.hash() == controls_list_ref_sorted.hash()):
		print("CONFIG FILE PARSE ERROR: controls name error type keyboard")
		return 1
	var controls_controller_key_list = controls_controller.keys()
	controls_controller_key_list.sort()
	if !(controls_controller_key_list.hash() == controls_list_ref_sorted.hash()):
		print("CONFIG FILE PARSE ERROR: controls name error type controller")
		return 2
	return 0

func set_game_bind():
	for control in controls_list_ref_sorted:
		var actionlist = InputMap.get_action_list(control)
		if !actionlist.empty():
			InputMap.action_erase_events(control)
		# add the keyboard key
		if controls_keyboard[control][0] == "InputEventKey":
			var new_control = InputEventKey.new()
			new_control.set_scancode(controls_keyboard[control][1])
			InputMap.action_add_event(control, new_control)
		elif controls_keyboard[control][0] == "InputEventMouseButton":
			var new_control = InputEventMouseButton.new()
			new_control.set_button_index(controls_keyboard[control][1])
			InputMap.action_add_event(control, new_control)
		# add the controllers button
		if controls_controller[control][0] == "InputEventJoypadMotion":
			var new_joypad_control = InputEventJoypadMotion.new()
			new_joypad_control.set_axis(controls_controller[control][1])
			new_joypad_control.set_axis_value(sign(controls_controller[control][2]))
			InputMap.action_add_event(control, new_joypad_control)
		elif controls_controller[control][0] == "InputEventJoypadButton":
			var new_joypad_control = InputEventJoypadButton.new()
			new_joypad_control.set_button_index(controls_controller[control][1])
			InputMap.action_add_event(control, new_joypad_control)

func new_game_bind(new_controls_keyboard, new_controls_controller): 
	controls_keyboard = new_controls_keyboard
	controls_controller = new_controls_controller
	set_game_bind()
	save_current_InputMap()

func save_current_InputMap():
	# save the current InputMap in file
	for control in controls_list_ref_sorted:
		var actionlist = InputMap.get_action_list(control)
		if actionlist.empty():
			print("MISSING INPUT IN INPUTMAP")
		for action in actionlist:
			# add the keyboard key
			if action is InputEventKey:
				settingsFile.set_value("keyboard",control,[action.get_class(),action.scancode])
			elif action is InputEventMouseButton:
				settingsFile.set_value("keyboard",control,[action.get_class(),action.button_index])
			# add the controllers button
			elif action is InputEventJoypadMotion:
				settingsFile.set_value("controller",control,[action.get_class(),action.axis,sign(action.axis_value)])
			elif action is InputEventJoypadButton:
				settingsFile.set_value("controller",control,[action.get_class(),action.button_index])
	settingsFile.save(settingsFilepath)

func set_volume(new_volume, new_volume_mute):
	volume = new_volume
	volume_mute = new_volume_mute
	save_volume(new_volume, new_volume_mute)

func save_volume(volume_to_save=volume, volume_mute_to_save=volume_mute):
	settingsFile.set_value("volume","value",volume_to_save)
	settingsFile.set_value("volume","mute",volume_mute_to_save)
	settingsFile.save(settingsFilepath)
	
func load_volume():
	volume = settingsFile.get_value("volume","value",100)
	volume_mute = settingsFile.get_value("volume","mute",false)

func save_project_default_controlls_dict():
	InputMap.load_from_globals()
	for control in controls_list_ref_sorted:
		var actionlist = InputMap.get_action_list(control)
		if actionlist.empty():
			print("MISSING INPUT IN DEFAULT INPUTMAP")
		for action in actionlist:
			# add the keyboard key
			if action is InputEventKey:
				default_controls_keyboard[control] = [action.get_class(),action.scancode]
			elif action is InputEventMouseButton:
				default_controls_keyboard[control] = [action.get_class(),action.button_index]
			# add the controllers button
			elif action is InputEventJoypadMotion:
				default_controls_controller[control] = [action.get_class(),action.axis,sign(action.axis_value)]
			elif action is InputEventJoypadButton:
				default_controls_controller[control] = [action.get_class(),action.button_index]

#func string_from_input(inputcontroller):
#	#controller_mode = controller
#	var input_name = get_input_name(inputcontroller)
#	if input_name.begins_with("Face Button"):
#		if input_name.ends_with("Top"):
#			input_name = "Y"
#		else:
#			input_name = "X"
#	$Key_value.text = "["+input_name+"]"
