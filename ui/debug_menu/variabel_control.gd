extends MarginContainer

signal value_changed(value)

@export var lb_id: Label
@export var ln_value: SpinBox

var value:
    set(v):
        if !is_inside_tree():
            await ready
        value = v
        ln_value.value = v


var id:
    set(v):
        if !is_inside_tree():
            await ready
        id = v
        lb_id.text = v
        
        
func _ready():
    ln_value.value_changed.connect(value_changed.emit)
    
