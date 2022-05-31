extends Node2D

onready var vBoxContainer = $Control/ScrollContainer/CenterContainer/VBoxContainer
var levelButton = preload("res://Menus/Scenes/LevelSelectionButton.tscn")

func _on_LevelButton_pressed(title):
	LevelsList.switch_to_level(title)

class LevelsListSorter:
	static func sort_ascending(a, b):
		if a.difficulty < b.difficulty:
			return true
		return false

func _ready():
	LevelsList.DataList.sort_custom(LevelsListSorter,"sort_ascending")
	for level in LevelsList.DataList:
		var button = levelButton.instance()
		button.init(level)
		button.connect("pressed", self, "_on_LevelButton_pressed",[level.title])
		vBoxContainer.add_child(button)
	var levelButtons = vBoxContainer.get_children()
	var first_focus_grabbed = false
	for index in range(levelButtons.size()):
		var button = levelButtons[index]
		if !(button.completed || first_focus_grabbed):
			button.grab_focus()
			first_focus_grabbed = true
		button.set_focus_previous(levelButtons[(index-1) % levelButtons.size()].get_path())
		button.set_focus_next(levelButtons[(index+1) % levelButtons.size()].get_path())
	if len(levelButtons):
		var settingsButtonPath = $SettingsButton.get_path()
		levelButtons[0].focus_neighbour_top = settingsButtonPath
		levelButtons[0].focus_previous = settingsButtonPath
		levelButtons[-1].focus_neighbour_bottom = settingsButtonPath
		levelButtons[-1].focus_next = settingsButtonPath
		$SettingsButton.focus_neighbour_top = levelButtons[-1].get_path()
		$SettingsButton.focus_previous = levelButtons[-1].get_path()
		$SettingsButton.focus_neighbour_bottom = levelButtons[0].get_path()
		$SettingsButton.focus_next = levelButtons[0].get_path()
	if !first_focus_grabbed:
		levelButtons[0].grab_focus()

func open_settings():
	SceneChanger.change_scene("res://Menus/Scenes/SettingsMenu.tscn", 0)

#func reset_save():
#	Save.delete_save()
#	SceneChanger.change_scene("res://Menus/Scenes/LevelSelection.tscn", 0)
