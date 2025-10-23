@tool
class_name Node_Connection
extends Line2D

## Store the connections TO the node and the position for the end of the line.
var input_pin : Node_Pin
var output_pin : Node_Pin

var current_mouse_offset : Vector2 = Vector2.ZERO
var initial_mouse_pos : Vector2
var dragging_offset : Vector2

var locked : bool = false

func _init() -> void:
	width = 2.0
	z_index	= -1

func _process(delta: float) -> void:
	if locked :
		_set_to_position(0, Vector2(14, 0))
		_set_to_position(1, (input_pin.pin_connection_point.global_position - output_pin.pin_connection_point.global_position) / VisualServer.v_editor_zoom)
		return

func _set_to_position(point_index : int = 0, in_position : Vector2 = Vector2.ZERO) -> void:
	set_point_position(point_index, in_position)
	return

func _drop_line() -> void:
	call_deferred("queue_free")
	return

func _connect_line() -> void:
	return
