extends Node2D

onready var vBoxContainer = $Control/ScrollContainer/CenterContainer/VBoxContainer
onready var animationPlayer = $AnimationPlayer
onready var backButton = $BackButton
onready var saveButton = $SaveButton
onready var ResetDefaultButton = $Control/ScrollContainer/CenterContainer/VBoxContainer/ResetDefaultButton
var controlButton = preload("res://Menus/Scenes/ControlButton.tscn")
var mode_controller = false
var listening = false

onready var new_controls_keyboard = SettingsSave.controls_keyboard.duplicate(true)
onready var new_controls_controller = SettingsSave.controls_controller.duplicate(true)

func _ready():
	mode_controller = SceneChanger.controller_mode 
	if mode_controller:
		animationPlayer.play("controller")
	for control in SettingsSave.controls_list_ref:
		var button = controlButton.instance()
		button.init(control, new_controls_keyboard, new_controls_controller, mode_controller)
		vBoxContainer.add_child(button)
	# replace the reset default button at the end
	vBoxContainer.remove_child(ResetDefaultButton)
	vBoxContainer.add_child(ResetDefaultButton)
	var controlsButtons = vBoxContainer.get_children()
	if len(controlsButtons):
		var backButtonPath = backButton.get_path()
		controlsButtons[0].focus_neighbour_top = backButtonPath
		controlsButtons[0].focus_previous = backButtonPath
		backButton.focus_neighbour_bottom = controlsButtons[0].get_path()
		backButton.focus_next = controlsButtons[0].get_path()

func _input(_event):
	if !listening:
		if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_super_left"):
			if !backButton.has_focus() && !saveButton.has_focus():
				left_pressed_action()
		elif Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_super_right"):
			if !backButton.has_focus() && !saveButton.has_focus():
				right_pressed_action()
		elif !focus_already():
			if Input.is_action_just_released("ui_down") || Input.is_action_just_released("ui_super_down"):
				vBoxContainer.get_child(0).grab_focus()
			elif Input.is_action_just_released("ui_up"):
				vBoxContainer.get_child(vBoxContainer.get_child_count()-1).grab_focus()

func focus_already():
	for child in vBoxContainer.get_children():
		if child.has_focus():
			return true
	if backButton.has_focus():
		return true
	return false	

func left_pressed_action():
	# switch to Keyboard
	switch_to(false)
	
func right_pressed_action():
	# switch to Controller
	switch_to(true)
	
func switch_to(controller=false):
	if controller != mode_controller:
		if controller:
			animationPlayer.play("switch")
		else:
			animationPlayer.play_backwards("switch")
		mode_controller = controller
		for child in vBoxContainer.get_children():
			if child.has_method("update_input_name"):
				child.update_input_name(controller)
		
func back_button():
	if !listening:
		SceneChanger.change_scene("res://Menus/Scenes/SettingsMenu.tscn", 0, false)

func save_button():
	if !listening:
		SettingsSave.new_game_bind(new_controls_keyboard, new_controls_controller)
		back_button()

func _on_ResetDefaultButton_pressed():
	if !mode_controller:
		new_controls_keyboard = SettingsSave.default_controls_keyboard.duplicate(true)
		for child in vBoxContainer.get_children():
			if child.has_method("update_input_name"):
				child.new_controls_keyboard = new_controls_keyboard
				child.update_input_name(mode_controller)
	else:
		new_controls_controller = SettingsSave.default_controls_controller.duplicate(true)
		for child in vBoxContainer.get_children():
			if child.has_method("update_input_name"):
				child.new_controls_controller = new_controls_controller
				child.update_input_name(mode_controller)

