extends Control


@export var ph_variable_control: Node

var switch_list = {
    switch_01 = 123,
    switch_02 = 123,
    switch_03 = 123,
    switch_04 = 123,
    switch_05 = 123,
    switch_06 = 123,
    switch_07 = 123,
    switch_08 = 123,
    switch_09 = 123,
    switch_10 = 123,
    switch_11 = 123,
    switch_12 = 123,
    switch_13 = 123,
    switch_14 = 123,
    switch_15 = 123,
    switch_16 = 123,
    switch_17 = 123,
    switch_18 = 123,
    switch_19 = 123,
    switch_20 = 123,
    switch_21 = 123,
    switch_22 = 123,
    switch_23 = 123,
    switch_24 = 123,
    switch_25 = 123,
    switch_26 = 123,
    switch_27 = 123,
   
}


func _ready() -> void:
    for switch_key in switch_list.keys():
        var control =(ph_variable_control as InstancePlaceholder).create_instance()
        control.id = switch_key
        control.value = switch_list[switch_key]
    