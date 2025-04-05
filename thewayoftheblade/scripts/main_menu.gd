extends Control

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_main_pressed() -> void:
	get_tree().change_scene_to_file("res://maps/main.tscn")
