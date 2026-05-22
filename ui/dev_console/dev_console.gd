class_name DevConsole
extends Control

signal console_active()
signal console_blur()


@export var line_edit: LineEdit
@export var lb_msg: Label
@export var btn_console: Button
@export var btn_console_container: Control
@export var console_container: Control
@export var autocomplete_container: Control
@export var lb_command_info: Label


var commands = [ConsoleCommand.new()]
var _is_console_visible = false
var _can_toggle_console = true
var _history = []
var _history_save_path = "res://ui/dev_console/command_history.cfg"


func _ready():
    _load_history()

    _console_visible(false)
    lb_msg.hide()
    lb_command_info.hide()
    lb_msg.text = ""
    lb_command_info.text = ""
    autocomplete_container.hide()
    autocomplete_container.selected.connect(
        func(text):
            var text_replacement = _remove_word_at_caret(line_edit.text, line_edit.caret_column, text)
            var new_text = text_replacement[0]
            var replaced_text = text_replacement[1]
            var prev_caret_index = line_edit.caret_column
            line_edit.text =  new_text
            if OS.get_name() == "Android":
                line_edit.release_focus()
                while  DisplayServer.virtual_keyboard_get_height() > 0:
                    await get_tree().process_frame
            
            line_edit.caret_column = prev_caret_index + text.length() - replaced_text.length()
            line_edit.grab_focus()
    )
    
    btn_console.pressed.connect(_toggle_console)

    line_edit.text_submitted.connect(
        func(text):
            if text.is_empty(): return
            if text != _history.front():
                _history.push_front(text)
                _history_index += 1
            if _history.size() >= 24:
                _history.resize(24)
            _save_history()

            for i in commands:
                var command_id = i.is_valid(text)
                if command_id != null:
                    var result = i.call_action(text, command_id)
                    if result ==  ConsoleCommand.CallResult.INVALID_ARGS:
                        _show_msg("Err. Invalid arguments")
                    else:
                        _show_msg("OK")
                    return

            _show_msg("Err. Command not exist")
    )
    
    line_edit.text_changed.connect(
        func(text):
            _update_command_info(text, commands)
            for i in commands:
                var text_before_carret = _get_text_before_caret()
                var currently_typed_text = text_before_carret.split(" ")[-1] # equivalent with Array.back()
                var autocomplete = i.get_autocomplete(text_before_carret, currently_typed_text)
                if autocomplete != null:
                    _update_autocomplete(autocomplete)
                    return
                else:
                    autocomplete_container.off()
    )


func _process(delta: float) -> void:
    if Input.is_key_pressed(KEY_CTRL) && Input.is_key_pressed(KEY_QUOTELEFT):
        if _can_toggle_console:
            _can_toggle_console = false
            _toggle_console()
    else:
        _can_toggle_console = true


var _history_index = -1
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_up"):
        _history_index= ( _history_index + 1 ) % _history.size()
        var last_used_command = _history[_history_index]
        if last_used_command:
            line_edit.text = last_used_command
            await get_tree().process_frame
            line_edit.caret_column = last_used_command.length()

    if event.is_action_pressed("ui_down"):
        _history_index= ( _history_index - 1 ) % _history.size()
        var last_used_command = _history[_history_index]
        if last_used_command:
            line_edit.text = last_used_command
            await get_tree().process_frame
            line_edit.caret_column = last_used_command.length()


func _toggle_console():
    _history_index = -1
    line_edit.text = ""
    _is_console_visible = !_is_console_visible
    if !_is_console_visible:
        autocomplete_container.off()
    _console_visible(_is_console_visible)
    await get_tree().create_timer(0.2).timeout
    btn_console.release_focus()


func _update_autocomplete(text_list):
    autocomplete_container.set_autocomplete(text_list)
    var char_width = 6
    var offset_right = 14
    var y = 16
    autocomplete_container.position = clamp(
        Vector2(offset_right + ( line_edit.text.length() * char_width ), y),
        Vector2(0, y),
        Vector2(320 - autocomplete_container.size.x, y)
    )
    
    
func _get_text_before_caret():
    var text = line_edit.text.left(line_edit.caret_column)
    return text
    

static func create(p_commands: Array):
    var instance = load("uid://cplt2xqjilwh4").instantiate()
    instance.commands = p_commands
    return instance


func _show_msg(text):
    lb_msg.show()
    lb_msg.text = "(>)"+"{0}".format([text])
    for i in ["err", "error"]:
        if i in text.to_lower():
            lb_msg.modulate= Color.RED
            break
        else:
            lb_msg.modulate= Color.GREEN
    
    await get_tree().create_timer(1).timeout
    lb_msg.modulate= Color.WHITE


func _console_visible(is_visible):
    if is_visible:
        console_active.emit()
        line_edit.grab_focus()
        var animate = AnimateOffset.new(console_container, Vector2.ZERO, 0.2, false)
    else:
        lb_command_info.hide()
        lb_msg.hide()
        console_blur.emit()
        line_edit.release_focus()
        var animate = AnimateOffset.new(console_container, Vector2(0, -console_container.size.y), 0.2, false)
        

func _remove_word_at_caret(text, caret_index, replace_with = ""):
    var caret_pos = 0
    var current_word= ""
    var words_caret_index = {}
    for i in text:
        current_word += i
        if i == " ":
            words_caret_index[current_word] = caret_pos
            current_word = ""

        caret_pos += 1

    if !current_word.is_empty():
        words_caret_index[current_word] = caret_pos
        current_word = []
    
    var caret_region = 0
    for i in words_caret_index.keys():
        if caret_index > words_caret_index[i]:
            caret_region += 1
        else:
            break
    
    var split_text = text.split(" ")
    var replaced_text = split_text[caret_region]
    split_text[caret_region] = replace_with
    return [" ".join(split_text),  replaced_text]


func _update_command_info(text, p_commands):
    lb_command_info.show()
    for i in p_commands:
        var command = i.is_valid(text)
        if command != null:
            lb_command_info.show()
            lb_command_info.text = "(?)"+i.sub_commands[command].get(ConsoleCommand.dk_DOCS, "")
            return
        else:
            lb_command_info.hide()


func _load_history():
    var cfg = ConfigFile.new()
    cfg.load(_history_save_path)
    _history = cfg.get_value("Main", "history")


func _save_history():
    var cfg = ConfigFile.new()
    cfg.load(_history_save_path)
    cfg.set_value("Main", "history", _history)
    cfg.save(_history_save_path)
