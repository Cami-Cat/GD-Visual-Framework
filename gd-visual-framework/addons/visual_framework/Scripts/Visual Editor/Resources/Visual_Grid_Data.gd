@tool
class_name Visual_Grid_Data
extends Resource

var visual_grid : Dictionary[Node, Vector2] = {}

func _add_node_data(node : Node, position : Vector2) -> void:
	visual_grid[node] = position
	return

func _change_node_data(node : Node, position : Vector2) -> void:
	return

func _save_grid() -> void:
	print("Saving.")
	ResourceSaver.save(self, "Visual_Grid.grid")
