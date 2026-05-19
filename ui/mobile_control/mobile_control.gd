class_name MobileControl
extends CanvasLayer
signal on_hamburger_clicked()

@export var img_button_enable: Texture2D 
@export var img_button_disabled: Texture2D 
@export var btn_toggle_control: TouchScreenButton
@export var btn_hamburger: TouchScreenButton

@export var dpad_container: Node2D
@export var action_btn_contaienr: Node2D

var _is_control_enabled = true

func _ready():
    var x= ("anjay
    mabae (
        a, (anjay mabae )
    )
    ")
    print(x.strip_edges())
    btn_hamburger.pressed.connect(func():
        on_hamburger_clicked.emit()
        var player = Player.instance
        if !(get_tree().current_scene is Map) || Player.instance.lock_counter > 0:
            return

        print(Player.instance.lock_counter)
        if player != null:
            player.lock_counter += 1
        var inven = load("uid://c1148pqf8xuv8").instantiate()
        inven.items_id = Bootstrap.save_system.fields["items_id"]
        #print(inven.items_id)
        inven.inventory_closed.connect(func(items_used):
            if player:
                player.lock_counter -= 1
            for i in items_used:
                Bootstrap.save_system.fields["items_id"].erase(i)
        )
        Bootstrap.canvas.add_child(inven)
    )
    
    btn_toggle_control.pressed.connect(func():
        _is_control_enabled = !_is_control_enabled    
        if _is_control_enabled:
            dpad_container.show()
            action_btn_contaienr.show()
        else:
            dpad_container.hide()
            action_btn_contaienr.hide()
    )

static func spawn():
    var instance = load("uid://bxxlmvxb1njx0").instantiate()
    return instance
