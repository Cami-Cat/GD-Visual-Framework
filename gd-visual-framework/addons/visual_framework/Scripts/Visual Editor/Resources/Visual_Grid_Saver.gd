@tool
class_name ResourceFormatSaverGrid
extends ResourceFormatSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["grid"])

func _recognize(resource: Resource) -> bool:
	return resource is Visual_Grid_Data

func _save(resource : Resource, path: String, flags: int) -> Error:
	if not resource:
		return ERR_INVALID_PARAMETER
	
	var data = resource.visual_grid
	
	var file = ConfigFile.new()
	file.load(path)
	file.set_value("Grid", "data", data)
	file.save(path)
	
	return OK
