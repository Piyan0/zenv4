@tool
extends EditorPlugin

var _template_path = "res://script_templates/EventCommands/event_commands_template.gd"
var _generate_path = "res://vault/generated_event_command/"
var _button: Button

func _enter_tree() -> void:
    _button = Button.new()
    _button.text = "Generate event command"
    _button.pressed.connect(func():
        var selection = get_editor_interface().get_selection().get_selected_nodes() 
        if selection.is_empty():
            return

        if selection[0] is Event:
            _erase_orphan_files()
            var event: Event = selection[0]
            if event._commands_source != null:
                print("{0} command source is not empty. aborting.".format([event.name]))
                return
            
            var text_source = FileAccess.open(_template_path, FileAccess.READ)
            var content = text_source.get_as_text()
            text_source.close()

            var file_count = DirAccess.get_files_at(_generate_path).size()
            var name = str(file_count) + "_" + event.name + ".gd"
            var file = FileAccess.open(_generate_path + name, FileAccess.WRITE) 
            file.store_string(content)
            file.close()
            event._commands_source = load(_generate_path + name)
            get_editor_interface().get_resource_filesystem().scan()
            print("generated " + name)
            
        )

    _button.name = "EventCommand"
    _button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

    add_control_to_dock(DOCK_SLOT_LEFT_UR, _button)


func _exit_tree() -> void:
    remove_control_from_docks(_button)
    _button.queue_free()


# TODO
func _erase_orphan_files():
    pass
