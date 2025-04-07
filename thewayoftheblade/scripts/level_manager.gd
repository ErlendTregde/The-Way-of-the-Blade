extends CanvasLayer

@export var next_scene_path: String = "res://scenes/LevelCompleteUI.tscn"
signal level_completed 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "ProtoController":
		print("Level complete!")
		emit_signal("level_completed")
