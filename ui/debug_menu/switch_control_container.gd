extends Control

@export var ph_switch_control: Node

var switch_list = {
    switch_01 = false,
    switch_03 = true,
    switch_04 = true,
    switch_05 = true,
    switch_06 = true,
    switch_07 = true,
    switch_08 = true,
    switch_09 = true,
    switch_10 = true,
    switch_11 = true,
    switch_12 = true,
    switch_13 = true,
    switch_14 = true,
    switch_15 = true,
    switch_16 = true,
    switch_17 = true,
    switch_18 = true,
    switch_19 = true,
    switch_20 = true,
    switch_21 = true,
    switch_22 = true,
    switch_23 = true,
    switch_24 = true,
    switch_25 = true,
    switch_26 = true,
    switch_27 = true,
    switch_28 = true,
    switch_29 = true,
    switch_30 = true,
    switch_31 = true,
    switch_32 = true,
    switch_33 = true,
    switch_34 = true,
    switch_35 = true,
}


func _ready() -> void:
    var switch_control_list = []
    for switch_key in switch_list.keys():
        var control =(ph_switch_control as InstancePlaceholder).create_instance()
        control.id = switch_key
        control.value = switch_list[switch_key]
        switch_control_list.append(control)
    
