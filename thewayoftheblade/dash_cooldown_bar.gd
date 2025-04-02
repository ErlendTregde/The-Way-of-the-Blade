extends TextureProgressBar

var cooldown_time := 0.5
var timer := 0.0
var cooling_down := false

func start_cooldown():
	cooling_down = true
	timer = cooldown_time
	value = 1.0
	visible = true

func _process(delta):
	if cooling_down:
		timer -= delta
		if timer <= 0:
			timer = 0
			value = 0
			cooling_down = false
			visible = false
		else:
			value = timer / cooldown_time
