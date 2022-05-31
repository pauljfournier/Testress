extends TextureButton

onready var animationPlayer = $AnimationPlayer
var state = 0

func _ready():
	if Save.is_there_save():
		init_default_setup()
	else:
		init_no_save_setup()

func _input(_event):
	if self.get_focus_owner() == self:
		if Input.is_action_just_released("ui_left") || Input.is_action_just_pressed("ui_super_left"):
			left_pressed_action()
		elif Input.is_action_just_released("ui_right") || Input.is_action_just_pressed("ui_super_right"):
			right_pressed_action()

func grab_default_focus():
	if state == 1:
		$Control1/ButtonNo.grab_focus()
	elif state == 2:
		$Control2/CheckButton.grab_focus()
	elif state == 3:
		$Control3/CheckButton.grab_focus()
		
func left_pressed_action():
	grab_default_focus()
	
func right_pressed_action():
	grab_default_focus()

func _pressed():
	if state == 0 :
		switch_default_to_1()
	else:
		grab_default_focus()

func init_no_save_setup():
	animationPlayer.play("No_Save")
	state = 4
	disabled = true

func init_default_setup():
	animationPlayer.play("Default")
	state = 0
	
func back_to_default():
	grab_focus()
	init_default_setup()

func switch_default_to_1():
	if state == 0:
		state = 1
		$Control1/ButtonNo.grab_focus()
		animationPlayer.play("Default_to_1")

func _on_1_ButtonNo_pressed():
	if state == 1:
		back_to_default()

func _on_1_ButtonYes_pressed():
	if state == 1:
		switch_1_to_2()

func switch_1_to_2():
	if state == 1:
		state = 2
		$Control2/CheckButton.grab_focus()
		_on_2_CheckButton_toggled(false)
		$Control2/CheckButton.pressed = false
		animationPlayer.play("1_to_2")
	
func _on_2_CheckButton_toggled(button_pressed):
	if state == 2:
		if button_pressed:
			$Control2/Button.text = "Validate"
		else:
			$Control2/Button.text = "Cancel"

func _on_2_Button_pressed():
	if state == 2:
		if $Control2/CheckButton.pressed:
			switch_2_to_3()
		else:
			back_to_default()

func switch_2_to_3():
	if state == 2:
		state = 3
		$Control3/CheckButton.grab_focus()
		_on_3_CheckButton_toggled(false)
		$Control3/CheckButton.pressed = false
		animationPlayer.play("2_to_3")
	
func _on_3_CheckButton_toggled(button_pressed):
	if state == 3:
		if button_pressed:
			var C3CheckButton2Path = $Control3/CheckButton2.get_path()
			$Control3/CheckButton.focus_neighbour_right = C3CheckButton2Path
			$Control3/CheckButton.focus_next = C3CheckButton2Path
			$Control3/Button.focus_neighbour_left = C3CheckButton2Path
			$Control3/Button.focus_previous = C3CheckButton2Path
			$Control3/CheckButton2.disabled = false
		else:
			var C3ButtonPath = $Control3/Button.get_path()
			var C3CheckButtonPath = $Control3/CheckButton.get_path()
			$Control3/CheckButton.focus_neighbour_right = C3ButtonPath
			$Control3/CheckButton.focus_previous = C3ButtonPath
			$Control3/Button.focus_neighbour_left = C3CheckButtonPath
			$Control3/Button.focus_previous = C3CheckButtonPath
			$Control3/CheckButton2.disabled = true
			$Control3/CheckButton2.pressed = false
			$Control3/Button.text = "Cancel"

	
func _on_3_CheckButton2_toggled(button_pressed):
	if state == 3:
		if $Control3/CheckButton.pressed:
			if button_pressed:
				$Control3/Button.text = "Validate!"
			else:
				$Control3/Button.text = "Cancel"

func _on_3_Button_pressed():
	if state == 3:
		if $Control3/CheckButton.pressed and $Control3/CheckButton2.pressed:
			_delete_save()
			animationPlayer.connect("finished", self, "init_no_save_setup")
			animationPlayer.play("3_to_No_Save")
		else:
			back_to_default()

func _delete_save():
	Save.delete_save()
