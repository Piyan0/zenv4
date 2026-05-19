@tool
class_name Map
extends Node2D

signal map_ready()

@export var bgm_id: String
@export var map_display_name: String
@export var spawn_pos: Vector2 = Vector2.ZERO
@export var player_direction: Player.Direction
@export_tool_button("Copy Map ID") var _copy_map_id = _copy_map_id_action
@export_tool_button("Set as starting scene") var _set_as_starting_map = _set_as_starting_map_action

func _copy_map_id_action():
    DisplayServer.clipboard_set(map_id)
    print(map_id)

func _set_as_starting_map_action():
    SceneMap.set_starting_scene(scene_file_path)
    print("Set {scene_file_path} as starting scene.".format(self))

var map_id: String:
    get():
        return get_map_id()


func _ready():
    if Engine.is_editor_hint():
        return

    if !bgm_id.is_empty():
        var eva = EventPageActions.new()
        eva.push(["play_bgm", bgm_id])

    y_sort_enabled = true
    _add_event_id()

    var player = _instantiate_player(player_direction, spawn_pos)
    add_child(player)
    Bootstrap.map_manager.map_ready.emit()
    

func _add_event_id():
    if OS.is_debug_build():
        var label = Label.new()
        label.text = "map_id = {map_id}".format(self)
        label.label_settings = load("uid://3wboop2jrvep")
        label.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_BOTTOM_RIGHT)
        #Bootstrap.canvas.add_child.call_deferred(label)
        tree_exited.connect(func():
            label.queue_free()
        )
        

func get_map_id():
    var asset_dict = {}
    if Engine.is_editor_hint():
        asset_dict = AssetLoader.new().get_asset_data()
    else:
        asset_dict = Bootstrap.asset_loader.get_asset_data()
    for i in asset_dict.keys():
        # printt(scene_file_path, asset_dict[i])
        if asset_dict[i] == scene_file_path:
            return i
    
    return "<map id not found.>"



func _instantiate_player(direction: int, pos):
    var player= load("res://entities/player/player.tscn").instantiate()
    player.initial_direction= direction
    player.position= pos
    return player
    
