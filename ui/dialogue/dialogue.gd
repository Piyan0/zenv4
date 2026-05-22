extends Control

signal dialogue_finished()

@export var container: Control
@export var lb_name: Label
@export var lb_msg: Label
@export var next_indicator: Control
@export var tr_portrait: Control

var portrait_data = {}
var _dialogue_base: DialogueBase


func _ready() -> void:
    tr_portrait.hide()
    lb_msg.text = ""
    lb_name.text = ""
    next_indicator.hide()
    # var x= await AnimateOpenCenter.spawn(bg, 0.4, func(): container.hide(), func(): container.show())
    _dialogue_base= DialogueBase.new() 
    _dialogue_base.on_progress= func(d, v, just_changed):
        if just_changed:
            if d.speaker in portrait_data:
                var portrait = portrait_data[d.speaker]
                d.speaker = portrait["name"]
                tr_portrait.show()
                tr_portrait.texture = Bootstrap.asset_loader.get_asset(portrait["img_id"])
            else:
                tr_portrait.hide()
                
        next_indicator.hide()
        lb_name.text= d.speaker
        lb_msg.text= d.msg
        lb_msg.visible_characters= v
    _dialogue_base.line_finished.connect(func():
        next_indicator.show()
    )
    _dialogue_base.batch_finished.connect(func():
        dialogue_finished.emit()
        queue_free()    
    )


func _input(event: InputEvent):
    _dialogue_base.input(event)


func set_dialogue_batch(arr_batch):
    _dialogue_base.dialogue_batch = arr_batch
