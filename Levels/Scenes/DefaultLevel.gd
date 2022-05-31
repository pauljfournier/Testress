extends Node

var I_Piece = preload("res://Pieces/Scenes/I_Piece.tscn")
var L_Piece = preload("res://Pieces/Scenes/L_Piece.tscn")
var J_Piece = preload("res://Pieces/Scenes/J_Piece.tscn")
var Z_Piece = preload("res://Pieces/Scenes/Z_Piece.tscn")
var S_Piece = preload("res://Pieces/Scenes/S_Piece.tscn")
var T_Piece = preload("res://Pieces/Scenes/T_Piece.tscn")
var O_Piece = preload("res://Pieces/Scenes/O_Piece.tscn")

var PieceList = []
var DefaultPieceList = [I_Piece,L_Piece,J_Piece,Z_Piece,S_Piece,T_Piece,O_Piece]
var gameStopped = true
var paused_time_left = 0
var gameVictorying = false
var gameStarting = false
var forced_submit = false
var title : String setget , get_title
var type setget , get_type
var score setget ,get_score
var lives = INF setget set_lives, get_lives
var max_lives setget ,get_max_lives
var percent : float setget set_percent, get_percent
var pieces_count : int setget set_pieces_count, get_pieces_count
var pieces_count_alive : int setget set_pieces_count_alive, get_pieces_count_alive
var number_of_active_subCells_pos = 0
var number_of_active_subCells_neg = 0
var number_of_subCells_pos = 1 setget , get_number_of_subCells_pos
var invulnerability_time = 3
var mode_controller = true
export(int, 0, 1000) var falling_speed = 60

func _ready():
	mode_controller = SceneChanger.controller_mode
	var _useless = SceneChanger.connect("scene_changed", self, "start_game")
	randomize()

func getNextPiece():
	if !PieceList.size():
		PieceList = DefaultPieceList.duplicate(true)
		PieceList.shuffle()
	return PieceList.pop_front()
	
func _on_RespawnTimer_timeout():
	if not gameStopped:
		var piece = getNextPiece().instance()
		piece.connect("touch", self, "piece_touch_received")
		piece.connect("exit_screen", self, "piece_exit_screen")
		add_child(piece)
		var pieces_started = piece.start($Pieces/StartPosition.position,falling_speed)
		if pieces_started:
			self.pieces_count += 1
		else:
			game_end()

func piece_touch_received(already_touched):
	if !already_touched:
		self.pieces_count_alive += 1
	lost_control_on_piece(already_touched)

func piece_exit_screen(already_touched):
	if !gameStarting:
		if self.max_lives != -1:
			if already_touched:
				self.pieces_count_alive -= 1
			lose_a_life()
		lost_control_on_piece(already_touched)

func lost_control_on_piece(already_touched):
	if not (already_touched || gameStopped):
		spawn_new()

func spawn_new():
	if not gameStopped:
		$Pieces/RespawnTimer.start()

func start_game_victorying():
	if !gameVictorying:
		gameVictorying = true
		$Pieces/RespawnTimer.paused = true
		$VictoryingCanvasLayer.start()

func interrupt_game_victorying():
	$VictoryingCanvasLayer.stop()
	gameVictorying = false
	forced_submit = false
	$Pieces/RespawnTimer.paused = false
		
func finish_game_victorying():
	$Pieces/RespawnTimer.paused = false
	gameVictorying = false
	if forced_submit:
		forced_submit = false
		game_end()
	else:
		game_victory()

func game_victory():
	game_end(true)

func game_over():
	if gameVictorying:
		interrupt_game_victorying()
	game_end()

func game_end(victory=false):
	print(self.score)
	var previous_saved_level = LevelsList.getLevelByTitle(self.title).duplicate(true)
	var is_new_highscore = previous_saved_level.is_new_highscore(self.score)
	var previous_saved_level_score_str = false
	if previous_saved_level.done :
		previous_saved_level_score_str = previous_saved_level.score_str()
	Save.save_levelscore(self.title, self.score, victory) #the verification score is effectively a new highscore
	gameStopped = true
	get_tree().paused = true
	$HUD.show_game_end(previous_saved_level_score_str,is_new_highscore,victory)
	yield($HUD, "transition_finished")

func start_game(restart=false):
	gameStarting = true
	gameStopped = false
	gameVictorying = false
	if restart:
		$VictoryingCanvasLayer.reset()
		$HUD.show_game_resume()
		yield($HUD, "transition_finished")
	else:
		$HUD.show_game_start()
		$Pieces/RespawnTimer.stop()
		$Pieces/RespawnTimer.paused = false
	get_tree().paused = false
	get_tree().call_group("Pieces", "queue_free")
	get_tree().call_group("SubCells", "reset")
	get_tree().call_group("Movings", "start")
	while len(get_tree().get_nodes_in_group("Pieces")):
		var t = Timer.new()
		t.set_wait_time(0.2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
	set_pieces_count(0)
	set_pieces_count_alive(0)
	set_percent(0)
	set_lives(self.max_lives)
	gameStarting = false
	spawn_new()
	
func game_pause():
	gameStopped = true
	get_tree().paused = true
	$HUD.show_game_pause()
	yield($HUD, "transition_finished")

func game_resume():
	gameStopped = false
	$HUD.show_game_resume()
	yield($HUD, "transition_finished")
	get_tree().paused = false

func game_reset():
	gameStopped = false
	gameVictorying = false
	$VictoryingCanvasLayer.reset()
	start_game()

func game_restart():
	start_game(true)

func game_submit():
	forced_submit = true
	start_game_victorying()

func _on_neg_percent_update(_positionArray,number_of_active_subCells):
	number_of_active_subCells_neg = number_of_active_subCells
	_on_percent_update(_positionArray,number_of_active_subCells_pos-number_of_active_subCells_neg)

func _on_pos_percent_update(_positionArray,number_of_active_subCells):
	number_of_active_subCells_pos = number_of_active_subCells
	_on_percent_update(_positionArray,number_of_active_subCells_pos-number_of_active_subCells_neg)

func _on_percent_update(_positionArray,number_of_active_subCells):
	var next_percent = ( number_of_active_subCells * 100 ) / self.number_of_subCells_pos
	if gameVictorying:
		if self.percent > next_percent:
			interrupt_game_victorying()
	set_percent(next_percent)
	if(number_of_active_subCells == self.number_of_subCells_pos):
		start_game_victorying()

func get_title():
	return LevelsList.currentLevel.title

func get_type():
	return LevelsList.currentLevel.type

func get_max_lives():
	return LevelsList.currentLevel.lives

func get_number_of_subCells_pos():
	if $ShapePos:
		return $ShapePos.number_of_subCells
	else:
		return -1

func get_score():
	if self.type == Level.TYPES.PERCENT:
		return self.percent
	elif self.type == Level.TYPES.MINIMUM:
		return self.pieces_count
	elif self.type == Level.TYPES.SURVIVAL:
		return self.pieces_count_alive
	else:
		return 0

func set_percent(new_percent):
	$HUD.update_percent(new_percent)
	percent = new_percent
	update_speed()
	
func get_percent():
	return percent

func set_pieces_count(new_pieces_count):
	if self.type == Level.TYPES.MINIMUM:
		$HUD.update_pieces_count(new_pieces_count)
	pieces_count = new_pieces_count
	update_speed()
	
func get_pieces_count():
	return pieces_count

func set_pieces_count_alive(new_pieces_count_alive):
	if self.type == Level.TYPES.SURVIVAL:
		$HUD.update_pieces_count(new_pieces_count_alive)
	pieces_count_alive = new_pieces_count_alive
	update_speed()
	
func get_pieces_count_alive():
	return pieces_count_alive

func lose_a_life():
	if $InvulnerabilityTimer.is_stopped() && self.lives>0:
		if gameVictorying:
			interrupt_game_victorying()
		else:
			var new_lives = self.lives-1
			set_lives(new_lives)
			$InvulnerabilityTimer.start(invulnerability_time)
			$HUD.flash_bar(invulnerability_time)
			if new_lives <= 0:
				start_game_victorying()

func set_lives(new_lives):
	$HUD.update_lives(new_lives)
	lives = max(new_lives,0)
	update_speed()

func get_lives():
	return lives

func update_speed():
	pass
