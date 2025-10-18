@tool
class_name Node_Output
extends Control

signal line_dropped()

@export var output_type : GDScript
@export var output_circle : RichTextLabel

var connections : Array[Node]

var lines : Array[Node_Connection]
var line : Node_Connection
var can_click : bool = false
var is_dragging : bool = false

func _process(delta: float) -> void:
	if !is_dragging || line == null : return
	## Alter the positioning of the end point (total number of points - 1 to get the final point in the array) by (dividing by) the size of the zoom in order to 
	## get an accurate end point.
	line._set_to_position((line.get_point_count() - 1), ((get_viewport().get_mouse_position() + line.dragging_offset) / VisualServer.v_editor_zoom))
	return

func _input(event: InputEvent) -> void:
	if !is_dragging:
		if !can_click : return
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if !is_dragging:
				## Create a line and add a (second, first is created in the [method _create_new_line() function) point, then store the mouse offset for dragging.
				line = _create_new_line()
				line.add_point(output_circle.position + Vector2(output_circle.size.x, (output_circle.size.y / 2)))
				line.initial_mouse_pos = event.position
				line.dragging_offset = line.get_point_position(0) - line.initial_mouse_pos
				is_dragging = true
		elif event.is_released():
			if !is_dragging : return
			line._drop_line()
			line_dropped.emit()
			is_dragging = false
	return

func _create_new_line() -> Line2D:
	## Create a new node connection, store it's position data at (0, 0), add a point at the end of the output circle (on the right) and store it within an array of lines.
	var new_line : Node_Connection = Node_Connection.new()
	new_line.position = Vector2(0, 0)
	self.add_child(new_line)
	new_line.add_point((output_circle.position + Vector2(output_circle.size.x, (output_circle.size.y / 2)))) # Create a starting point
	lines.append(new_line)
	return new_line

func _can_click() -> bool:
	return can_click

func _on_output_circle_mouse_entered() -> void:
	can_click = true
	return

func _on_output_circle_mouse_exited() -> void:
	can_click = false
	return
