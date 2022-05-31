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
var animation_stopped = false
export(int, 0, 1000) var falling_speed = 300

func _ready():
	randomize()
	spawn_new()

func getNextPiece():
	if !PieceList.size():
		PieceList = DefaultPieceList.duplicate(true)
		PieceList.shuffle()
	return PieceList.pop_front()
	
func _on_RespawnTimer_timeout():
	var piece = getNextPiece().instance()
#	piece.connect("touch", self, "lost_control_on_piece")
	piece.connect("exit_screen", self, "lost_control_on_piece")
	piece.connect("touch", self, "lost_control_on_piece")
	add_child(piece)
#	piece.start($StartPosition.position, falling_speed)
	var pieces_started = piece.start($StartPosition.position,falling_speed)
	if !pieces_started:
		_on_restart_animation()
	
func lost_control_on_piece(already_touched):
	if not already_touched && not animation_stopped:
		spawn_new()

func spawn_new():
	$RespawnTimer.start()

func _on_restart_animation():
	get_tree().call_group("Pieces", "queue_free")
	spawn_new()
