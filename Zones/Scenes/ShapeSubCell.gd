extends Area2D

signal activated(position)
signal desactivated(position)

var bodies: Array = []
var active setget , _get_active
var number_of_subCells = 1
var frozen = false
var staticBodiesColliding = []
var original_modulate_a = modulate.a
var active_modulate_a = modulate.a * 2

func _on_ShapeSubCell_body_entered(body):
	if not frozen:
		if body.is_in_group("Pieces") && !staticBodiesColliding.has(body):
			bodies.append(body)
			body.has_entered(self)
			if bodies.size()==1:
				modulate.a = active_modulate_a
				var parent = get_parent()
				if parent.is_in_group("Shapes"):
					parent._on_subCell_activated([get_position_in_parent()])
				emit_signal("activated",[get_position_in_parent()])

func _on_ShapeSubCell_body_exited(body):
	if not frozen:
		if body.is_in_group("Pieces") && !staticBodiesColliding.has(body):
			bodies.erase(body)
			body.has_exited(self)
			if bodies.size()==0:
				modulate.a = original_modulate_a
				var parent = get_parent()
				if parent.is_in_group("Shapes"):
					parent._on_subCell_desactivated([get_position_in_parent()])
				emit_signal("desactivated",[get_position_in_parent()])

func _get_active():
	return !bodies.empty()

func activated_subCells():
	if active:
		return self

func return_subCell(PositionsArray):
	if !PositionsArray.empty():
		print("Coordinates error. PositionsArray not emptry. Return this cell.")
	return self
	
func freeze():
	frozen = true
		
func unfreeze():
	frozen = false

func piece_will_become_static(piece):
	staticBodiesColliding.append(piece)

func piece_will_stop_being_static(piece):
	staticBodiesColliding.erase(piece)

func reset():
	staticBodiesColliding.clear()
	bodies.clear()
	modulate.a = original_modulate_a
