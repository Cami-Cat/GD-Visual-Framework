@tool
extends RichTextLabel

@export var output: Node_Output
var stylebox : StyleBoxFlat

func _ready() -> void:
	## Duplicate the theme in order to prevent updating every single output node when changing stylebox properties.
	stylebox = get_theme_stylebox("normal").duplicate()
	add_theme_stylebox_override("normal", stylebox)

func _on_mouse_entered() -> void:
	_fill_circle()
	output.can_click = true
	return

func _on_mouse_exited() -> void:
	_empty_circle()
	output.can_click = false
	return

func _fill_circle() -> void:
	## Given the current size of the output circle, totally fills it in.
	var stylebox : StyleBoxFlat = get_theme_stylebox("normal")
	stylebox.set_border_width_all(8)
	return

func _empty_circle() -> void:
	## Waits for the user to finish dragging the connection line off of the output before resetting the border width to the open output look.
	if output.is_dragging : await output.line_dropped
	var stylebox : StyleBoxFlat = get_theme_stylebox("normal")
	stylebox.set_border_width_all(3)
	return
