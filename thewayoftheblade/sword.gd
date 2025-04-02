extends Node3D

@export var damage := 1
@onready var hitbox = $HitBox

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_body_entered)

func slash() -> void:
	hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
