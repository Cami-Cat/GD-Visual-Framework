class_name me
extends Control

var timer : Timer = Timer.new()

func _ready() -> void:
	VisualServer.register_script("me", me)
	var script = VisualServer.get_registered_script("me")
	script.register_method("does_method_exist")
	var method = script.get_method("does_method_exist")
	print(method.method_arguments)
	
func does_method_exist(in_script : Script = null, method_name : StringName = &"") -> bool:
	if in_script == null:
		print("Cannot find whether the method: %s exists in a null script: %s" % [method_name, in_script.get_global_name()])
		return false
	for method in in_script.get_script_method_list():
		if method["name"] == method_name:
			return true
	return false

func new_method() -> void:
	return
