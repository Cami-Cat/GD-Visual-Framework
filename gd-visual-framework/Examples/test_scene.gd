@tool
class_name me
extends Control

var timer : Timer = Timer.new()

static func _static_init() -> void:
	var script = VisualServer.register_script("me", me)
	var method = script.register_method("does_method_exist")
	if !method : return
	
	method.set_tuple_return(method.create_tuple(({"attached_to_script" : me, "does_exist" : TYPE_BOOL})))
	
	print("%s(%s) -> [%s]" % [method.method_name, method.method_arguments.keys(), method.method_return.properties.keys()])
	return

func _ready() -> void:
	does_method_exist(me, "does_method_exist")

func does_method_exist(in_script : Script = null, method_name : StringName = &"") -> Dictionary[String, me]:
	var _method = VisualServer.get_registered_script("me").get_method("does_method_exist")
	var tuple = _method.create_tuple_from_tuple(_method.get_tuple_return())
	if in_script == null:
		print("Cannot find whether the method: %s exists in a null script: %s" % [method_name, in_script.get_global_name()])
		return { "true" : null }
	for method in in_script.get_script_method_list():
		if method["name"] == method_name:
			return { "true" : null }
	return { "false" : null }

func new_method() -> void:
	return
