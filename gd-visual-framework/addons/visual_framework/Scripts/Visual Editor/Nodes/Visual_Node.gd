@tool
class_name Visual_Node
extends Control

const MINIMUM_NODE_SIZE : Vector2 = Vector2(450, 150)
const MAXIMUM_NODE_SIZE : Vector2 = Vector2(1000, 5000)

## The total size of the node, clamped to the [member MINIMUM_NODE_SIZE] and [member MAXIMUM_NODE_SIZE].
@export var node_size : Vector2 :
	set(new_size):
		node_size = clamp(new_size, MINIMUM_NODE_SIZE, MAXIMUM_NODE_SIZE)
		set_node_size(node_size)
		return
@export_group("Node Details")
@export_subgroup("Name")
## Change the name of the node, will typically take from the name of the class that you're passing into it by default.
@export var node_name_reference : RichTextLabel
@export var node_name : StringName = &"Node Name" :
	set(new_name) :
		node_name = new_name
		set_node_name(new_name)
		return
@export_subgroup("Header")
## Pass a reference to the node header, to be able to change the colour and reference it where needed.
@export var node_header_reference : ColorRect
@export var header_colour : Color :
	set(new_colour):
		header_colour = new_colour
		set_colour_rect_colour(node_header_reference, new_colour)
		return
@export_subgroup("Body")
## Pass a reference to the node body, to be able to change the colour and reference it where needed.
@export var node_body_reference : ColorRect
@export var body_colour : Color:
	set(new_colour):
		body_colour = new_colour
		set_colour_rect_colour(node_body_reference, new_colour)
		return
@export_subgroup("Outputs")
@export var outputs : VBoxContainer


## Changes the display name of the node, you should use this function for changing the name of the node rather than doing so on the RichTextNode [member Body/Node Name].
func set_node_name(new_name : StringName) -> void:
	if !self.is_node_ready() : await self.ready
	node_name_reference.text = new_name
	return

## Output is to be the "return" or "get" on an object. node_type is for whether it is a script, function or property. Node path is the path to it. It should look like:
## Script
## Script:Property
## Script:Method
func set_node_outputs(output : Variant, node_type = null, node_path : String = "") -> void:
	if !self.is_node_ready() : await ready
	match typeof(output):
		TYPE_OBJECT:
			if node_type == "method":
				if is_instance_of(output, VisualServer.Registered_Method.Tuple):
					var node_paths = node_path.split(":")
					var _script : StringName = node_paths[0]
					var _method : StringName = node_paths[1]

					var script = VisualServer.get_registered_script(_script)
					var method = script.get_method(_method)

					for return_argument in method.method_return.properties:
						var node_output_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node_Output.tscn")
						var node_output : Node_Output = node_output_path.instantiate()
						node_output.output_type = method.method_return.properties[return_argument]["type"]
						node_output.set_output_text(return_argument)
						outputs.add_child(node_output)
					return
	var node_output_path : PackedScene = load("res://addons/visual_framework/Scenes/Visual Editor/Nodes/Node_Output.tscn")
	var node_output : Node_Output = node_output_path.instantiate()
	node_output.output_type = typeof(output)
	node_output.set_output_text(type_string(typeof(output)))
	outputs.add_child(node_output)
	return

## Change the size of the entire node, used to resize when nodes contain more outputs or inputs, or you want to alter the size of the node by default to display
## Images, textures or descriptions.
func set_node_size(new_size : Vector2 = Vector2.ZERO) -> void:
	if !self.is_node_ready() : await self.ready
	_reset_anchors()
	set_deferred("size", new_size)
	set_deferred("position", Vector2(0, 0)) # Reset the position in-case of any wacky interactions.
	return

## Pass in a colour rect and a colour and you can change either the colour of the node body or the node header. With custom nodes this could extend your own
## theme methods, if you don't want to use shaders.
func set_colour_rect_colour(node : ColorRect, in_colour : Color) -> void:
	if !self.is_node_ready() : await self.ready
	set_deferred("node:color", in_colour)
	return

## This exists purely as a way to prevent an annoying warning that on large node graphs would spam the console output, you can safely ignore it.
func _reset_anchors() -> void:
	anchor_left = 0
	anchor_right = 0
	anchor_bottom = 0
	anchor_top = 0
	return
	
