class_name EventPageActions

enum Direction{
    UP, DOWN, LEFT, RIGHT
}

var _actions = {}
static var _state = {}

func _init() -> void:
    _actions["narator"] = func(msg_arr):
        var narator_dialogue = [] as Array[DialogueBase.DialogueNormal]
        for i in msg_arr:
            narator_dialogue.push_back(
                NaratorView.NaratorDialogue.new(i)
            )
        var narator_view = load("uid://cqtqvc51an3sh").instantiate()
        narator_view.narator_dialogue = narator_dialogue
        Bootstrap.canvas.add_child(narator_view)
        await narator_view.finished
    
    # TODO simplify dialogue invoke.
    _actions["push_dialogue"] = _queue_dialogue_batch

    _actions["push_dialogue2"] = _queue_dialogue_batch2

    _actions["start_dialogue"] = _start_dialogue

    _actions["choices"] = func(p_choices = [], on_end = func(choice_index): pass):
        var choices = [] as Array[String]
        choices.assign(p_choices)
        var result = await Choice.spawn(Player.instance.position + Vector2(8, -28), choices)
        await on_end.call(result)
    
    _actions["open_inventory"] = func(on_end = func(item_id): pass):
        var items = Bootstrap.save_system.fields["items_id"].duplicate()
        var inven = load("uid://c1148pqf8xuv8").instantiate()
        inven.filter_item = func(item):
            return item.is_key_item
            
        inven.close_on_selected = true
        inven.items_id = items
        Bootstrap.canvas.add_child(inven)
        var items_used = await inven.inventory_closed
        if items_used.is_empty():
            await on_end.call(-1)
            return
        await on_end.call(items_used[0])
    
    _actions["erase_item"] = func(id = -1):
        if id == -1:
            id = Inventory.last_used_item
        print(id)
        Bootstrap.save_system.fields["items_id"].erase(id)
    
    _actions["add_item"] = func(id):
        Bootstrap.save_system.fields["items_id"].push_back(id)
    
    _actions["set_iswitch"] = func(internal_switch_str, value = true):
        var id = EventManager.current_internal_switch_id
        var internal_switch = EventPage.InternalSwitch[internal_switch_str.to_upper()]
        Bootstrap.progression.set_internal_switch(id, str(internal_switch), value)
        
    _actions["get_iswitch"] = func(event_name, internal_switch):
        pass
        
    _actions["set_switch"] = func(id, value = true):
        Bootstrap.progression.set_switch(id, value)
        
    _actions["get_switch"] = func(id, cb):
        var value = Bootstrap.progression.get_switch(id)
        await cb.call(value)
    
    _actions["set_var"] = func(id, value):
        Bootstrap.progression.set_var(id, value)
    
    _actions["get_var"] = func(id, cb):
        var value = Bootstrap.progression.get_var(id)
        await cb.call(value)

    _actions["increment_var"] = func(id):
        var current_value = Bootstrap.progression.get_var(id)
        if current_value is int:
            Bootstrap.progression.set_var(id, current_value + 1)
        

    _actions["show_image"] = func(img_id = "img_screen"):
        await DisplayImage.spawn(img_id)
    
    _actions["has_item"] = func(item_id):
        pass
    
    #TODO this change the current scene, so all control flow such as set_switch and set_var, set_internal_switch will be error. Call this at the end of the commands. 
    _actions["goto"] = func(map_id, x = 0, y = 0, dir_str = "down", start_from_black = false):
        var dir
        match dir_str:
            "up":
                dir = MapManager.Direction.UP
            "down":
                dir = MapManager.Direction.DOWN
            "left":
                dir = MapManager.Direction.LEFT
            "right":
                dir = MapManager.Direction.RIGHT
                
        var tf_data = MapManager.PlayerTransferData.new()
        tf_data.map_id = map_id
        tf_data.spawn_pos = Vector2(x,y)
        tf_data.direction = dir
        await Bootstrap.map_manager.goto(tf_data, start_from_black)
        
    _actions["spawn_animation_player"] = func(animation_id):
        pass
        
    _actions["spawn_animation_world"] = func(animation_id, pos):
        pass

    _actions["transfer"] = func(target: String, x , y):
        var instance = Event.get_by_id(target)
        if target == "player":
            instance = Player.instance
       
        if instance:
            var mk_transfer = "transfer"
            if instance.has_meta(mk_transfer):
                instance.get_meta(mk_transfer).call(Vector2(x,y))
    
    
    _actions["look"] = func(target: String, dir_str = "up"):
        var instance = Event.get_by_id(target)
        if target == "player":
            instance = Player.instance
       
        if instance:
            var nk_look = "look"
            if instance.has_meta(nk_look):
                instance.get_meta(nk_look).call(dir_str)
    
    
    _actions["alpha"] = func(target: String, is_transparent = true):
        var instance = Event.get_by_id(target)
        if target == "player":
            instance = Player.instance
       
        if instance:
            var meta_key = "alpha"
            if instance.has_meta(meta_key):
                instance.get_meta(meta_key).call(is_transparent)
    

    _actions["move"] = func(target: String, arr_dir: Array, speed = 30, on_arrived = func(): pass):
        var instance = Event.get_by_id(target)
        if target == "player":
            instance = Player.instance
        
        var parse_dir = func():
            var r = []
            for i in arr_dir:
                match i:
                    "up":
                        r.push_back(Vector2.UP)
                    "down":
                        r.push_back(Vector2.DOWN)
                    "left":
                        r.push_back(Vector2.LEFT)
                    "right":
                        r.push_back(Vector2.RIGHT)
            return r

        if instance:
            var mk_set_routes = "set_routes"
            if instance.has_meta(mk_set_routes):
                await instance.get_meta(mk_set_routes).call(parse_dir.call(), speed)
                await on_arrived.call()
    
    _actions["fade_in"] = func(free_at_end = false):
        var fade = await TransitionBlack.spawn()
        if free_at_end:
            await Engine.get_main_loop().process_frame
            await Engine.get_main_loop().process_frame
            await Engine.get_main_loop().process_frame
            fade.queue_free.call_deferred()
        else:
            _state["fade"] = fade
    
    _actions["fade_out"] = func(wait = false):
        if "fade" in _state:
            if wait:
                await _state["fade"].confirm()
            else:
                _state["fade"].confirm()
            _state.erase("fade")
        else:
            var fade = await TransitionBlack.spawn(true)
            await fade.confirm()


    _actions["black"] = func(duration):
        var cr = ColorRect.new()
        cr.color = Color.BLACK
        Bootstrap.canvas.add_child(cr)
        cr.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_FULL_RECT)
        await Bootstrap.get_tree().create_timer(duration).timeout
        cr.queue_free()
        

    
    _actions["wait"] = func(second):
        await Engine.get_main_loop().create_timer(second).timeout
    
    _actions["play_bgm"] = func(bgm_id, custom_db = 0):
        if "playing_bgm_id" in _state:
            if bgm_id == _state["playing_bgm_id"]:
                return
                
        _state["playing_bgm_id"] = bgm_id
        var stream = Bootstrap.asset_loader.get_asset(bgm_id)
        assert(stream is AudioStream, str(stream))
        Bootstrap.audio_manager.play_bgm(stream, custom_db)
        
    _actions["play_sfx"] = func(bgm_id):
        var stream = Bootstrap.asset_loader.get_asset(bgm_id)
        assert(stream is AudioStream, str(stream))
        Bootstrap.audio_manager.play_sfx(stream)
    
    _actions["tag"] = func(tag):
        Bootstrap.progression.add_tag(tag)
    
    _actions["rtag"] = func(tag):
        Bootstrap.progression.remove_tag(tag)
    
    _actions.text = func(str_arg):
    
        var arr = Array(str_arg.split(" > "))
        var speaker = arr.pop_front()
        if !"dialogue" in _state:
            _state.dialogue = [] as Array[DialogueBase.DialogueNormal]
            
        for msg in arr:
            _state.dialogue.push_back(
                DialogueBase.DialogueNormal.new(speaker, msg)
            )

            
    _actions.textt = func(arg):
       
        var dialogue = load("uid://dws6emg1mc14n").instantiate()
        #dialogue.portrait_data = DialoguePortraitData.new().get_data()
        Bootstrap.canvas.add_child(dialogue)
        dialogue.set_dialogue_batch(_state.dialogue)
        await dialogue.dialogue_finished
        _state.erase("dialogue")
     

func push_batch(commands: Array):
    for i in commands:
        var arr = Array(i.split(" "))
        var args = i
        var id = arr.pop_front()
        assert(id in _actions, str(id))
        var arg = " ".join(arr)
        printt(id, arg)
        await _actions[id].callv([arg])
    
# first element (at index 0 should be the key of '_actions', rest is call arguments.)
func push(args = []):
    var id = args.pop_front()
    if id.is_empty():
        return
    # print("start push {id}".format({"id":id}), ">>",EventManager.current_internal_switch_id)
    var result = await _actions[id].callv(args) 
    # print("finished push {id}".format({"id":id}), ">>",EventManager.current_internal_switch_id)
    return self


func _queue_dialogue_batch(name = "Godot", msg = "<message here>"):
    if !"dialogue_batch" in _state:
        _state["dialogue_batch"]= [] as Array[DialogueBase.DialogueNormal]
    var d_batch = _state["dialogue_batch"]
    d_batch.push_back(
        DialogueBase.DialogueNormal.new(name, tr(msg))
    )

func _queue_dialogue_batch2(name = "Godot", msg_list = ["interact_empty"]):
    if !"dialogue_batch" in _state:
        _state["dialogue_batch"]= [] as Array[DialogueBase.DialogueNormal]
    var d_batch = _state["dialogue_batch"]
    for i in msg_list:
        d_batch.push_back(
            DialogueBase.DialogueNormal.new(name, tr(i))
        )
    await push(["start_dialogue"])


func _start_dialogue():
    #print(_state["dialogue_batch"])
    var dialogue = load("uid://dws6emg1mc14n").instantiate()
    dialogue.portrait_data = DialoguePortraitData.new().get_data()
    Bootstrap.canvas.add_child(dialogue)
    dialogue.set_dialogue_batch(_state["dialogue_batch"])
    await dialogue.dialogue_finished
    _state.erase("dialogue_batch")
