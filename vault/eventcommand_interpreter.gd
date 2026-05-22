class_name EventCommandInterpreter
extends PiyanScriptingLanguage

var _state = {}

func _get_variable_list():
    var var_ = {}
    var_.test = "anjay"


func _get_code_list():
    var code = {}
    code.text = func(args, remaining_commands):
        if !"dialogue_batch" in _state:
            _state["dialogue_batch"]= [] as Array[DialogueBase.DialogueNormal]
            var d_batch = _state["dialogue_batch"]
            d_batch.push_back(
                DialogueBase.DialogueNormal.new(args[0], args[1])
            )

        var next_command = null
        if !remaining_commands.is_empty():
            next_command = remaining_commands.back()

        if next_command != null || next_command != "text":
            var dialogue = load("uid://dws6emg1mc14n").instantiate()
            dialogue.portrait_data = DialoguePortraitData.new().get_data()
            Bootstrap.canvas.add_child(dialogue)
            dialogue.set_dialogue_batch(_state["dialogue_batch"])
            await dialogue.dialogue_finished
            _state.erase("dialogue_batch")

        
    
    return code
