extends CanvasLayer

signal victorying_finished

func start():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("victorying_count")

func stop():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("failled")

func reset():
	$AnimationPlayer.stop()
	$AnimatedSprite.hide()

func freeze():
	$AnimationPlayer.stop(false)

func unfreeze():
	$AnimationPlayer.start()

func _on_AnimationPlayer_animation_finished(animation):
	if animation == "victorying_count":
		emit_signal("victorying_finished")
