extends MarginContainer

signal tag_added(tag)
signal tag_removed(tag)

@export var op_tag: OptionButton
var available_tags = ["tag_1", "tag_2"]:
    set(v):
        available_tags = v
        op_tag.clear()
        for tag in available_tags:
            op_tag.add_item(tag)
        


@export var tag_container: Control
@export var ph_tag: Node

var current_active_tags = []:
    set(v):
        current_active_tags = v
        # _sync_tags(v)

var _added_tags = []


func _ready():
    op_tag.item_selected.connect(func(id):
        print("called")
        var tag = op_tag.get_item_text(id)
        if tag in current_active_tags:
            return
        current_active_tags.append(tag)
        print(">>", tag, current_active_tags)
        _sync_tags(current_active_tags)
        tag_added.emit(tag)
    )
    

func _sync_tags(p_tags):
    for tag_node in _added_tags:
        tag_node.queue_free()
    _added_tags.clear()
    
    for tag in p_tags:
        var ins = (ph_tag as InstancePlaceholder).create_instance()
        ins.id = tag
        ins.tag_clicked.connect(func(id):
            current_active_tags.erase(id)
            _sync_tags(current_active_tags)
            tag_removed.emit(id)
        )
        _added_tags.append(ins)
    
