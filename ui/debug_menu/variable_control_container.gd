extends Control

signal variable_changed(id, value)

@export var ph_variable_control: Node

var variable_list = {}:
    set(v):
        variable_list = v
        for var_id in variable_list.keys():
            var control =(ph_variable_control as InstancePlaceholder).create_instance()
            control.id = var_id
            control.value = int(variable_list[var_id])
            control.value_changed.connect(func(value):
                variable_changed.emit(control.id, value)
            )
        