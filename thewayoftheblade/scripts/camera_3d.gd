extends Camera3D

var shake_amplitude := 0.0
var shake_timer := 0.0
var original_position := Vector3.ZERO

func _ready():
	original_position = position

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		var offset := Vector3(
			(randf() - 0.5) * shake_amplitude,
			(randf() - 0.5) * shake_amplitude,
			(randf() - 0.5) * shake_amplitude
		)
		position = original_position + offset
	else:
		position = original_position

func shake(duration: float, amplitude: float):
	shake_timer = duration
	shake_amplitude = amplitude
