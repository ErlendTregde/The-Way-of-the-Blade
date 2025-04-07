extends Area3D

@export var next_scene_path: String = "res://Scenes/level_complete_ui.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "ProtoController":
		TimeManager.stop()
		get_tree().change_scene_to_file(next_scene_path)
