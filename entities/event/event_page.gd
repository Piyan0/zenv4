class_name EventPage
extends Resource

const EMPTY= "empty"

enum Direction {UP, DOWN, LEFT, RIGHT}
enum Trigger{ PLAYER_TOUCH, INTERACT_BUTTON, AUTORUN }
enum InternalSwitch { NONE, A = 1, B = 2, C = 3, D = 4}
enum Placement { BELOW_GROUND=1, GROUND, ABOVE_GROUND }


# TODO add event graphic resources.
@export_group("graphics")
@export var graphic: Texture2D
@export var graphic_offset= Vector2.ZERO
@export_group("")

@export_group("animations")
@export var direction: Direction
@export var walk_animations: WalkAnimationCollection
@export var idle_animations: IdleAnimationCollection
@export_group("")

@export_group("conditions")
@export var trigger: Trigger= Trigger.INTERACT_BUTTON
@export var placement: Placement= Placement.GROUND
@export var through = false
@export var internal_switch: InternalSwitch
# TODO add item conditions.
@export var variable: String= EMPTY
@export var variable_value: int= -1
@export var global_switch_001: String= EMPTY
@export var global_switch_002: String= EMPTY
@export var tags: String= EMPTY
@export_group("")

@export_group("debug")
@export var force_active = false
@export var force_disabled = false
@export_group("")

@export_group("command")
## Dipisahkan dengan koma. Contoh: arg1, arg2.
@export_multiline var arguments: String
@export var event_traits: Array[EventTrait]
@export_file("*.psl") var event_command: String
@export_group("")


func get_arguments():
    var args = {}
    var split_args = arguments.split(",")
    for i in range(0, split_args.size()):
        args[str("_", i)] = split_args[i].strip_edges()
    
    return args


func is_event_active(
        internal_switches,
        variables,
        global_switches,
        tag_list
        ):
    if OS.is_debug_build():
        if force_active:
            return true
        elif force_disabled:
            return false
            
    # print(global_switches)
    var conditions= [
        _internal_switch_pass(internal_switches),
        _variable_pass(variables),
        _switch_pass(global_switch_001, global_switches),
        _switch_pass(global_switch_002, global_switches),
        _tag_pass(tag_list),
    ]
    for i in conditions:
        if i == false:
            return false
    
    return true
    

func _internal_switch_pass(switches):
    assert(!switches.is_empty(), str(switches))
    if internal_switch == InternalSwitch.NONE: return true
    # printt(switches, internal_switch)
    return switches[str(internal_switch)] == true


func _variable_pass(variables):
    if variable == EMPTY: return true
    return variables[variable] == variable_value


func _switch_pass(switch_name, switches):
    if switch_name == EMPTY: return true
    return switches[switch_name] == true


func _tag_pass(tag_list: Array):
    if tags == EMPTY:
        return true
    var tag_split = tags.split(",")
    var is_passed = Array(tag_split).all(func(tag):
        return tag in tag_list
    )
    # printt(is_passed, tag_split, tag_list)
    return is_passed
    
