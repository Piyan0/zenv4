class_name MapManager
extends Node

signal map_ready()

enum Direction{ UP, DOWN, LEFT, RIGHT }

var player_scene_path
var prev_transfer_data
func _init(p_owner, p_player_scene_path):
    player_scene_path= p_player_scene_path
    p_owner.add_child(self)
    name= "MapManager"
    

# TODO refactor this.
func goto(transfer_data: PlayerTransferData, start_from_black = false):
    prev_transfer_data = transfer_data
    var fade= await TransitionBlack.spawn(start_from_black, Color.BLACK, 0.3)
    var scene= load(transfer_data.map_scene_path)

    if transfer_data.spawn_pos == Vector2.ZERO:
        var ins = scene.instantiate() as Map
        transfer_data.spawn_pos = ins.default_spawn_pos
        ins.free()
        
    await get_tree().process_frame
    get_tree().change_scene_to_packed(scene)
    await get_tree().process_frame
    var current_scene = get_tree().current_scene as Map
    current_scene.map_ready.connect(map_ready.emit, CONNECT_ONE_SHOT)
    
    var player= _instantiate_player(transfer_data.direction, transfer_data.spawn_pos)
    get_tree().current_scene.add_child.call_deferred(player)
    await player.ready
    fade.confirm()
    

func _instantiate_player(direction: int, pos):
    var player= load(player_scene_path).instantiate()
    player.initial_direction= direction
    player.position= pos
    return player
    
    
func _parse_direction(dir_id: int):
    match dir_id:
        Direction.UP:
            return Vector2.UP
        Direction.DOWN:
            return Vector2.DOWN
        Direction.LEFT:
            return Vector2.LEFT
        Direction.RIGHT:
            return Vector2.RIGHT

    
class PlayerTransferData:
    var spawn_pos: Vector2
    var direction: Direction
    var map_scene_path: String
    
    
