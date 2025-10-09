@tool
extends EditorPlugin

const AUTOLOAD_NAME = "VEditor"
const VISUAL_EDITOR = preload("res://addons/visual_framework/Scenes/Visual Editor/Graph/Visual_Editor_Main.tscn")
const PLUGIN_FILE_PATH : StringName = &"res://addons/visual_framework/plugin.cfg"

var autoload_path : String = "res://addons/visual_framework/Scenes/Visual Editor/Graph/Visual_Editor_Singleton.tscn"
var visual_editor_instance
var file : ConfigFile

func _enable_plugin() -> void:
	file = ConfigFile.new()
	if file.load(PLUGIN_FILE_PATH) != OK:
		push_error("Unable to load plugin config file. Was it installed correctly? path [%s]" % [PLUGIN_FILE_PATH])
		return
	var details = _get_plugin_details()
	print_rich("loaded plugin: [b]%s[/b]\n\t\t\t╰› version: [b]%s[/b]\n\t\t\t╰› author: [b]%s[/b]" % \
						 [details["name"], details["version"], details["author"]])
	_make_visible(false)
	add_autoload_singleton(AUTOLOAD_NAME, autoload_path)

func _disable_plugin() -> void:
	var details = _get_plugin_details()
	print_rich("unloaded plugin: [b]%s[/b]\n\n[b]NOTE[/b] : Disabling the visual framework will break all plugins that depend on it. Please disable all plugin with it as a dependancy." % \
						 [details["name"]])
	if visual_editor_instance :
		visual_editor_instance.queue_free()
	remove_autoload_singleton(AUTOLOAD_NAME)
	return

func _get_plugin_details() -> Dictionary:
	var details : Dictionary = {}
	var keys = file.get_section_keys("plugin")
	for key in keys:
		details[key] = file.get_value("plugin", key)
	return details

func _enter_tree() -> void:
	visual_editor_instance = VISUAL_EDITOR.instantiate()
	EditorInterface.get_editor_main_screen().add_child(visual_editor_instance)
	_make_visible(false)

func _exit_tree() -> void:
	if visual_editor_instance :
		visual_editor_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if visual_editor_instance :
		visual_editor_instance.visible = visible

func _get_plugin_name() -> String :
	return "Visual Editor"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("2D", "EditorIcons")
