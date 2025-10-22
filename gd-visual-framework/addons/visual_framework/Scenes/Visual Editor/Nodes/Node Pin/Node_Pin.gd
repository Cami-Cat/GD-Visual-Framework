@tool
class_name Node_Pin
extends Control

## The currently loaded theme, stored here for comparison.
var current_theme : Theme = load("res://addons/visual_framework/Assets/Themes/Visuals/Node Pins/Node_Pin_Output.tres")

enum CONNECTION_TYPES {INPUT, OUTPUT, TWO_WAY}

@export_group("Pin Type")
## The connection type of the pin, how it acts with other pins. It can be [member OUTPUT], [member INPUT] and [member TWO_WAY].
@export var connection_type : CONNECTION_TYPES = CONNECTION_TYPES.OUTPUT :
	set(type):
		connection_type = type
		_update_pin_connection_type(type)
		return
## The literal TYPE of the pin, such as TYPE_INT, TYPE_OBJECT, etc.
@export var pin_type : Variant.Type :
	set(type):
		pin_type = type
		_set_pin_colour(type)
## If the pin is of TYPE_OBJECT, this will be filled in.
var pin_class : Object = null
## The name of the pin, typically just typestring(pin_type)
var pin_class_name : StringName = &""
@export_group("Node Connections")
## Important node references in order to be able to change their values correctly.
@export var pin: RichTextLabel
@export var pin_name: RichTextLabel

## The actual value of the pin, set when a function is finished or when a get/set signal is sent.
var pin_value : Variant

## Update the look of the connection pin to reflect if it's a [member Input], [member Output] or [member Two_Way] pin
func _update_pin_connection_type(new_type : CONNECTION_TYPES) -> void:
	var theme_path : String = ""
	match new_type:
		CONNECTION_TYPES.INPUT:
			theme_path = "res://addons/visual_framework/Assets/Themes/Visuals/Node Pins/Node_Pin_Input.tres"
		CONNECTION_TYPES.OUTPUT:
			theme_path = "res://addons/visual_framework/Assets/Themes/Visuals/Node Pins/Node_Pin_Output.tres"
		CONNECTION_TYPES.TWO_WAY:
			theme_path = "res://addons/visual_framework/Assets/Themes/Visuals/Node Pins/Node_Pin_Two_Way.tres"
	_set_pin_theme(theme_path)
	return

## Actually set the theme, only if it's not the same as the current one.
func _set_pin_theme(theme_path : StringName) -> void:
	if current_theme.resource_path != theme_path :
		var _theme = load(theme_path)
		pin.theme = _theme
		current_theme = _theme

## Set the colour of the pin to match the colour in the TYPE_PALETTE you can find by default at:
## ("res://addons/visual_framework/Assets/Colour Palettes/Visual Node/Type_Colours.tres")
func _set_pin_colour(pin_type : Variant) -> void:
	if !self.is_node_ready() : await self.ready
	pin.modulate = VisualPalette.type_palette.colors[pin_type]
	return
