extends Control

signal switch_toggled(id, value)

@export var ph_switch_switch_control: Node

var switch_list = {}:
    set(v):
        switch_list = v
        for switch_key in switch_list.keys():
            var control =(ph_switch_switch_control as InstancePlaceholder).create_instance()
            control.id = switch_key
            control.value = switch_list[switch_key]
            control.value_changed.connect(func(value):
                switch_toggled.emit(control.id, value)
            )
