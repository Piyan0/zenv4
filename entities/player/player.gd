class_name Player
extends Node2D

enum Direction{ UP, DOWN, LEFT, RIGHT }
static var instance: Player
static var god_mode = false

@export var area: Area2D
@export var player_animations: Array[PlayerAnimationCollection]
@export var initial_direction: Direction
@export var animation_process: AnimationProcess
@export var grid_mov: InputGridMovement
@export var ray: RayCast2D
@export var camera: Camera2D

var last_direction
var active_animation: PlayerAnimationCollection

var lock_counter = 0:
    set(value):
        # print(value)
        lock_counter = value
        # print("Player:lock_counter ",value)
        if lock_counter > 0:
            grid_mov.lock_input = true
        else:
            grid_mov.lock_input = false


func _ready():
    last_direction = initial_direction
    var progression_data= Bootstrap.progression.get_data()
    update_active_animation(progression_data[Progression.KEY_GLOBAL_SWITCHES])
    
    ray.target_position = Vector2.ZERO
    instance= self
    match initial_direction:
        Direction.UP:
            play_animation("idle_up")
        Direction.DOWN:
            play_animation("idle_down")
        Direction.LEFT:
            play_animation("idle_left")
        Direction.RIGHT:
            play_animation("idle_right")
        
    grid_mov.can_move= func(dir):
        if god_mode:
            return true
        var angles= [-20, 0, 20]
        for i in angles:
            ray.rotation_degrees= i
            ray.target_position= dir * 16
            ray.force_raycast_update()
            if ray.is_colliding():
                return false
            
        return true

    grid_mov.on_direction_changed= func(dir, prev):
        match dir:
            Vector2.ZERO:
                match prev:
                    Vector2.UP:
                        play_animation("idle_up")
                    Vector2.DOWN:
                        play_animation("idle_down")
                    Vector2.LEFT:
                        play_animation("idle_left")
                    Vector2.RIGHT:
                        play_animation("idle_right")
            Vector2.UP:
                last_direction = Direction.UP
                play_animation("walk_up")
            Vector2.DOWN:
                last_direction = Direction.DOWN
                play_animation("walk_down")
            Vector2.LEFT:
                last_direction = Direction.LEFT
                play_animation("walk_left")
            Vector2.RIGHT:
                last_direction = Direction.RIGHT
                play_animation("walk_right")
  

func update_active_animation(global_switches):
    var anims_reversed = player_animations.duplicate()
    anims_reversed.reverse()
    for i in anims_reversed:
        if i.is_active(global_switches):
            if i == active_animation:
                return
            active_animation = i
            # print(active_animation)
            _active_animation_changed(i)
            return
    
    
func play_animation(anim_name):
    var anim = get_animation(anim_name)
    if anim != null:
        animation_process.change_animation(anim)
    
 
func get_animation(anim_name):
    if !active_animation: return
    if active_animation.walk_animations:
        if anim_name in active_animation.walk_animations:
            return active_animation.walk_animations[anim_name]
    if active_animation.idle_animations:
        if anim_name in active_animation.idle_animations:
            return active_animation.idle_animations[anim_name]

    
    
func get_animation_process():
    return animation_process


func get_latest_collider():
    ray.force_raycast_update()
    return ray.get_collider()


func is_moving():
    return grid_mov.is_moving()


func get_camera():
    return camera


func _active_animation_changed(player_anim: PlayerAnimationCollection):
    match last_direction:
        Direction.UP:
            play_animation("idle_up")
        Direction.DOWN:
            play_animation("idle_down")
        Direction.LEFT:
            play_animation("idle_left")
        Direction.RIGHT:
            play_animation("idle_right")
