class_name me
extends Control

var timer : Timer = Timer.new()

static func _static_init() -> void:
	var script = VisualServer.register_script("me", me)
	var method = script.register_method("does_method_exist")
	
	script.register_method_tuple_as_dict("does_method_exist", [{"property": "integer_property", "type": TYPE_INT, "class_name": ""},\
															  {"property": "script", "type": TYPE_OBJECT, "class_name": "me"}])
															
	script.register_method_tuple("does_method_exist", [VisualServer.create_property_dict("does_exist", TYPE_BOOL), 
													   VisualServer.create_property_dict("attached_to_script", Script, "Script")])
	
	print("%s(%s) -> %s:" % [method.method_name, method.method_arguments.keys(), method.method_return])

func does_method_exist(in_script : Script = null, method_name : StringName = &"") -> Dictionary[String, me]:
	if in_script == null:
		print("Cannot find whether the method: %s exists in a null script: %s" % [method_name, in_script.get_global_name()])
		return { "true" : null }
	for method in in_script.get_script_method_list():
		if method["name"] == method_name:
			return { "true" : null }
	return { "false" : null }

func new_method() -> void:
	return
