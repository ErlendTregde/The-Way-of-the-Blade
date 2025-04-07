# scripts/TimerManager.gd
extends Node

var time := 0.0
var running := false
var last_run_time := 0.0  # New!

func _process(delta):
	if running:
		time += delta

func start():
	time = 0.0
	running = true

func stop():
	running = false
	last_run_time = time

func get_time() -> float:
	return time

func get_last_time() -> float:
	return last_run_time
