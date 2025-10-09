# GD-Visual-Framework (Godot 4.5)
A visual framework for developing tools using a node-based grid system. Inspired by Unreal Engine's blueprinting and C++ Reflection system.

This project is currently unfinished, it is part of a University Module whose deadline ends sometime in `January, 2026`. If you're interested in developing on this framework, feel free to make a fork and add any changes you might like.

It also has a TODO, how fancy. There's quite a lot to get done but this is the gist of it thus far:
- Add node connections between Outputs and Inputs
- Allow Outputs to also act as Inputs if a developer wishes
- Create Script, Property and Function registry within GDScript
- Create a Script Server to load and save these in memory
- Serialize the Visual Grid upon a save and save to a user-specified or default location (`"res://addons/visual_framework/visual_grids"`)
- Write in-depth documentation to help people create their own Nodes.
- Create an example level transitions system to connect complex levels with story-implications.
- ...

The list continues for an eternity, and I'd rather not bore you to death. All of the code used in this project is GDScript, though I would love to delve into GDExtension to maybe add greater support and functionality to the Visual Framework another time.

# Attributions

### ["Jetbrains Mono Collection" by Jetbrains](https://www.jetbrains.com/lp/mono/)
### [Dotted Grid 2D Shader (improved) by Trastaroots](https://godotshaders.com/shader/dotted-grid-2d/)

# Introduction & How it works

The Godot Visual Framework is not in itself a tool that you can just use straight out of the box. This is a tool that you have to then add to to create your own stuff. Though I'm hoping to minimize the amount of work you have to do to get it to work the way that you want it to.

So lets just get into the nitty gritty with a simple introduction to the Grid System:
[Add node PNG]

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
Say for example, you want to return multiple values with different types, GDScript doesn't natively support Tuples nor Structs, so you will be left to use a Class as aggregate or a Dictionary with the Key being the name of the property. This can get clunky in code, if you're constructing a million classes just for a return, or returning a dictionary whose safety you cannot guarantee always.

I would recommend using class as aggregate, as it's easily callable elsewhere should you need to access the subclass. (These will need to be registered as `return_type`)

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

This is not an example of using a class as aggregate for a return, but it should showcase just how easy it is to create a class within a class.

Inputs, however, have it much easier. With Function arguments constructing themselves or, should you use a [variadic function](https://github.com/godotengine/godot-proposals/issues/1034), the ability to add them dynamically. Please ensure that your functions have type-safety if you are using variadic functions.
Inputs also work as arguments for constructors, so you can construct anything on the fly should you need to - though this is getting into the territory of Visual Scripting, which is not what this is built as.

If you wish to create your own Node type, with Output/Inputs, specific size with a specific use-case; for a grid that does not follow the same rules as the Unreal Engine Blueprinting system, then you can extend the Visual Node scene using an Inherited Scene and change it to fit your needs as you wish. If you want to overload certain functions in the base visual node script, you can also extend that or alter the default script. Though I would recommend overloading / polymorphism instead, keeping base functionality should you extend it once again.

# Documentation

Crickets...
