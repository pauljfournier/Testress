extends CanvasLayer

onready var controller_mode = SceneChanger.controller_mode

func _ready():
	SceneChanger.connect("controller_mode", self, "_on_controller_mode_change")

func _on_controller_mode_change(new_mode):
	controller_mode = new_mode
	update_text()
	
func update_text():
	return
