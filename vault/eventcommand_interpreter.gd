class_name EventCommandInterpreter
extends PiyanScriptingLanguage

var _state = {}

func _get_variable_list():
    var var_ = {}
    var_.test = "anjay"


func _get_code_list():
    var code = {}
    code.text = _text
    
    return code


func _text(args, remaining_commands):
        if !"dialogue_batch" in _state:
            _state["dialogue_batch"]= [] as Array[DialogueBase.DialogueNormal]
        
        var d_batch = _state["dialogue_batch"]
        d_batch.append(
            DialogueBase.DialogueNormal.new(args[0], args[1])
        )
        
        var next_command = null
        if !remaining_commands.is_empty():
            next_command = remaining_commands.front()
        
        if next_command == null || next_command != "text":
            var dialogue_vp = load("uid://ctal5xoq67h54").instantiate()
            Bootstrap.canvas.add_child(dialogue_vp)
            dialogue_vp.dialogue.set_dialogue_batch(_state["dialogue_batch"])
            await dialogue_vp.dialogue.dialogue_finished
            dialogue_vp.queue_free()
            _state.erase("dialogue_batch")
