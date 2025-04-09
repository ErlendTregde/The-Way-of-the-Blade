extends Control

@onready var return_button: Button = $VBoxContainer/ReturnButton
@onready var time_label: Label = $VBoxContainer/TimeLabel

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    var t := TimeManager.get_last_time()
    time_label.text = "Time: %.2f seconds" % t

    if not return_button.pressed.is_connected(_on_return_button_pressed):
        return_button.pressed.connect(_on_return_button_pressed)

func _on_return_button_pressed() -> void:
    get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
