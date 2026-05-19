extends Node

var event_manager
var asset_loader
var progression: Progression
var map_manager
var canvas
var world_canvas
var items_database: ItemsDatabase
var save_system
var audio_manager: AudioManager

func _enter_tree():
    canvas= _add_canvas()
    world_canvas = _add_world_canvas()
    _create_mobile_control()
    asset_loader = AssetLoader.new()
    event_manager= _create_event_manager()
    audio_manager = _create_audio_manager()

    progression= _boot_progression()

  
    map_manager= _boot_map_manager()
    save_system = _create_save_system()
    items_database= ItemsDatabase.new()
    
    if OS.is_debug_build():
        _create_dev_console()
    else:
        RenderingServer.set_default_clear_color(Color.BLACK)


func _create_audio_manager():
    var am = AudioManager.new()
    add_child(am)
    return am
    
func _create_save_system():
    var sv = SaveSystem.new("res://user/save")
    sv.fields = {
        "items_id" : [],
        "player_map_id" : "",
    }
    
    sv.on_data_loaded.connect(
        func(save_data):
            progression.set_data(save_data["progression"])
    )
    sv.get_save_data = func():
        return {
            "progression" : progression.get_data(),
        }
        
    return sv
    

func _boot_map_manager():
    var scene_man= MapManager.new(self, "res://entities/player/player.tscn")
    scene_man.map_ready.connect(func():
        var events = get_tree().get_nodes_in_group("events")
        for i in events:
            progression.add_internal_switch(i.get_internal_switch_id())
        
        var progression_data= progression.get_data()
        event_manager.refresh_map(
            progression_data[Progression.KEY_INTERNAL_SWITCHES],
            progression_data[Progression.KEY_VARIABLES],
            progression_data[Progression.KEY_GLOBAL_SWITCHES],
            progression_data[Progression.KEY_TAG],
        )
    )
    
    return scene_man


func _boot_progression():
    var progression= Progression.new("res://vault/progression/variables.cfg", "res://vault/progression/global_switches.cfg")

    progression.entries_changed.connect(
    func(it_switch, vars, gb_switch, tag_list):
        event_manager.refresh_map(it_switch, vars, gb_switch, tag_list)
        if Player.instance:
            Player.instance.update_active_animation(gb_switch)   
    )
    
    return progression


var _valid_player: Player
func _create_dev_console():
    return
    var commands = [
        DevCommand.new(),
        GameConsoleCommand.new(),
        PlayerConsoleCommand.new(),
    ]
    var console = DevConsole.create(commands)
    if console:
        console.console_active.connect(func():
            if Player.instance:
                _valid_player = Player.instance
                Player.instance.lock_counter += 1
        )
        console.console_blur.connect(func():
            if Player.instance != _valid_player:
                return
            if Player.instance:
                Player.instance.lock_counter -= 1
        )
        canvas.add_child(console)


func _create_event_manager():
    var evm = EventManager.new(self)
    evm.can_process_interact = func():
        if Player.instance:
            return Player.instance.lock_counter == 0
        return true
    
    return evm
    
    
func _create_mobile_control():
    # if OS.get_name() == "Windows" && OS.is_debug_build():
    #     return
        
    var mobile_control = MobileControl.spawn()
    if mobile_control != null:
        canvas.add_child(mobile_control)


func _add_canvas():
    # other canvas layer should below this, as global_canvas is considered as high priority draw order.
    var cv= CanvasLayer.new()
    cv.layer= 10
    cv.name= "GlobalCanvas"
    add_child(cv)
    
    return cv


func _add_world_canvas():
    var cv= Node2D.new()
    # other canvas layer should below this, as global_canvas is considered as high priority draw order.
    cv.z_index= 30
    cv.name= "WorldGlobalCanvas"
    add_child(cv)
    return cv
