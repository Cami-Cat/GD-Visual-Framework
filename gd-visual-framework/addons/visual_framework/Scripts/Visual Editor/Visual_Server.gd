@tool
extends Node

## The zoom scale stored in an editable, accessible variable.
@export var v_editor_zoom : Vector2 = Vector2.ONE

enum CONNECTION_TYPE {OUTPUT, INPUT, OUTPUT_INPUT}

var registered_scripts : Dictionary[String, Registered_Script]

func _get_registered_scripts() -> Dictionary[String, Registered_Script]:
	return registered_scripts

func register_script(script_name : StringName = "", script : Script = null) -> void:
	if !script:
		print("Cannot register a script with no given script argument. Called method should look like such: \
			 register_script(\"this_script\", this_script)")
		return
	if !script_name:
		print("No name given to register script, giving it the same name as it's global_name")
		script_name = script.get_global_name()
	if is_script_registered(script_name, script) : 
		print("The script: %s is already a registered script, returning" % [script_name])
		return
	
	var registry : Registered_Script = Registered_Script.new(script_name, script)
	registered_scripts[script_name] = registry
	return
	
func get_registered_script(script_name : StringName = "", script : Script = null) -> Registered_Script:
	if !is_script_registered(script_name, script) : 
		return null
	if script_name:
		var registry : Registered_Script = registered_scripts.get(script_name)
		if registry:
			return registry
	if script:
		for registered_script : String in registered_scripts:
			var registry : Registered_Script = registered_scripts.get(registered_script)
			if registry:
				if script == registry.script_type:
					return registry
	return null

func is_script_registered(script_name : StringName = "", script : Script = null) -> bool:
	if script_name:
		var registry : Registered_Script = registered_scripts.get(script_name)
		if registry:
			return true
	if script:
		for registered_script : String in registered_scripts:
			var registry : Registered_Script = registered_scripts.get(registered_script)
			if registry:
				if script == registry.script_type:
					return true
	print("Script with name: %s and script: %s is not registered." % [script_name, script])
	return false

class Registered_Script:
	
	var script_name : StringName = ""
	var script_type : Script = null
	var registered_properties : Array[StringName] = []
	var registered_functions : Array[Registered_Method] = []

	func _init(new_script_name : String = "", new_script_type : Script = null) -> void:
		script_name = new_script_name
		script_type = new_script_type
		return

	func _get_script_name() -> Variant:
		if script_name == null:
			if script_type.resource_name:
				return script_type.resource_name
			if script_type != null:
				return script_type.get_global_name()
		return script_name

	func remove_registered_property(property_name : StringName) -> void:
		if registered_properties.has(property_name) : 
			registered_properties.erase(property_name)
		return
	
	func register_property(property_name : StringName) -> void:
		var properties = script_type.get_property_list()
		if !properties.has(property_name):
			print("%s does not have property with the name: %s" % [_get_script_name(), property_name])
			return
		registered_properties.append(property_name)
		return

class Registered_Method:
	
	var method_name : StringName = ""
	var method_arguments : Array = []
	var method_return : Variant = null
