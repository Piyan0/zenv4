class_name EventManager
extends Node

signal map_refreshed(events)

static var current_internal_switch_id: String
static var current_event_id: String

var interpreter : PiyanScriptingLanguage
var can_process_interact = func(): return true

var _current_input: InputEvent= InputEventAction.new()
var _is_running_event= false


func _init(p_owner):
    p_owner.add_child(self)
    name= "EventManager"
    
    
func _unhandled_input(event):
    if !can_process_interact.call():
        return
    if event is InputEventAction || event is InputEventKey || event is InputEventJoypadButton:
        # print(event.device)
        _current_input= event


func _process(_delta):
    var events_in_area= get_tree().get_nodes_in_group("events")
    for i in events_in_area:
        if _is_running_event: break
        var player= Player.instance
        # Don't process further if player hasn't been instantiated.
        if !player: return
        if i.is_interact(player, _current_input):
            current_internal_switch_id = i.get_internal_switch_id()
            current_event_id = i.name
            _is_running_event= true
            player.lock_counter += 1
            i.interact(player)
            await i.interact_finished
            await _delay_after_interact()
            _is_running_event= false
            if is_instance_valid(player):
                player.lock_counter -= 1
                
            _current_input = null
            current_internal_switch_id = ""
            current_event_id = ""


func process_command(text):
    await interpreter.from_text(text)
    
    
func refresh_map(internal_switches, variables, global_switches, tag_list):
    var events= get_tree().get_nodes_in_group("events")
    for i: Event in events:
        i.update_active_event(internal_switches, variables, global_switches, tag_list)
    
    map_refreshed.emit(events)
    _reset()


func _reset():
    # _is_running_event = false
    _current_input = null
  

func get_event(id: String):
    for i in get_tree().get_nodes_in_group("events"):
        if i.name == id:
            return i
    assert(false, "No event with 'id' of '{0}' in the current scene.".format([id]))
    return null


func _delay_after_interact():
    await get_tree().process_frame