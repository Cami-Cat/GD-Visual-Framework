@tool
class_name Visual_Node_Master
extends Control

var initial_mouse_pos : Vector2 = Vector2.ZERO
var dragging_offset : Vector2 = Vector2.ZERO
var is_dragging : bool = false

func _ready() -> void:
	global_position = Vector2.ZERO
	visible = true

func _process(delta: float) -> void:
	if !is_dragging : return
	global_position = get_global_mouse_position() + dragging_offset

## Move the parent node of all of the Visual Nodes on the grid to simulate panning a camera around with [member Middle Mouse Button]
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.is_pressed():
			initial_mouse_pos = event.position
			dragging_offset = global_position - initial_mouse_pos
			is_dragging = true
		elif event.is_released():
			is_dragging = false
	return

func zoom(new_scale : Vector2) -> void:	
	if new_scale == scale : return
	var mouse_position = get_global_mouse_position() * scale
	var new_mouse_position = get_global_mouse_position() * new_scale
	scale = new_scale
	global_position += (mouse_position - new_mouse_position)
	return
