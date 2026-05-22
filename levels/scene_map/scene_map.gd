class_name SceneMap
extends Node

@export var vp: SubViewport
const source_path = "res://levels/scene_map/source.cfg"

func _ready():
    var map = load(_get_map_path()).instantiate()
    vp.add_child(map)

static func set_starting_scene(scene_id):
    var cfg = ConfigFile.new()
    cfg.load(source_path)
    cfg.set_value("Data", "starting_map", scene_id)
    cfg.save(source_path)

    
func _get_map_path():
    var cfg = ConfigFile.new()
    cfg.load(source_path)
    return cfg.get_value("Data", "starting_map")
