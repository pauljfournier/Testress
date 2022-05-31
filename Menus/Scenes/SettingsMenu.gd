extends Node2D

onready var vBoxContainer = $Control/ScrollContainer/CenterContainer/VBoxContainer
var current_focus

func _input(_event):
	if !current_focus:
		if Input.is_action_just_released("ui_down"):
			vBoxContainer.get_child(0).grab_focus()
		elif Input.is_action_just_released("ui_up"):
			vBoxContainer.get_child(vBoxContainer.get_child_count()-1).grab_focus()
	else:
		if Input.is_action_just_pressed("ui_down") or \
			Input.is_action_just_pressed("ui_up"):
			# will grab focus to the current_focus node on pressed
			# and move to correct node when released	
			current_focus.grab_focus()

func back_button():
	SceneChanger.change_scene(SceneChanger.previous_scene, 0)

func _on_VolumeButton_focus_entered():
	current_focus = vBoxContainer.get_child(0)

func _on_ControlsButton_focus_entered():
	current_focus = vBoxContainer.get_child(1)

func _on_ResetButton_focus_entered():
	current_focus = vBoxContainer.get_child(2)

func _on_BackButton_focus_entered():
	current_focus = $BackButton
