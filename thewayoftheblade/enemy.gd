extends CharacterBody3D

@export var max_health := 3
var health := max_health

@onready var damage_label: Label3D = $DamageLabel

func _ready() -> void:
	add_to_group("enemies")


func take_damage(amount: int) -> void:
	print("Enemy hit! Damage taken:", amount)

	health -= amount
	damage_label.text = "-" + str(amount)
	damage_label.visible = true

	await get_tree().create_timer(0.5).timeout
	damage_label.visible = false

	print("Remaining health:", health)

	if health <= 0:
		print("Enemy died.")
		get_tree().call_group("players", "on_enemy_killed")
		queue_free()
