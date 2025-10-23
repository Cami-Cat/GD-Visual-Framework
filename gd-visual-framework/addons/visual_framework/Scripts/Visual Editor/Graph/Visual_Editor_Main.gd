@tool
class_name Visual_Editor
extends Control

## A reference to the background grid for scaling.
@export var grid : Background_Grid
## How much to adjust zoom levels by. 
@export var zoom_step : float = 0.5
## A reference to the parent of all visual nodes.
@export var visual_node_master : Visual_Node_Master

@export var data : Visual_Grid_Data

const MAX_ZOOM : float = 2
const MIN_ZOOM : float = 0.5

func _ready() -> void:
	VisualServer.visual_grid = self

func _gui_input(event: InputEvent) -> void:
	## Handle Zoom inputs
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		_zoom(1 - zoom_step)
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		_zoom(1 + zoom_step)
		return
	return

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") && Input.is_action_pressed("ui_cancel"):
		var visual_node_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node.tscn")
		var node = visual_node_path.instantiate()
		visual_node_master.add_child(node)
		data._add_node_data(node, node.global_position)
		return
	if Input.is_action_just_pressed("ui_page_down"):
		data._save_grid()

## Increase or decrease the scale of the grid, increasing or decreasing the size of all of the children it has. Amount affects how much it is scaled by, for reference:
## [codeblock]
## var new_zoom = clamp(grid.scale * Vector2(amount, amount)...
## [/codeblock]
## If [member amount] is [member 1], scale will remain the same.
func _zoom(amount : float = 0.0) -> void:
	var new_zoom = clamp(visual_node_master.scale * Vector2(amount, amount), Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	VisualServer.v_editor_zoom = new_zoom
	visual_node_master.zoom(new_zoom)
	return
