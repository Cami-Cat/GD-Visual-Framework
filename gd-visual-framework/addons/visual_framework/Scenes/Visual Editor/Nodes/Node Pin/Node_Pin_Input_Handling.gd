@tool
class_name Node_Pin_Input_Handler
extends Control

@export var pin : Node_Pin

signal released()
signal clicked()


## -- Section : Input Handling


var mouse_over  : bool = false
var is_dragging : bool = false

var temp_line : Node_Connection = null

func _process(_delta: float) -> void:
	if !is_dragging : return
	_drag()

func _input(event: InputEvent) -> void:
	if !is_dragging : 
		if !mouse_over : return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if !is_dragging:
					_click_event()
			if event.is_released():
				_release_event()
	return

func _click_event() -> void:
	if !is_dragging:
		clicked.emit()
		temp_line = _create_line()
		get_parent().add_child(temp_line)
		is_dragging = true

func _create_line() -> Node_Connection:
	var node_connection = Node_Connection.new()
	for i in 2:
		node_connection.add_point(Vector2.ZERO)
	node_connection.set_point_position(0, Vector2(14.0, 0))
	node_connection.initial_mouse_pos = get_global_mouse_position()
	node_connection.dragging_offset = node_connection.get_point_position(0) - node_connection.initial_mouse_pos
	return node_connection

func _release_event() -> void:
	is_dragging = false
	released.emit()
	## TEMP
	temp_line.queue_free()

func _drag() -> void:
	if temp_line == null : return
	temp_line._set_to_position(1, (get_global_mouse_position() + temp_line.dragging_offset) / VisualServer.v_editor_zoom)
	return

func _on_pin_mouse_entered() -> void:
	mouse_over = true
	pin._set_pin_state(true)
	return

func _on_pin_mouse_exited() -> void:
	if is_dragging : await released
	mouse_over = false
	pin._set_pin_state(false)
	return
