extends TextureButton

var previous_volume = 100
var mute = false

var _texture_mute = load("res://Menus/assets/music/music_off.png")
var _texture_mute_hover = load("res://Menus/assets/music/music_on_hover.png")
var _texture_unmute = load("res://Menus/assets/music/music_on.png")
var _texture_unmute_hover = load("res://Menus/assets/music/music_off_hover.png")

func _ready():
	mute = SettingsSave.volume_mute
	previous_volume = SettingsSave.volume
	if mute:
		$HSlider.value = 0
	else:
		$HSlider.value = SettingsSave.volume

func _input(_event):
	if self.get_focus_owner() == self:
		if Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_super_left"):
			left_pressed_action()
		elif Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_super_right"):
			right_pressed_action()
	if Input.is_action_just_pressed("ui_mute"):
		_mute()

func left_pressed_action():
	_set_volume($HSlider.value - $HSlider.step)
	
func right_pressed_action():
	_set_volume($HSlider.value + $HSlider.step)

func _mute():
	if not mute:
		_set_volume(0)
	else:
		_set_volume(previous_volume)

func _set_volume(value):
	$HSlider.value = value

func _pressed():
	_mute()

func visualy_change_button(mute_state):
	if mute_state:
		$NoteIcon_max.texture_normal = _texture_mute
		$NoteIcon_max.texture_hover = _texture_mute_hover
		$NoteIcon_min.texture_normal = _texture_mute
		$NoteIcon_min.texture_hover = _texture_mute_hover
	else:
		$NoteIcon_max.texture_normal = _texture_unmute
		$NoteIcon_max.texture_hover = _texture_unmute_hover
		$NoteIcon_min.texture_normal = _texture_unmute
		$NoteIcon_min.texture_hover = _texture_unmute_hover

func _on_HSlider_value_changed(value):
	if value == 0:
		mute = true
	else:
		previous_volume = $HSlider.value
		mute = false
	SettingsSave.set_volume(previous_volume,mute)
	visualy_change_button(mute)
