@tool
class_name Popup_Context_Menu
extends Control

signal animation_finished()

const MINIMUM_SIZE : Vector2 = Vector2(280, 300)
const MAXIMUM_SIZE : Vector2 = Vector2(400, 1680)

@export_group("Size")
@export var popup_menu_size : Vector2 = Vector2.ZERO :
	set(new_size) :
		new_size = Vector2(clamp(new_size.x, MINIMUM_SIZE.x, MAXIMUM_SIZE.x), clamp(new_size.y, MINIMUM_SIZE.y, MAXIMUM_SIZE.y))
		popup_menu_size = new_size
		_set_size(new_size)
		return
@export_group("Background")
@export var menu_bg : ColorRect
@export var menu_bg_colour : Color :
	set(new_colour) :
		menu_bg_colour = new_colour
		if menu_bg != null : _update_node_colour(menu_bg, new_colour)
@export_group("Animation")
@export var animate_opening : bool = true
@export var animation_length : float = 0.35

var mouse_over : bool = false
var animating : bool = false
var open : bool = false

func _ready() -> void:
	_reset_anchors()
	_set_size(popup_menu_size)
	if menu_bg != null : _update_node_colour(menu_bg, menu_bg_colour)
	self.hide()
	return

func _input(event: InputEvent) -> void:
	if VisualServer.mouse_over_pin != null : return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					if mouse_over:
						if open : return
					open_menu()
					return
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			if not open : return
			if animating : await animation_finished
			close_menu()
			return
	return

func open_menu() -> void:
	if animating : await animation_finished
	size.y = 0.0 # Reset just the height of the menu
	global_position = (get_global_mouse_position())
	show()
	await _animate_size(popup_menu_size, animation_length)
	open = true
	return

func close_menu() -> void:
	await _animate_size(Vector2(popup_menu_size.x, 0.0), animation_length)
	hide()
	open = false
	return

func _set_size(in_size : Vector2) -> void:
	if !is_node_ready() : await self.ready
	size = in_size
	return

func _animate_size(in_size : Vector2, length_seconds : float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "size", in_size, length_seconds).set_trans(Tween.TRANS_EXPO)
	await tween.finished
	animation_finished.emit()
	tween.kill()
	return

func _update_node_colour(node : ColorRect, new_colour : Color) -> void:
	if !node.is_node_ready() : await node.ready
	node.color = new_colour
	return

func _reset_anchors() -> void:
	anchor_bottom = 0
	anchor_top = 0
	anchor_right = 0
	anchor_left = 0
	return

func _on_menu_background_mouse_entered() -> void:
	mouse_over = true

func _on_menu_background_mouse_exited() -> void:
	mouse_over = false
