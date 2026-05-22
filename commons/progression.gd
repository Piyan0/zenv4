class_name Progression

signal entries_changed(internal_switches, variables, global_switches)

const KEY_INTERNAL_SWITCHES= "_internal_switches"
const KEY_GLOBAL_SWITCHES= "_global_switches"
const KEY_VARIABLES= "_variables"
const KEY_TAG = "_tag_list"

var variable_source: String
var global_switch_source: String
var _variables= {}
var _global_switches= {}
var _internal_switches= {}
var _tag_list= ["tag", "tag2"]

func _init(p_var_source, p_switch_source):
    variable_source= p_var_source
    global_switch_source= p_switch_source
    
    var var_cfg= ConfigFile.new()
    var_cfg.load(variable_source)
    var g_switch_cfg= ConfigFile.new()
    g_switch_cfg.load(global_switch_source)
    _variables= _cfg_to_json(var_cfg)
    _global_switches= _cfg_to_json(g_switch_cfg)
    # print(_global_switches)


func set_data(data):
    assert(KEY_VARIABLES in data && KEY_GLOBAL_SWITCHES in data && KEY_INTERNAL_SWITCHES in data , "param 'data' should contains fields: '_variables', '_global_switches' and '_internal_switches'. 'data' fields: "+ str(data.keys()))
    _variables= data[KEY_VARIABLES]
    _global_switches= data[KEY_GLOBAL_SWITCHES]
    _internal_switches= data[KEY_INTERNAL_SWITCHES]
    _tag_list= data[KEY_TAG]
    
    
func get_data():
    return {
        KEY_VARIABLES : _variables,
        KEY_GLOBAL_SWITCHES : _global_switches,
        KEY_INTERNAL_SWITCHES : _internal_switches,
        KEY_TAG : _tag_list
    }


func get_var_keys():
    return _variables.keys()


func get_global_switch_keys():
    return _global_switches.keys()


func has_global_switch(key):
    return key in _global_switches


func has_var(key):
    return key in _variables


func has_internal_switch(key):
    return key in _internal_switches


func set_switch(key, value):
    _assert_key_exist(key, _global_switches, "_global_switches")
    _global_switches[key]= value
    entries_changed.emit(_internal_switches, _variables, _global_switches, _tag_list)


func try_set_switch(key, value) -> Error:
    if !key in _global_switches:
        return FAILED
        
    set_switch(key, value)
    return OK


func get_switch(key):
    _assert_key_exist(key, _global_switches, "_global_switches")
    return _global_switches[key]


func set_var(key, value):
    _assert_key_exist(key, _variables, "_variables")
    _variables[key]= value
    entries_changed.emit(_internal_switches, _variables, _global_switches, _tag_list)


func try_set_var(key, value) -> Error:
    if !key in _variables:
        return FAILED
        
    set_var(key, value)
    return OK


func get_var(key):
    _assert_key_exist(key, _variables, "_variables")
    return _variables[key]


func get_internal_switch(event_id, internal_switch_id):
    _assert_key_exist(event_id, internal_switch_id, "_internal_switches")
    return _internal_switches[event_id][internal_switch_id]
    
    
func set_internal_switch(event_id, internal_switch_id, value):
    # printt(">>", event_id)
    _assert_key_exist(event_id, _internal_switches, "_internal_switches")
    _internal_switches[event_id][internal_switch_id]= value
    entries_changed.emit(_internal_switches, _variables, _global_switches, _tag_list)


func add_internal_switch(id):
    if id in _internal_switches: return
    _internal_switches[id]= {
        str(EventPage.InternalSwitch.A): false,
        str(EventPage.InternalSwitch.B): false,
        str(EventPage.InternalSwitch.C): false,
        str(EventPage.InternalSwitch.D): false,
    }
    
    
func add_tag(tag):
    _tag_list.push_back(tag)
    entries_changed.emit(_internal_switches, _variables, _global_switches, _tag_list)


func remove_tag(tag):
    _tag_list.erase(tag)
    entries_changed.emit(_internal_switches, _variables, _global_switches, _tag_list)
    
    
func _assert_key_exist(key, dict, dict_name):
    assert(key in dict, "There is no key of '{0}' in '{1}.'".format([key, dict_name]))
    
    
func _cfg_to_json(cfg):
    var data= {}
    for section in cfg.get_sections():
        for key in cfg.get_section_keys(section):
            data[key]= cfg.get_value(section, key)
    
    return data
