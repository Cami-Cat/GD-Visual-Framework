@tool
extends Label

var animation_length : float = 0.2 # seconds

func _ready() -> void:
	$"../../../../../..".unsaved_state.connect(_show_unsaved)
	return

func _show_unsaved(should_show : bool = false) -> void:
	var tween = create_tween()
	if should_show:
		tween.tween_property(self, "scale", Vector2.ONE, animation_length).set_trans(Tween.TRANS_SINE)
	else:
		tween.tween_property(self, "scale", Vector2(0, 1), animation_length).set_trans(Tween.TRANS_SINE)
	await tween.finished
	tween.kill()
