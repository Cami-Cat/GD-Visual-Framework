class_name me
extends Control

var timer : Timer = Timer.new()

func _ready() -> void:
	var script = VisualServer.register_script("me", me)
	var method = script.register_method("does_method_exist")
	print("%s(%s) -> %s:" % [method.method_name, method.method_arguments.keys(), method.method_return.keys()])

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
