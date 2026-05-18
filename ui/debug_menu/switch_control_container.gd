extends VBoxContainer


@export var arrow_nav: Control

func _ready() -> void:
    arrow_nav.page_changed.connect(func(page):
        print(page)    
    )
    arrow_nav.setup(0, 20)
