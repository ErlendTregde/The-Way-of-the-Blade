extends CanvasLayer

@onready var timer_label: Label = $TimerLabel

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and TimeManager.running:
		timer_label.text = "Time: %.2f" % TimeManager.get_time()
