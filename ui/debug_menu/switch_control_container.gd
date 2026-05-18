extends VBoxContainer

@export var y: Control
@export var arrow_nav: Control

func _ready() -> void:
    var x = GroupControl.new()
    x.items = y.get_children()
    x.parent = y
    x.group()
