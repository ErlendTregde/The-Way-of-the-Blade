extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var enemies_label: Label = $EnemiesLabel

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		# Update timer
		if TimeManager.running:
			timer_label.text = "Time: %.2f" % TimeManager.get_time()

		# Update enemies left
		var enemies = get_tree().get_nodes_in_group("enemies").size()
		enemies_label.text = "Enemies Left: %d" % enemies
