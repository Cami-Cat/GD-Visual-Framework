# GD-Visual-Framework (Godot 4.5)
A visual framework for developing tools using a node-based grid system. Inspired by Unreal Engine's blueprinting and C++ Reflection system.

This project is currently unfinished, it is part of a University Module whose deadline ends sometime in `January, 2026`. If you're interested in developing on this framework, feel free to make a fork and add any changes you might like.

It also has a TODO, how fancy. There's quite a lot to get done but this is the gist of it thus far:
- ~~Add node connections between Outputs and Inputs~~ ( Completed )
- ~~Allow Outputs to also act as Inputs if a developer wishes~~ ( Completed )
- ~~Create Script, Property and Function registry within GDScript~~ ( Completed)
- ~~Create a Script Server to load and save these in memory~~ ( Completed )
- Create an example level transitions system to connect complex levels with story-implications.
- Write in-depth documentation to help people create their own Nodes.
- Serialize the Visual Grid upon a save and save to a user-specified or default location (`"res://addons/visual_framework/visual_grids"`)

The list continues for an eternity, and I'd rather not bore you to death. All of the code used in this project is GDScript, though I would love to delve into GDExtension to maybe add greater support and functionality to the Visual Framework another time.

# Attributions

### ["Jetbrains Mono Collection" by Jetbrains](https://www.jetbrains.com/lp/mono/)
### [Dotted Grid 2D Shader (improved) by Trastaroots](https://godotshaders.com/shader/dotted-grid-2d/)

# Introduction & How it works

The Godot Visual Framework is not in itself a tool that you can just use straight out of the box. This is a tool that you have to then add to to create your own stuff. Though I'm hoping to minimize the amount of work you have to do to get it to work the way that you want it to.

So lets just get into the nitty gritty with a simple introduction to the Grid System:
![alt text](https://github.com/Cami-Cat/GD-Visual-Framework/blob/1cbeed4eb9e4284a33ee8048df83090319f62151/images/NODE.png "Node Image")

This is a Node, they're the basis of everything in this Framework. A node can construct itself based on a registered script, or you can create your own through inherited scenes. Nodes have a few parts that might be interesting:
### Node Header
The node header is the coloured strip at the top of the node. This can and will denote the type of a node, including built-in types (planned feature). Objects will have a base header colour; however, you have full control over this property per script or on a larger scale.
### Node Name
The name of the node denotes what it is or does: 
- It might be named after a class, and is thus only a reference to an object or resource.
- It might be a property, in which case it will be prefixed with either "set" or "get"
- It might be a function, if there are arguments it will have Inputs. If it is a [variadic function](https://github.com/godotengine/godot-proposals/issues/1034), it will have a number of inputs that you can add yourself.
- It could be an enumerator
- Or an Image reference

All of the above are fully possible within the node system, and the functionality will be supported. For the time being, however, this is in an unsuable state as I slowly work on it and update it with much needed features and frills.

### Node Outputs and Inputs
Node Outputs are either getters (for properties) or returns (from functions), this is where some issues may arise if you want a complex function
Say for example, you want to return multiple values with different types, GDScript doesn't natively support Tuples nor Structs, so you would be left to use a Class as aggregate or a Dictionary with the Key being the name of the property. This can get clunky in code. Which is why I created my own tuple object, where you can add a property name and the type that it will return.

If you don't want to use the custom Tuple object, I would suggest using a class as aggregate. This can be a subclass, a global class or even a resource, so long as you have the ability to reference it. (These will need to be registered as `return_type`)

If you don't know the syntax for constructing a class within a class, here's an example:

```gdscript
class_name Empty_Class
extends Node

func _ready() -> void:
  construct_subclass()
  return

func construct_subclass() -> void:
  var subclass = Empty_Class_Subclass.new()
  subclass.empty_class_subclass_func()
  return

class Empty_Class_Subclass:
  var empty_class_subclass_var : Variant

  func empty_class_subclass_func() -> Variant
    return empty_class_subclass_var
```

Inputs, however, have it much easier. With Function arguments constructing themselves or, should you use a [variadic function](https://github.com/godotengine/godot-proposals/issues/1034), the ability to add them dynamically. Please ensure that your functions have type-safety if you are using variadic functions.

Inputs also work as arguments for constructors, so you can construct anything on the fly should you need to - though this is getting into the territory of Visual Scripting, which is not what this is built as.

If you wish to create your own Node type, with Output/Inputs, specific size with a specific use-case; for a grid that does not follow the same rules as the Unreal Engine Blueprinting system, then you can extend the Visual Node scene using an Inherited Scene and change it to fit your needs as you wish. If you want to overload certain functions in the base visual node script, you can also extend that or alter the default script. Though I would recommend overloading / polymorphism instead (as an inherited class), keeping base functionality should you extend it once again.

# Documentation

To get started you might want to create a scene instance of the Visual Node scene (`res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node.tscn`), this will let you create custom Node appearances using it as a base.
If you want to make your own custom node type you can extend the Visual Node script (`res://addons/visual_framework/Scripts/Visual Editor/Nodes/Visual_Node.gd`). This will give you full control over the node behaviour.

The Visual_Server supports registering Scripts, Methods and Properties currently. With the main functions being:
```gdscript
Visual_Server.register_script(script_name : StringName = "", script : Object = null)
Visual_Server.Registered_Script.register_property(property_name : StringName)
Visual_Server.Registered_Script.register_method(method_name : StringName)
```

By default, as stated prior, Godot doesn't natively support Tuples. As a solution to this, I have created my own Tuple object instead. This can be accessed as a subclass of Registered_Method.
I do intend in the future to add this as a global class instead of a subclass, but for now this is the only place that needs a Tuple return.

```gdscript
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
```

You're free to alter this code if you have any specific needs or you know that you can make a better Tuple object. If you do have a better solution, don't hesitate to reach out in the Issues tab and I'll see what I can do about it (so long as it doesn't affect the University grade, it might have to go on a fork)

Node interconnectivity is handled by the Node_Pin object, which can be either Input, Output or Two_Way. If you right click on the node it will clear all connections it has. You can drag from inputs to outputs and from outputs to inputs and it should still work.

The Node_Pin object *will* have signals and functions that allow it to obtain information and then share that information with it's owning Node. The value will not be stored on the node itself but will instead be stored on the Pin, until another node calls for the value from it.

If the node is a Function type, there will be functionality to call the method every time for different results, as it should work. Currently, this does not exist.
