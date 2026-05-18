extends Control

@export var toggle: CheckButton
@export var lb_id: Label

var value: bool:
    set(p_value):
        if !is_inside_tree():
            await ready
        value = p_value
        toggle.button_pressed = value

var id: String:
    set(value):
        if !is_inside_tree():
            await ready
        id = value
        lb_id.text = value