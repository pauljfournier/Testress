extends Node

var savegame = File.new() #file
var save_path = GVar.SAVE_PATH #place of the file

func _ready():
	if not savegame.file_exists(save_path):
		create_save()
	else:
		update_levelscore_list()

func update_levelscore_list():
	#get the old save
	savegame.open(save_path, File.READ)
	var savedLevelDataList = dictsArray2levelsArray(savegame.get_var(true))
	savegame.close()
	#update if necessary
	var levelDataListTmp = []
	var levelTmp
	for level in LevelsList.DEFAULT_LEVELS_LIST:
		levelTmp = level.duplicate(true)
		for levelSaved in savedLevelDataList:
			var toCheckLevelSaved = levelSaved.duplicate(true)
			var diff = levelTmp.difference_value_from_level(toCheckLevelSaved)
			if diff < 3:
				if diff == 1 || diff == 2:
					levelTmp.highscore = toCheckLevelSaved.highscore
					levelTmp.completed = toCheckLevelSaved.completed
					levelTmp.done = toCheckLevelSaved.done
		levelDataListTmp.append(levelTmp)
	#save new version
	savegame.open(save_path, File.WRITE)
	savegame.store_var(levelsArray2dictsArray(levelDataListTmp),true)
	savegame.close()
	LevelsList.DataList = levelDataListTmp
	return levelDataListTmp

func save_levelscore(title,score,completed,done=true):
	print(score)
	var saving_level = LevelsList.getLevelByTitle(title)
	if saving_level.is_new_highscore(score):
		saving_level.highscore = score
	saving_level.completed = saving_level.completed || completed
	saving_level.done = done
	savegame.open(save_path, File.WRITE) #open file to write
	print(saving_level.highscore)
	print(levelsArray2dictsArray(LevelsList.DataList))
	savegame.store_var(levelsArray2dictsArray(LevelsList.DataList),true) #store the data
	savegame.close() # close the file

func create_save():
	savegame.open(save_path, File.WRITE)
	savegame.store_var(levelsArray2dictsArray(LevelsList.DEFAULT_LEVELS_LIST),true)
	LevelsList.DataList = LevelsList.DEFAULT_LEVELS_LIST.duplicate(true)
	savegame.close()

func delete_save():
	savegame.open(save_path, File.WRITE) #open file to write
	savegame.store_var(levelsArray2dictsArray(LevelsList.DEFAULT_LEVELS_LIST),true)
	LevelsList.DataList = LevelsList.DEFAULT_LEVELS_LIST.duplicate(true)
	savegame.close()

func is_there_save():
	for level in LevelsList.DataList:
		if level.done:
			return true
	return false

### For serialization of level 
func levelsArray2dictsArray(levelsArray):
	var dictsArray = []
	for level in levelsArray:
		dictsArray.append(level2dict(level))
	return dictsArray

func dictsArray2levelsArray(dictsArray):
	var levelsArray = []
	for dict in dictsArray:
		levelsArray.append(dict2level(dict))
	return levelsArray

func level2dict(level):
	return {"title":level.title,"file":level.file,"type":level.type,"difficulty":level.difficulty,"version":level.version,"best_score_possible":level.best_score_possible,"set_limit":level.set_limit,"lives":level.lives,"highscore":level.highscore,"done":level.done,"completed":level.completed}

func dict2level(dict):
	return Level.new(dict.get("title"), dict.get("file"), dict.get("type"), dict.get("difficulty"), dict.get("version"), dict.get("best_score_possible"), dict.get("set_limit"), dict.get("lives"), dict.get("highscore"), dict.get("done"), dict.get("completed"))
