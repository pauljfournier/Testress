extends CanvasLayer

signal reset_game
signal restart_game
signal pause_game
signal resume_game
signal submit_game
signal transition_finished

onready var animation_player = $AnimationPlayer
var title setget , _get_title

func _input(event):
	if Input.is_action_just_released("ui_cancel"):
		_on_PauseButton_pressed()

func _ready():
	if LevelsList.currentLevel.type == Level.TYPES.PERCENT:
		$SubmitButton.disabled = false
		$ScoreInGame/PrimaryLabel.text="0%"
		$ScoreInGame/SecondaryLabel.hide()
	else:
		$SubmitButton.disabled = true
		$ScoreInGame/PrimaryLabel.text="0"
		if LevelsList.currentLevel.type == Level.TYPES.MINIMUM:
			$ScoreInGame/SecondaryLabel.show()
			$ScoreInGame/SecondaryLabel.text="0%"
		else:
			$ScoreInGame/SecondaryLabel.hide()
	if LevelsList.currentLevel.lives != -1: 
		$Hearths.show()
	else:
		$Hearths.hide()

func show_game_end(previous_highscore_str=null,is_new_highscore=false,victory=false):
	show_game_pause()
	$EndGamePanel/ScoreSprite.scale = Vector2.ONE * 0.317
	if victory:
		$EndGamePanel/ScoreSprite.play("win")
		$EndGamePanel/NextButton.grab_focus()
	else:
		$EndGamePanel/ScoreSprite.play("lost")
		$EndGamePanel/RetryButton.grab_focus()
	$PlayButton.hide()
	yield(animation_player, "animation_finished")
	if is_new_highscore:
		show_new_highscore()
	if previous_highscore_str:
		show_previous_highscore(previous_highscore_str,is_new_highscore)

func show_game_start():
	$EndGamePanel.hide()
	$PlayButton.hide()
	$ResetButton.show()
	$PauseButton.show()
	$SubmitButton.show()
	emit_signal("transition_finished")

func show_game_pause():
	$ResetButton.hide()
	$PauseButton.hide()
	$SubmitButton.hide()
	$PlayButton.show()
	$EndGamePanel/MenuButton.grab_focus()
	$EndGamePanel/ScoreSprite.play("pause")
	$EndGamePanel/ScoreSprite.scale = Vector2.ONE * 0.9
	$EndGamePanel/HighscoreLabel.hide()
	$EndGamePanel/NewHighscoreLabel.hide()
	$EndGamePanel.show()
	animation_player.play("end_game")
	yield(animation_player, "animation_finished")
	emit_signal("transition_finished")

func show_game_resume():
	animation_player.stop()
	animation_player.play_backwards("end_game")
	yield(animation_player, "animation_finished")
	$EndGamePanel.hide()
	$PlayButton.hide()
	$ResetButton.show()
	$PauseButton.show()
	$SubmitButton.show()
	emit_signal("transition_finished")
	
func _on_ResetButton_pressed():
	if $ResetButton.visible :
		emit_signal("reset_game")
	
func _on_RestartButton_pressed():
	if $EndGamePanel/RetryButton.visible:
		emit_signal("restart_game")

func update_percent(percent):
	$ScoreInGame.value = percent
	var label
	if LevelsList.currentLevel.type == Level.TYPES.PERCENT:
		label = $ScoreInGame/PrimaryLabel
	else:
		label = $ScoreInGame/SecondaryLabel
	label.text = str(percent)+"%"

func update_pieces_count(nb_of_piece):
	$ScoreInGame/PrimaryLabel.text = str(nb_of_piece)

func init_lives(nb_of_lives):
	if nb_of_lives > 3:
		"Not feasable for the moment"
	else:
		var to_show = nb_of_lives
		for hearth in $Hearths.get_children():
			if to_show > 0:
				hearth.play("default")
				hearth.show()
				to_show -= 1
			else:
				hearth.hide()

func update_lives(nb_of_lives):
	if nb_of_lives > 3:
		"Not feasable for the moment"
	else:
		var to_keep = nb_of_lives
		for hearth in $Hearths.get_children():
			if hearth.visible:
				if to_keep <= 0:
					hearth.play("death")
					yield(hearth, "animation_finished")
					hearth.hide()
			else:
				if to_keep > 0:
					hearth.show()
					hearth.play("rebirth")
					yield(hearth, "animation_finished")
					hearth.play("default")
			to_keep -= 1

func _on_MenuButton_pressed():
	animation_player.stop()
	SceneChanger.change_scene("res://Menus/Scenes/LevelSelection.tscn", 0)
	animation_player.play_backwards("end_game")
	yield(animation_player, "animation_finished")
	$EndGamePanel.hide()

func _on_PauseButton_pressed():
	if $PauseButton.visible:
		emit_signal("pause_game")

func _on_PlayButton_pressed():
	if $PlayButton.visible:
		emit_signal("resume_game")

func _on_NextButton_pressed():
	for i in range(LevelsList.DataList.size()-1):
		if LevelsList.DataList[i]["title"]==self.title:
			LevelsList.switch_to_level(LevelsList.DataList[i+1]["title"])
			animation_player.stop()
			animation_player.play_backwards("end_game")
			yield(animation_player, "animation_finished")
			$EndGamePanel.hide()
			return
	_on_MenuButton_pressed()

func _get_title():
	var levelNode = get_parent()
	if levelNode.is_in_group("Levels"):
		return levelNode.title
	return ""

func show_previous_highscore(previous_highscore_str, is_new_highscore):
	$EndGamePanel/HighscoreLabel.show()
	var prefix = ""
	if is_new_highscore:
		prefix = "Previous "
	$EndGamePanel/HighscoreLabel.text = prefix+"Highscore: "+previous_highscore_str

func show_new_highscore():
	$EndGamePanel/NewHighscoreLabel.show()
	animation_player.play("new_highscore")

func _on_SubmitButton_pressed():
	if $SubmitButton.visible:
		emit_signal("submit_game")

func flash_bar(second):
	for n in int(second):
		$AnimationPlayer.play("flash_bar")
		yield ($AnimationPlayer, "animation_finished")
