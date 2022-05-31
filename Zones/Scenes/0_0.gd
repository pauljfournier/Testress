extends RigidBody2D

signal activated(position)
signal desactivated(position)

var bodies: Array = []
var active setget , _get_active
var number_of_subCells = 1
var frozen = false

func _on_ShapeSubCell_body_entered(body):
	print(" in: ",body," ",body.mode==RigidBody2D.MODE_STATIC)
	if body.is_in_group("Pieces"):
		bodies.append(body)
		if bodies.size()==1:
			modulate.a = modulate.a * 2
			var parent = get_parent()
			if parent.is_in_group("Shapes"):
				parent._on_subCell_activated([get_position_in_parent()])
			emit_signal("activated",[get_position_in_parent()])

func _on_ShapeSubCell_body_exited(body):
	print("out: ",body," ",body.mode==RigidBody2D.MODE_STATIC)
	if body.is_in_group("Pieces"):
		bodies.erase(body)
		if bodies.size()==0:
			modulate.a = modulate.a / 2
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
