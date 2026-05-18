class_name EventCommands

var _commands= {}
var action
var event
var internal_switch

func _init():
    action = EventPageActions.new()
    _commands = _get_commands_list()


func push(args = []):
    return await action.push(args)


func pb(commands: Array):
    await action.push_batch(commands)
    

func get_event_commands(key : int) -> Callable:
    if key in _commands:
        return _commands[key]
    else:
        return func():
            print("this is default event commands.")


# @virtual
func _get_commands_list():
    return {}
