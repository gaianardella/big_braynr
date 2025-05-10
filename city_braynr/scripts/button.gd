extends Button

func _on_pressed() -> void:
	var scene = load("res://scenes/course__options.tscn").instantiate()
	get_tree().get_root().add_child(scene)  # Add it to the scene tree
	scene.popup_centered()  # Show the popup
