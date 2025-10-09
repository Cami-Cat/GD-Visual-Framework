@tool
extends Node

## The zoom scale stored in an editable, accessible variable.
@export var v_editor_zoom : Vector2 = Vector2.ONE
## The current node that the mouse is over in the visual editor, only updates on specific nodes such as visual node inputs and outputs.
@export var mouse_over_node : Node
