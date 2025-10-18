@tool
extends Node

var v_editor_zoom : Vector2 = Vector2.ONE

## Set the connection type of any pins to Output, Input or Both. Allows you to create multi-directional connections or one-way directions.
enum CONNECTION_TYPE {OUTPUT, INPUT, OUTPUT_INPUT}

## The container for every registered script stored within the script server. Accessible from anywhere. Don't call any methods on this yourself, unless you know what you're doing.[br][br]
## Use these methods to interface with the dictionary instead: [br][br]
## - [method register_script] [br]
## - [method get_registered_scripts] -> [member Dictionary[String, Registered_Script]] [br]
## - [method get_registered_script] -> [member Registered_Script][br]
## - [method is_script_registered] -> [member bool][br]
var registered_scripts : Dictionary[String, Registered_Script]

## Return all of the scripts registered within [member registered_scripts] as a dictionary.
func _get_registered_scripts() -> Dictionary[String, Registered_Script]:
	return registered_scripts

## Built-in, do not use : If a function call is broken, nodes should call a breakpoint or make their own. This exists as a depreciated way to call for any breaks within code. 
func call_breakpoint() -> void:
	breakpoint
	return

## Register a script within the Visual Server. Allows access to it and it's then registered Properties and Methods within the Visual Grid, following whatever implementation of the tool
## you decide to use. This will create an object of type [member Registered_Script][br]you can access this object with [method get_registered_script] and then use the methods within
## the [member Registered_Script] subclass.
func register_script(script_name : StringName = "", script : Script = null) -> void:
	if !script:
		print("Cannot register a script with no given script argument. Called method should look like such: \
			 register_script(\"this_script\", this_script)")
		breakpoint
		return
	if !script_name:
		print("No name given to register script, giving it the same name as it's global_name")
		if script.resource_name:
			script_name = script.resource_name
		if script.get_global_name():
			script_name = script.get_global_name()
	if is_script_registered(script_name, script) : 
		print("The script: %s is already a registered script, returning" % [script_name])
		return
	
	var registry : Registered_Script = Registered_Script.new(script_name, script)
	registered_scripts[script_name] = registry
	return

## Return a registered script with either the name or script_type. This is the object that you can register properties to and methods (functions) to.
func get_registered_script(script_name : StringName = "", script : Script = null) -> Registered_Script:
	if !is_script_registered(script_name, script) : 
		return null
	# Should a script name be given, and it exists as a key, return the registered_script value.
	if script_name:
		var registry : Registered_Script = registered_scripts.get(script_name)
		if registry:
			return registry
	# Should a script name *not* be given, search through all keys, if it has the script_type, return it.
	if script:
		for registered_script : String in registered_scripts:
			var registry : Registered_Script = registered_scripts.get(registered_script)
			if registry:
				if script == registry.script_type:
					return registry
	# This will never be called, but it will return nothing even if it is.
	return null

## Find out of the script is a registered script, returns a true or false value.
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

func create_visual_node_script(registered_script : Registered_Script) -> Visual_Node:
	return null

func create_visual_node_function(registered_function : Registered_Method) -> Visual_Node:
	return null

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
			## These are safeguards in-case the builtin method to create a script_name on class instantiation somehow fail. Ensure that the script is created with a name reflecting its class.
			# Is it a resource?
			if script_type.resource_name:
				script_name = script_type.resource_name
			# Is it a global class?
			elif script_type != null:
				script_name = script_type.get_global_name()
		return script_name

	## If the property exists within this script, removes it from the registry. It cannot then be accessed in the visual editor.
	func remove_registered_property(property_name : StringName) -> void:
		if is_property_registered(property_name) :
			registered_properties.erase(property_name)
		return

	## Check if the property is already registered.
	func is_property_registered(property_name : StringName) -> bool:
		if registered_properties.has(property_name) : return true
		return false

	## Check if the property exists in the script.
	func does_property_exist(property_name : StringName) -> bool:
		var properties = script_type.get_property_list()
		if !properties.has(property_name) : 
			print("%s does not have property with the name: %s" % [_get_script_name(), property_name])
			return false
		return true
	
	## Register a property within this script, allows it to be accessed ([method set] & [method get]) within the visual editor.
	func register_property(property_name : StringName) -> void:
		if !does_property_exist(property_name): return
		if is_property_registered(property_name) :
			registered_properties.append(property_name)
		return

class Registered_Method:
	
	var method_name : StringName = ""
	var method_arguments : Array = []
	var method_return : Variant = null

	func get_method_arguments() -> Array[Variant]:
		return method_arguments
	
	func get_method_return() -> Variant:
		return method_return
