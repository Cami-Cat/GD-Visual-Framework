@tool
@icon("res://addons/visual_framework/Assets/Node Icon.png")
class_name Visual_Editor
extends Control

signal unsaved_state(new_state : bool)

signal continue_save

const default_dir_path : String = "res://addons/visual_framework/Grids/"
@export_storage var current_save_path : String = ""

## A reference to the background grid for scaling.
@export var grid : Background_Grid
## How much to adjust zoom levels by. 
@export var zoom_step : float = 0.5
## A reference to the parent of all visual nodes.
@export var visual_node_master : Visual_Node_Master

var actions_since_last_edit : int = 0
var action_list : Array[Dictionary] = []
var unsaved : bool = false
var overwrite_request : bool = false
var overwrite : bool = false

var grid_name : StringName = &""

const MAX_ZOOM : float = 2
const MIN_ZOOM : float = 0.5

func _ready() -> void:
	VisualServer.visual_grid = self
	print(get_all_children(self))

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
	## Placeholder.
	if Input.is_action_just_pressed("ui_accept") && Input.is_action_pressed("ui_cancel"):
		var visual_node_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node.tscn")
		var node = visual_node_path.instantiate()
		
		var duplicate_node = node.duplicate()
		duplicate_node.scene_file_path = ""
		duplicate_node.name = node.name + "_duplicate"
		
		visual_node_master.add_child(duplicate_node)
		duplicate_node.owner = VisualServer.visual_grid
		duplicate_node.action_ran.connect(action_ran)	
		action_ran("Added Node", duplicate_node)
		return
	## So long as the grid is visible, allow save.
	if visible != false:
		if Input.is_key_label_pressed(KEY_CTRL) && Input.is_key_label_pressed(KEY_S):
			save()
			return

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

func save() -> void:
	## If it's unnamed, popup
	if grid_name == "":
		unnamed_save_popup()
		await continue_save
		## Once the popup is closed, if it's still unnamed, return.
		if grid_name == "":
			return
	## Pack this grid into a single TSCN so that it can be instantiated on any object.
	
	set_all_owner()
	
	var packed = PackedScene.new()
	packed.pack(self)
	var composite_path : String = (default_dir_path + grid_name + ".tscn")
	
	if FileAccess.file_exists(composite_path) && current_save_path != composite_path:
		overwrite_popup()
		await continue_save
		if overwrite == false:
			return
			
	ResourceSaver.save(packed, composite_path)
	
	## So long as the file was successfully saved, reset these states.
	if FileAccess.file_exists(composite_path):
		current_save_path = composite_path
		actions_since_last_edit = 0
		action_list.clear()
		unsaved = false
		unsaved_state.emit(false)
		return
	return

func overwrite_popup() -> void:
	overwrite_request = true
	create_confirmation_dialogue("Overwrite?", "A grid with that name already exists. Would you like to overwrite?\n\n WARNING : This will completely erase the other grid, only do so if you're sure!")
	return

func unnamed_save_popup() -> void:
	create_confirmation_dialogue("Error saving grid", "Current grid is unnamed, please give it a name if you would like to save.", true, "unnamed")
	return

func create_confirmation_dialogue(dialogue_title : String = "", dialogue_text : String = "", has_line_edit : bool = false, line_edit_text : String = "") -> void:
	## Define the popup dialogue window.
	var dialogue = AcceptDialog.new()
	dialogue.title = dialogue_title
	dialogue.dialog_text = dialogue_text

	dialogue.add_cancel_button("Cancel")
	if has_line_edit:
	## Create a Line Edit object to pass an editable name through.
		var line_edit = LineEdit.new()
		line_edit.placeholder_text = "..."
		dialogue.get_label().add_child(line_edit)
		dialogue.register_text_enter(line_edit)
		
		## Set the positions of thel Line Edit so that it is centered and separate from the dialog_text
		line_edit.set_anchors_preset(Control.PRESET_CENTER)
		line_edit.size = Vector2(200, 10)
		line_edit.position -= line_edit.size / 2 
		line_edit.position.y += 30
		line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		line_edit.text_changed.connect(force_set_grid_name)
	
	dialogue.canceled.connect(confirmation_canceled)
	dialogue.confirmed.connect(confirmation_confirmed)
	
	## Open the dialogue in the middle of the screen.
	add_child(dialogue)
	dialogue.popup_centered()
	dialogue.show()
	return

func confirmation_canceled() -> void:
	force_set_grid_name("")
	if overwrite_request:
		deny_overwrite()
	continue_save.emit()
	return

func confirmation_confirmed() -> void:
	if overwrite_request:
		accept_overwrite()
	continue_save.emit()
	return

func deny_overwrite() -> void:
	overwrite_request = false
	overwrite = false
	return

func accept_overwrite() -> void:
	overwrite_request = false
	overwrite = true
	return

func force_set_grid_name(new_name : String) -> void:
	$"UI/Top Bar/Script Information/Script Name".text = new_name
	set_grid_name(new_name)
	return
	
func set_grid_name(new_name : String) -> void:
	new_name = new_name.replace(" ", "_")
	grid_name = new_name
	name = new_name
	return

func action_ran(action_name : String = "", ...args : Array) -> void:
	actions_since_last_edit += 1
	## TODO : Implement below.
	# action_list.append({action_name : args})
	if !unsaved : 
		unsaved = !unsaved
		unsaved_state.emit(true)
	return

func get_all_children(node, children_accumulated = []) -> Array:
	children_accumulated.push_back(node)
	for child in node.get_children():
		children_accumulated = get_all_children(child, children_accumulated)

	return children_accumulated

func set_all_owner() -> void:
	var children = get_all_children(self)
	for child in children:
		if is_instance_valid(child):
			if child is AcceptDialog : continue
			child.owner = self
