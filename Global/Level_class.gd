extends Object

class_name Level

enum TYPES { PERCENT=0, SURVIVAL=1, MINIMUM=2 }
#PERCENT win by getting 100% of the shapes
#SURVIVAL suvive as long as possible, limited or unlimited set, 3 lives or other game over, score count as max number of piece reached
#MINIMUM win by solving the puzzle with the minimum nb of pieces,  limited or unlimited set, 3 lives or not, score count as min number of piece reached
const DEFAULT_BESTSCORE = {TYPES.PERCENT:100.0, TYPES.SURVIVAL:INF, TYPES.MINIMUM:0}
const DEFAULT_INITSCORE = {TYPES.PERCENT:-INF, TYPES.SURVIVAL:0, TYPES.MINIMUM:INF}

var title : String
var file : String
var type : int
var highscore : float
var best_score_possible : float
var set_limit : int = -1 
var lives : int = -1
var difficulty : float = 0
var done : bool = false #at least once
var completed : bool = false
var version : float = 0.0

func _init(new_title, new_file, new_type, new_difficulty, new_version=0.0, new_best_score_possible = null, new_set_limit=-1, new_lives=-1, new_highscore = null, new_done=false, new_completed=false):
	self.title = new_title #unique
	self.file = new_file
	self.difficulty = new_difficulty
	self.version = new_version
	if TYPES.has(new_type):
		self.type = new_type
	else:
		self.type = int_to_type(new_type)
	if new_highscore == null:
		new_highscore = DEFAULT_INITSCORE.get(type)
	self.highscore = new_highscore
	if new_best_score_possible == null:
		 new_best_score_possible = DEFAULT_BESTSCORE.get(type)
	self.best_score_possible = new_best_score_possible
	self.set_limit = new_set_limit
	self.lives = new_lives
	self.done = new_done
	self.completed = new_completed

func score_str():
	match type:
		TYPES.PERCENT:
			if best_score_possible!=highscore:
				return str(highscore)+"%"
			else:
				return str(highscore)+"%!!"
		TYPES.SURVIVAL:
			if !best_score_possible || best_score_possible==INF:
				return str(highscore)
			else:
				if highscore == best_score_possible:
					return ""+str(highscore)+"/"+str(best_score_possible)+"!!"
				else:
					return str(highscore)+"/"+str(best_score_possible)
		TYPES.MINIMUM:
			if highscore == best_score_possible:
				return str(highscore)+"!!"
			else:
				return str(highscore)

func get_full_node_path():
	return GVar.LEVELS_DIR+file

func difference_value_from_level(level):
	if version==level.version:
		if file==level.file && type==level.type && best_score_possible==level.best_score_possible && set_limit==level.set_limit && lives==level.lives:
			if title==level.title && difficulty==level.difficulty:
				if highscore==level.highscore && completed==level.completed && done==level.done:
					return 0
				else: 
					return 1
			else:
				return 2
		else:
			return 3
	else:
		return 4

func duplicate(deepcopy):
	if deepcopy:
		return get_script().new(title, file, type, difficulty, version, best_score_possible, set_limit, lives, highscore, done, completed)
	else:
		return self

func is_new_highscore(new_potential_score):
	print(new_potential_score, self.highscore)
	match type:
		TYPES.PERCENT:
			return new_potential_score > self.highscore
		TYPES.SURVIVAL:
			return new_potential_score > self.highscore
		TYPES.MINIMUM:
			return new_potential_score < self.highscore

func int_to_type(intType):
	match intType:
		0:
			return TYPES.PERCENT
		1:
			return TYPES.SURVIVAL
		2:
			return TYPES.MINIMUM
		_:
			push_error("Impossible level type: "+str(intType)+" for "+self.title)
