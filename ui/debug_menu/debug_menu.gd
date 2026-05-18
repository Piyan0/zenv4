extends Control

@export var btn_toggle_visible: Button

@export var controls_container: Control
@export var variable_container: Control
@export var switch_container: Control
@export var tag_container: Control


func _ready() -> void:


    controls_container.hide()
    variable_container.variable_changed.connect(func(id, value):
        printt(id, value)
    )

    switch_container.switch_toggled.connect(func(id, value):
        printt(id, value)    
    )

    tag_container.tag_added.connect(func(tag):
        var eva = EventPageActions.new()
        eva.push(["tag", tag])
        print(tag)    
    )

    tag_container.tag_removed.connect(func(tag):
        var eva = EventPageActions.new()
        eva.push(["rtag", tag])
        print(tag)
    )

    btn_toggle_visible.button_down.connect(func():
        if controls_container.visible:
            controls_container.hide()
        else:
            var progression_data = Bootstrap.progression.get_data()
            switch_container.switch_list = progression_data[Progression.KEY_GLOBAL_SWITCHES]
            variable_container.variable_list = progression_data[Progression.KEY_VARIABLES]
            tag_container.available_tags = _get_available_tags()
            tag_container.current_active_tags = progression_data[Progression.KEY_TAG]
            controls_container.show()
    )


func _get_available_tags():
    var tags = []
    var txt = "res://vault/progression/tags.txt" 
    var file = FileAccess.open(txt, FileAccess.READ)
    while !file.eof_reached():
        var line = file.get_line()
        line = line.strip_edges()
        if !line.is_empty():
            tags.push_back(line)
    
    return tags
