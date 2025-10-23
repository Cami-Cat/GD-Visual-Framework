@tool
class_name Node_Pin_Input_Handler
extends Control

@export var pin : Node_Pin

signal released()
signal clicked()


## -- Section : Input Handling


var mouse_over  : bool = false
var is_dragging : bool = false

var lines : Array[Node_Connection] = []
var temp_line : Node_Connection = null

func _process(_delta: float) -> void:
	if !is_dragging : return
	_drag()

## Handle all of the controls related to Node Pins.
## Default controls:
## - MOUSE_BUTTON_LEFT
## - MOUSE_BUTTON_RIGHT
func _input(event: InputEvent) -> void:
	if !is_dragging : 
		if !mouse_over : return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if !is_dragging 	: _click_event()
			if event.is_released()	: _release_event()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed()	: _clear_connections()
	return

## Remove all connections related to this pin.
func _clear_connections() -> void:
	if lines.size() > 0:
		for line in lines:
			if line == null: continue
			line.queue_free()
		lines.clear()
		for connection : Node_Pin in pin.pin_connections.keys():
			connection.pin_connections[pin].queue_free()
			connection.pin_connections.erase(pin)
			connection._set_pin_state(false)
		pin.pin_connections.clear()
		return

func _click_event() -> void:
	if !is_dragging:
		clicked.emit()
		temp_line = _create_line()
		get_parent().add_child(temp_line)
		is_dragging = true

## Create a new Node Connection line and create two points. Then define important initial variables for controlling positions thereeafter.
func _create_line() -> Node_Connection:
	var node_connection = Node_Connection.new()
	for i in 2:
		node_connection.add_point(Vector2.ZERO)
	node_connection.set_point_position(0, Vector2(14.0, 0))
	node_connection.initial_mouse_pos = get_global_mouse_position()
	node_connection.dragging_offset = node_connection.get_point_position(0) - node_connection.initial_mouse_pos
	return node_connection

## Release handling, mostly VisualServer information. May alter this to a signal to have the Visual Server handle it instead of each Input Handler on a node pin.
func _release_event() -> void:
	if !is_dragging : return
	is_dragging = false
	## If you are not currently hovering over a pin or the pin that you're hovering over does not match the same TYPE as yours, abort.
	if VisualServer.mouse_over_pin == null || VisualServer.mouse_over_pin.pin_type != pin.pin_type:
		temp_line.queue_free()
		released.emit()
		return
	## Otherwise, if the pin is not yourself and is indeed a pin.
	if (VisualServer.mouse_over_pin != null && VisualServer.mouse_over_pin != self):
		## If it's two way, lock the connection regardless.
		if VisualServer.mouse_over_pin.connection_type == Node_Pin.CONNECTION_TYPES.TWO_WAY:
			_lock_connection()
		## If it's an output, ensure that the connection this pin is Input, otherwise free it.
		elif VisualServer.mouse_over_pin.connection_type == Node_Pin.CONNECTION_TYPES.OUTPUT:
			if pin.connection_type == Node_Pin.CONNECTION_TYPES.INPUT:
				_lock_connection()
			else:
				temp_line.queue_free()
		## If it's an input, ensure that the connection to this pin is Output, otherwise free it.
		elif (VisualServer.mouse_over_pin.connection_type == Node_Pin.CONNECTION_TYPES.INPUT):
			if pin.connection_type == Node_Pin.CONNECTION_TYPES.INPUT:
				temp_line.queue_free()
			_lock_connection()	
	released.emit()
	return

## Lock the connection between two nodes, requires temp_line to not be null.
func _lock_connection() -> void:
	if temp_line == null : 
		return
	if pin.pin_connections.has(VisualServer.mouse_over_pin) : 
		temp_line.queue_free()
		return

	## Set important temp_line variables for updating positions continuously.	
	temp_line.output_pin = pin
	temp_line.input_pin = VisualServer.mouse_over_pin
	## Lock the temporary line so that it does not follow the mouse.
	temp_line.locked = true
	## Store the lines in an accessible array to be cleared when right clicked.
	lines.append(temp_line)

	## Store the connection to this node with another node to access it later.
	pin.pin_connections[VisualServer.mouse_over_pin] = temp_line
	VisualServer.mouse_over_pin.pin_connections[pin] = temp_line
	temp_line = null

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
