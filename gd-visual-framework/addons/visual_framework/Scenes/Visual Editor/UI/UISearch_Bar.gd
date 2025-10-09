@tool
class_name Search_Bar
extends LineEdit

@export var connected_list : BoxContainer

func search(for_string : String = "") -> void:
	for_string = for_string.to_lower()
	if for_string == "" : 
		for member in connected_list.get_children() : member.show()
		return
	for member in connected_list.get_children():
		var lower_text = member.text.to_lower()
		if !lower_text.contains(for_string) : member.hide()
		else : member.show()
		continue
	return

func _on_text_changed(new_text: String) -> void:
	search(new_text)
