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
func register_script(script_name : StringName = "", script : Script = null) -> Registered_Script:
	if !script:
		print("Cannot register a script with no given script argument. Called method should look like such: \
			 register_script(\"this_script\", this_script)")
		breakpoint
		return null
	if !script_name:
		print("No name given to register script, giving it the same name as it's global_name")
		if script.resource_name:
			script_name = script.resource_name
		if script.get_global_name():
			script_name = script.get_global_name()
	if is_script_registered(script_name, script) : 
		print("The script: %s is already a registered script, returning" % [script_name])
		return null
	
	var registry : Registered_Script = Registered_Script.new(script_name, script)
	registered_scripts[script_name] = registry
	return registered_scripts[script_name]

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
	return false

func create_visual_node_script(registered_script : Registered_Script) -> Visual_Node:
	return null

func create_visual_node_function(registered_function : Registered_Method) -> Visual_Node:
	return null

class Registered_Script:
	
	var script_name : StringName = ""
	var script_type : Script = null
	var registered_properties : Dictionary[StringName, Dictionary] = {}
	var registered_functions : Dictionary[StringName, Registered_Method] = {}

	func _init(new_script_name : StringName = "", new_script_type : Script = null) -> void:
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

	## Register a property within this script, allows it to be accessed ([method set] & [method get]) within the visual editor.
	func register_property(property_name : StringName) -> void:
		if !does_property_exist(property_name): return
		if is_property_registered(property_name) :
			registered_properties[property_name] = {}
		return

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
	
	func does_method_exist(method_name : StringName = &"") -> bool:
		if script_type == null:
			print("Cannot find whether the method: %s exists in a null script: %s" % [method_name, _get_script_name()])
			return false
		for method in script_type.get_script_method_list():
			if method["name"] == method_name:
				return true
		return false

	func get_method(method_name : StringName = &"") -> Registered_Method:
		if !does_method_exist(method_name):
			return null 
		if !registered_functions.has(method_name):
			return null
		return registered_functions[method_name]

	func register_method(method_name : StringName = &"") -> Registered_Method:
		if !does_method_exist(method_name):
			return
		if registered_functions.has(method_name):
			print("This method is already registered within this class.")
			return
		registered_functions[method_name] = Registered_Method.new(script_type, method_name)
		return registered_functions[method_name]

class Registered_Method:
	
	var method_name : StringName = ""
	var method_arguments : Dictionary[StringName, Dictionary] = {}
	var method_return : Dictionary[StringName, Dictionary] = {}

	func _init(in_script : Script = null, new_method_name : StringName = "") -> void:
		## Store the method's name.
		method_name = new_method_name
		## Construct an empty array for all of the potential arguments.
		for method in in_script.get_script_method_list():
			## With every user-defined method, check against it's name. If it matches, grab the arguments list.
			if method["name"] == new_method_name:
				define_method_return(method)
				define_method_arguments(method["args"])
		return

	func define_method_return(method : Dictionary) -> void:
		if method["return"] != null:
			## 0 refers to Nil or Void, you do not need to care about Nil returns.
			if method["return"]["type"] == 0 : return
			var _return = method["return"]
			## TODO : Change the method if it's a dictionary or class as aggregate? Give them an option?
			## Store important information such as the class_name of the return (will change the name of the output pin) and the type (incase it has no global class)
			var return_dict : Dictionary[String, Variant] = {
				"class_name" : _return["class_name"],
				"type" : int(_return["type"]),	
			}
			## Then set the type_string of the type (could be object, or int, or string) and store the dictionary.
			method_return[type_string(int(_return["type"]))] = return_dict
		return
	
	func define_method_arguments(argument_list : Array[Dictionary]) -> void:
		for arg in argument_list:
			## Store it's type and global class (if it has one) within a dictionary
			var arg_dict : Dictionary[String, Variant] = {
				"class_name" : arg["class_name"],
				"type" : int(arg["type"])
			}
			method_arguments[arg["name"]] = arg_dict
