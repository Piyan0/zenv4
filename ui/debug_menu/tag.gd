extends MarginContainer
signal tag_clicked(id)

@export var lb_id: Label
@export var btn: Button
var id:
    set(v):
        if !is_inside_tree():
            return
        id = v
        lb_id.text = v


func _ready():
    btn.button_down.connect(func():
        tag_clicked.emit(id)
    )
    
    
    

        
