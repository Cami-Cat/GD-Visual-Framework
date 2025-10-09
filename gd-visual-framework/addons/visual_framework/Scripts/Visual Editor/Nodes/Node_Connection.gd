@tool
class_name Node_Connection
extends Line2D

## Store the connections TO the node and the position for the end of the line.
var current_mouse_offset : Vector2 = Vector2.ZERO
var initial_mouse_pos : Vector2
var dragging_offset : Vector2

func _init() -> void:
	width = 2.0

func _set_to_position(point_index : int = 0, in_position : Vector2 = Vector2.ZERO) -> void:
	set_point_position(point_index, in_position)
	return

func _drop_line() -> void:
	call_deferred("queue_free")
	return

func _connect_line() -> void:
	return
