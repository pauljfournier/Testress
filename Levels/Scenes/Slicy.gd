extends "res://Levels/Scenes/DefaultLevel.gd"

func update_speed():
	if self.percent < 60:
		falling_speed = 60
	elif 60 <= self.percent && self.percent < 90:
		falling_speed = 120
	elif 90 <= self.percent:
		falling_speed = 200
