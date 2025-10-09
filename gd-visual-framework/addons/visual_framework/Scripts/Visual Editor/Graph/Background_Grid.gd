@tool
class_name Background_Grid
extends ColorRect

func _ready() -> void:	
	return

func resize(new_scale : Vector2) -> void:
	if new_scale == self.scale : return
	self.scale = new_scale
	return
