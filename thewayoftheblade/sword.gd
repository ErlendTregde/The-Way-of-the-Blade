extends Node3D

@export var damage := 1
@onready var hitbox: Area3D = $HitBox
var is_slashing := false

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_body_entered)

func slash() -> void:
	is_slashing = true
	hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout
	is_slashing = false
	hitbox.monitoring = false

func _on_body_entered(body: Node) -> void:
	if is_slashing and body.has_method("take_damage"):
		body.take_damage(damage)
