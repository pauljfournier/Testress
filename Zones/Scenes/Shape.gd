extends Node2D

signal activated(position,number_of_active_subCells)
signal desactivated(position,number_of_active_subCells)

var number_of_active_subCells setget , _number_of_active_subCells_get
var number_of_subCells setget , _number_of_subCells_get

export(bool) var negative = false

func activated_subCells():
	var activated_subCells = []
	for child in get_children():
		if child.is_in_group("SubCells"):
			activated_subCells.append(child.activated_subCells())
		else:
			activated_subCells.append_array(child.activated_subCells())
	return activated_subCells
	
func return_all_subCells():
	var subCells = []
	for child in get_children():
		if child.is_in_group("SubCells"):
			subCells.append(child)
		else:
			subCells.append_array(child.return_all_subCells())
	return subCells

func return_subCell(positionsArray):
	var positionsArrayCopy = positionsArray.duplicate(true)
	var position =  positionsArrayCopy.pop_front()
	for child in get_children():
		if child.get_position_in_parent() == position:
			return child.return_subCell(positionsArrayCopy)

func _on_subCell_activated(positionsArray):
	positionsArray.append(get_position_in_parent())
	var parent = get_parent()
	if parent.is_in_group("Shapes"):
		parent._on_subCell_activated(positionsArray)
	emit_signal("activated",positionsArray,self.number_of_active_subCells)

func _on_subCell_desactivated(positionsArray):
	positionsArray.append(get_position_in_parent())
	var parent = get_parent()
	if parent.is_in_group("Shapes"):
		parent._on_subCell_desactivated(positionsArray)
	emit_signal("desactivated",positionsArray,self.number_of_active_subCells)

func _number_of_subCells_get():
	var total = 0
	for child in get_children():
		total += child.number_of_subCells
	return total

func _number_of_active_subCells_get():
	var activated_subCells = 0
	for child in get_children():
		if child.is_in_group("SubCells"):
			activated_subCells += int(child.active)
		else:
			activated_subCells += child.number_of_active_subCells
	return activated_subCells
