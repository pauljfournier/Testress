extends Node

var currentLevel
var DataList = []
var DEFAULT_LEVELS_LIST = [
	Level.new("First Point", "FirstPoint.tscn", Level.TYPES.PERCENT, 0.2, 1.0),
	Level.new("Green Boat", "GreenBoat.tscn", Level.TYPES.PERCENT, 0.2, 1.0),
	Level.new("Grip 4 life", "Grip4life.tscn", Level.TYPES.MINIMUM, 0.2, 1.0, 4),
	Level.new("Equilibrium", "Equilibrium.tscn", Level.TYPES.SURVIVAL, 0.2, 1.0, null, -1, 3),
	Level.new("Level 34", "Level34.tscn", Level.TYPES.PERCENT, 1.9, 1.0),
	Level.new("Ninja", "LevelNinja.tscn", Level.TYPES.PERCENT, 1.9, 1.0),
	Level.new("Slicy", "Slicy.tscn", Level.TYPES.PERCENT, 2.4, 1.0),
	Level.new("Mountain Peak", "MountainPeak.tscn", Level.TYPES.SURVIVAL, 1.0, 1.0, null, -1, 3),
	]

func getNextLevel(title):
	for index in range(DataList.size()-1):
		if DataList[index].title == title:
			return DataList[index+1]
	return -1

func getLevelByTitle(title):
	for level in DataList:
		if level.title == title:
			return level
	return -1

func does_level_exist(title):
	return getLevelByTitle(title)!=-1

func switch_to_level(title):
	var newCurrentLevel = getLevelByTitle(title)
	currentLevel = newCurrentLevel
	SceneChanger.change_scene(newCurrentLevel.get_full_node_path(), 0)
