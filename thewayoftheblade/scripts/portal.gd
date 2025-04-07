extends Area3D

@export var next_scene_path: String = "res://Scenes/level_complete_ui.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "ProtoController":
		var enemies_left = get_tree().get_nodes_in_group("enemies").size()

		if enemies_left == 0:
			print("All enemies defeated. Proceeding to level complete.")
			TimeManager.stop()
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Enemies remaining: %d. Cannot finish level yet." % enemies_left)
