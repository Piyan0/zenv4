@icon("./icon_search.png")
class_name Event
extends Node2D

signal interact_finished()


@export var eventpages: Array[EventPage]
@export var area: Area2D
@export var spr: Sprite2D
@export var colls_shape: CollisionShape2D
@export var animation_process: AnimationProcess
@export var hint_rect: ReferenceRect

var is_interact_running= false
var interact_direction= Vector2.ZERO
var active_event_page: EventPage
var can_interact= true

var _can_trigger_touch= true
var _touch_area= Vector2.ZERO
var _commands : EventCommands


# TODO add initial graphic / idle animation for event in editor.
func _ready():
    if !OS.is_debug_build():
        hint_rect.hide()
        
    spr.hide()
    add_to_group("events")


func _exit_tree() -> void:
    interact_finished.emit()


func _physics_process(delta):
    if !active_event_page: return
    for i in active_event_page.event_traits:
        if is_instance_valid(i):
            i.call_update(delta, self)


func play_animation(anim_name):
    var anim = get_animation(anim_name)
    if anim != null:
        animation_process.change_animation(anim) 


func get_animation(anim_name):
    if !active_event_page: return null
    if active_event_page.walk_animations:
        if anim_name in active_event_page.walk_animations:
            return active_event_page.walk_animations[anim_name]
    if active_event_page.idle_animations:
        if anim_name in active_event_page.idle_animations:
            return active_event_page.idle_animations[anim_name]


func get_animation_process():
    return animation_process


func get_internal_switch_id():
    var current_scene = get_tree().current_scene
    if !current_scene is Map:
        return "<internal_switch_id>"
    return current_scene.map_id + "-" + name
    
    
static func get_by_id(id):
    for i in Engine.get_main_loop().get_nodes_in_group("events"):
        if i.name == id:
            return i


static func get_keys():
    var keys = []
    for i in Engine.get_main_loop().get_nodes_in_group("events"):
        keys.push_back(str(i.name))    
    return keys


func get_size():
    return colls_shape.shape.size


func set_texture(texture):
    spr.texture= texture
    
    
func reset_texture():
    assert(active_event_page != null, str(active_event_page))
    spr.texture= active_event_page.graphic
    spr.offset= active_event_page.offset


func get_area():
    return area
    

func get_collision_space():
    return active_event_page.placement
    
    
func is_interact(player: Player, input_event: InputEvent= null):
    if active_event_page == null:
        return false
        
    match active_event_page.placement:
        EventPage.Placement.GROUND:
            return _is_interact_ground(player, input_event)
        EventPage.Placement.BELOW_GROUND, EventPage.Placement.ABOVE_GROUND:
            return _is_interact_below_or_above_ground(player, input_event)
            

func interact(player):
    assert(active_event_page != null, "active event page is null.")
    if !can_interact:
        return
    var direction_from_player= player.position - position
    direction_from_player= direction_from_player.normalized()
    
    interact_direction= direction_from_player
    is_interact_running= true
    var command = FileAccess.open(active_event_page.event_command, FileAccess.READ)
    command = command.get_as_text()
    await Bootstrap.event_manager.process_command(command, active_event_page.get_arguments())
    interact_finished.emit.call_deferred()
    is_interact_running= false
    

func update_active_event(internal_switches, variables, global_switches, tag_list):

    var reversed_event_pages= eventpages.duplicate()
    reversed_event_pages.reverse()
    for i in reversed_event_pages:
        if i == null: continue
        # TODO return if event is the same, since everytime variable / switch is changed, it will be called.
        if i.is_event_active(internal_switches[get_internal_switch_id()], variables, global_switches, tag_list):
            if i == active_event_page:
                return
            if active_event_page:
                for j in active_event_page.event_traits:
                    j.exit(self)

            active_event_page= i
            _active_event_changed(i)

            for j in active_event_page.event_traits:
                j.enter(self)
            return
    
    
func _update_trigger_touch(player):
    if player.position != _touch_area:
        _can_trigger_touch= true
        

func _active_event_changed(event_page: EventPage):
    area.collision_layer = 0
    spr.show()
    spr.texture= event_page.graphic
    spr.offset= event_page.graphic_offset
    _play_initial_idle_animation(event_page)
    match event_page.placement:
        EventPage.Placement.BELOW_GROUND:
            area.set_collision_layer_value(1, true)
            z_index= 0
        EventPage.Placement.GROUND:
            area.set_collision_layer_value(2, true)
            z_index= 10
        EventPage.Placement.ABOVE_GROUND:
            area.set_collision_layer_value(3, true)
            z_index= 20
    if event_page.through:
            area.collision_layer = 0
        


func _is_interact_ground(player, input_event):
    match active_event_page.trigger:
        EventPage.Trigger.PLAYER_TOUCH:
            if !player.is_moving():
                if !_can_trigger_touch:
                    _update_trigger_touch(player)
                    return false
                
                if player.get_latest_collider() == area:
                    _can_trigger_touch= false
                    _touch_area= player.position
                    return true
            
        EventPage.Trigger.INTERACT_BUTTON:
            if !input_event: return
            if !player.is_moving():
                if input_event.is_action_pressed("ui_accept"):
                    if player.get_latest_collider() == area:
                        return true
                    
        EventPage.Trigger.AUTORUN:
            return true
    
    return false


func _is_interact_below_or_above_ground(player, input_event):
    match active_event_page.trigger:
        EventPage.Trigger.PLAYER_TOUCH:
            if !player.is_moving():
                if !_can_trigger_touch:
                    _update_trigger_touch(player)
                    return false
                
                var touch_threshold= 1.0
                var distance_from_player= abs( position.distance_to(player.position) )
                if distance_from_player <=  touch_threshold:
                    _can_trigger_touch= false
                    _touch_area= player.position
                    return true
            
        EventPage.Trigger.INTERACT_BUTTON:
            if !input_event: return
            if !player.is_moving():
                var interact_threshold= 1.0
                var distance_from_player= abs( position.distance_to(player.position) )
                if input_event.is_action_pressed("ui_accept") && distance_from_player <= interact_threshold:
                    return true
        
        EventPage.Trigger.AUTORUN:
            return true
    
    return false


func _play_initial_idle_animation(evpage: EventPage):
    var dir = evpage.direction
    var anim_id = ""
    if evpage.idle_animations:
        var anims = evpage.idle_animations
        match dir:
            EventPage.Direction.UP:
                anim_id = "idle_up"
            EventPage.Direction.DOWN:
                anim_id = "idle_down"
            EventPage.Direction.LEFT:
                anim_id = "idle_left"
            EventPage.Direction.RIGHT:
                anim_id = "idle_right"
    
        if !anim_id.is_empty():
            play_animation(anim_id)
    
