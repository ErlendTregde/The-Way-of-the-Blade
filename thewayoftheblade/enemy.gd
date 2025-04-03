extends CharacterBody3D

@export var max_health := 3
@export var enemy_material_default: Material
@export var enemy_material_hit: Material


var health := max_health

@onready var damage_label: Label3D = $DamageLabel
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("enemies")
	mesh.set_surface_override_material(0, enemy_material_default)

func take_damage(amount: int) -> void:
	print("Enemy hit! Damage taken:", amount)

	health -= amount
	damage_label.text = "-" + str(amount)
	damage_label.visible = true

	# Swap to hit material
	mesh.set_surface_override_material(0.15, enemy_material_hit)

	await get_tree().create_timer(0.3).timeout

	# Reset to default
	mesh.set_surface_override_material(0, enemy_material_default)
	damage_label.visible = false

	print("Remaining health:", health)

	if health <= 0:
		print("Enemy died.")
		get_tree().call_group("players", "on_enemy_killed")
		queue_free()
