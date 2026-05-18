extends Control

signal dialogue_finished()

@export var max_char_one_line = 39
@export var bg: Control
@export var container: Control
@export var lb_name: Label
@export var lb_msg: Label
@export var next_indicator: Control
@export var tr_portrait: Control

var portrait_data = {}
var _dialogue_base: DialogueBase


func _ready() -> void:
    tr_portrait.hide()
    _split_text_autowrap(_test_msg)
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
    var dialogue_batch = [] as Array[DialogueBase.DialogueNormal]
    for i in arr_batch:
        var split_autowrap = _split_text_autowrap(i.msg, 2)
        for j in split_autowrap:
            dialogue_batch.push_back(
                DialogueBase.DialogueNormal.new(i.speaker, j)
            )
    #print(dialogue_batch)
    _dialogue_base.dialogue_batch = dialogue_batch


var _test_msg = "pada jaman dahulu, ada legenda yang menceritakan tentang suatu kisah yang sangat mengerikan dan juga sangat mencenangkan."
func _split_text_autowrap(text, max_line_visible = 2):
    var space_char_len = 1
    var overflow_hint = "-"
    var prefix_len = overflow_hint.length()
    #print(prefix_len)
    var split_text = text.split(" ")
    var line_count = 0
    var current_line_length = 0
    var result = {}
    
    for i in split_text:
        if current_line_length + i.length() + prefix_len >= max_char_one_line:
            line_count += 1
            current_line_length = 0 
           
        if !(line_count in result):
            result[line_count] = []
            
        result[line_count].push_back(i)
        current_line_length += i.length() + space_char_len
            
    var get_lines = func(arr):
        var r = []
        for i in range(0, max_line_visible):
            var val = arr.pop_front()
            if val == null:
                return {"str" : " ".join(r), "stop" : true}
            r.push_back(" ".join(val))
        
        return {"str" : " ".join(r), "stop" : false}
    
    var result_values = result.values()
    var lines = []
    while true:
        var status = get_lines.call(result_values)
        var str = status["str"]
        if !str.is_empty():
            lines.push_back(status["str"])
            
        if status["stop"]:
            break

    if lines.size() > 1:
        for i in range(0, lines.size()):
            var line = lines[i]
            line += overflow_hint
            lines[i] = line
        var end_text = lines[-1]
        end_text = end_text.substr(0, end_text.length() - prefix_len)
        lines[-1] = end_text
        
    return lines
    
