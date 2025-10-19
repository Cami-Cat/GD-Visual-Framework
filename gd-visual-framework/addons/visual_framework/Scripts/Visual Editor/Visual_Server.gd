@tool
extends Node

var v_editor_zoom : Vector2 = Vector2.ONE
var visual_grid : Visual_Editor

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

## Built-in, do not use : If a function call is broken, nodes should call a breakpoint or make their own. 
## This exists as a depreciated way to call for any breaks within code. 
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
	
func create_script_visual_node(registered_script : Registered_Script) -> Visual_Node:
	var visual_node_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node.tscn")
	var visual_node : Visual_Node = visual_node_path.instantiate()
	visual_node.set_node_name(registered_script.script_name)
	visual_node.set_node_outputs(registered_script.script_type)
	visual_grid.visual_node_master.add_child(visual_node)
	return null

func create_function_visual_node(registered_function : Registered_Method) -> Visual_Node:
	var visual_node_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node.tscn")
	var visual_node : Visual_Node = visual_node_path.instantiate()
	visual_node.set_node_name(registered_function.method_name)
	visual_node.set_node_outputs(registered_function.method_return, "method", "me:does_method_exist")
	visual_grid.visual_node_master.add_child(visual_node)
	return null


class Registered_Script:
	
	var script_name : StringName = ""
	var script_type : Script = null
	var registered_properties : Dictionary[StringName, Dictionary] = {}
	var registered_methods : Dictionary[StringName, Registered_Method] = {}

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
		print("Method: %s does not exist in script: %s" % [method_name, _get_script_name()])
		return false

	func get_method(method_name : StringName = &"") -> Registered_Method:
		if !does_method_exist(method_name):
			return null 
		if !registered_methods.has(method_name):
			return null
		return registered_methods[method_name]

	func register_method(method_name : StringName = &"") -> Registered_Method:
		if !does_method_exist(method_name):
			return
		if registered_methods.has(method_name):
			print("This method is already registered within this class.")
			return
		registered_methods[method_name] = Registered_Method.new(script_type, method_name)
		return registered_methods[method_name]

class Registered_Method:
	
	var method_name : StringName = ""
	var method_arguments : Dictionary[StringName, Dictionary] = {}
	var method_return : Variant = []

	func _init(in_script : Script = null, new_method_name : StringName = "") -> void:
		## Store the method's name.
		method_name = new_method_name
		## Construct an empty array for all of the potential arguments.
		for method in in_script.get_script_method_list():
			## With every user-defined method, check against it's name. If it matches, grab the arguments list.
			if method["name"] == new_method_name:
				_define_method_return(method)
				_define_method_arguments(method["args"])
		return
	
	## Depreciated : only works on functions that return a single value. Please use [method register_method_return] to return multiple values or just a single one.
	func _define_method_return(method : Dictionary) -> void:
		if method["return"] != null:
			## 0 refers to Nil or Void, you do not need to care about Nil returns.
			if method["return"]["type"] == TYPE_NIL : 
				return
			var _return = method["return"]
			var return_name = type_string(int(_return["type"]))
			## TODO : Change the method if it's a dictionary?
			## Store important information such as the class_name of the return (will change the name of the output pin) and the type (incase it has no global class)
			var return_dict : Dictionary[String, Variant] = {
				"name" : return_name,
				"class_name" : _return["class_name"],
				"type" : int(_return["type"]),	
			}
			## Then set the type_string of the type (could be object, or int, or string) and store the dictionary.
			method_return.append(return_dict)
		return
	
	func _define_method_arguments(argument_list : Array[Dictionary]) -> void:
		for arg in argument_list:
			## Store it's type and global class (if it has one) within a dictionary
			var arg_dict : Dictionary[String, Variant] = {
				"class_name" : arg["class_name"],
				"type" : int(arg["type"])
			}
			method_arguments[arg["name"]] = arg_dict

	func create_tuple(in_dictionary : Dictionary[String, Variant]) -> Tuple:
		var tuple = Tuple.new(in_dictionary)
		return tuple

	func set_tuple_return(to_tuple : Tuple) -> void:
		method_return = to_tuple
		return

	class Tuple:
		
		var properties : Dictionary[String, Dictionary] = {}
		var _class_name : StringName = &"Tuple"
		
		func _init(properties : Dictionary[String, Variant] = {}) -> void:
			for property in properties:
				if !typeof(properties[property]) == TYPE_OBJECT:
					store_var(property, properties[property])
					continue
				store_class(property, properties[property])
			return
		
		func get_class_name() -> StringName:
			return _class_name
		
		func store_var(property_name : StringName, property_type : Variant) -> void:
			var property_dict : Dictionary = {
				"type" : property_type,
				"type_name" : type_string(property_type),
				"value" : null,
			}
			properties[property_name] = property_dict
			return
		
		func store_class(property_name : StringName, property_type : Object) -> void:
			var property_class_name : StringName = "Object"
			if property_type.get_class() == "GDScriptNativeClass":
				## If you're using a builtin abstract type or a builtin-type with no instantiation You are likely to get errors here. (see Script, FileAccess, DirAccess),
				## They are still stored correctly, but they are not accessible by class_name.
				## This is the only method after hours of erroneous work that I could figure out, despite multiple times using "get_class()" and it not returning the correct value.
				## TODO : Find a way to... Not do that. And do it better.
				var _property_instance = property_type.new()
				if _property_instance != null:
					if _property_instance.has_method("get_class"):
						property_class_name = _property_instance.get_class()
			## At the very least, custom classes are protected as they'll always return GDScript as their base class, and all will either have resource_names or global_names.
			## You cannot use a class as an argument if you don't have the class named in some way.
			elif property_type.get_class() == "GDScript":
				if property_type.resource_name:
					property_class_name = property_type.resource_name
				if property_type.get_global_name():
					property_class_name = property_type.get_global_name()
				else:
					## However, for subclasses you have to do a little bit of extra work in order to get the correct name that you want.
					## When defining a new custom subclass, please ensure that you have the method get_class_name() *and* that the subclass isn't massive.
					## Otherwise, please create a main class and skip this.
					var _property_instance = property_type.new()
					if _property_instance.has_method("get_class_name"):
						property_class_name = _property_instance.get_class_name()
			var property_dict : Dictionary = {
				"type" : TYPE_OBJECT,
				"class" : property_type,
				"class_name" : property_class_name,
				"value" : null,
			}
			properties[property_name] = property_dict
			return
			
		func get_property_value(property_name : StringName) -> Variant:
			return properties[property_name]["value"]
