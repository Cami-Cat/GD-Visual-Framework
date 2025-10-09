@tool
class_name Visual_Editor
extends Control

## A reference to the background grid for scaling.
@export var grid : Background_Grid
## How much to adjust zoom levels by. 
@export var zoom_step : float = 0.5
## A reference to the parent of all visual nodes.
@export var visual_node_master : Control 

const MAX_ZOOM : float = 5
const MIN_ZOOM : float = 0.2

func _gui_input(event: InputEvent) -> void:
	## Handle Zoom inputs
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		_zoom(1 - zoom_step)
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		_zoom(1 + zoom_step)
		return
	return

## Increase or decrease the scale of the grid, increasing or decreasing the size of all of the children it has. Amount affects how much it is scaled by, for reference:
## [codeblock]
## var new_zoom = clamp(grid.scale * Vector2(amount, amount)...
## [/codeblock]
## If [member amount] is [member 1], scale will remain the same.
func _zoom(amount : float = 0.0) -> void:
	var new_zoom = clamp(grid.scale * Vector2(amount, amount), Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	VEditor.v_editor_zoom = new_zoom
	grid.resize(new_zoom)
	return
