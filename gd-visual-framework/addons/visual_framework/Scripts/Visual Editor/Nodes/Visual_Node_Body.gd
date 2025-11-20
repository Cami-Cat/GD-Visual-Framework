@tool
extends ColorRect

var can_drag : bool = false
var is_dragging : bool = false
## The offset between the mouse and the current object.
var mouse_offset : Vector2 = Vector2.ZERO
## The position of where the mouse initially clicked
var initial_position : Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if !is_dragging : return
	self.get_parent().global_position = get_global_mouse_position() + mouse_offset

func _input(event: InputEvent) -> void:
	if !is_dragging :
		if !can_drag : return
	## Check for mouse clicks and release to handle movement.
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT :
		if event.is_pressed() :
			if !is_dragging :
				## Get the position of the event and create an offset based on the position of yourself and the position of the mouse, iterate on this in [method _process]
				initial_position = event.position
				mouse_offset = global_position - initial_position
				is_dragging = true
		elif event.is_released() : 
			is_dragging = false
			self.get_parent().action_ran.emit("Node Moved", self.get_parent(), global_position)
		return

func _on_mouse_entered() -> void:
	can_drag = true

func _on_mouse_exited() -> void:
	can_drag = false
