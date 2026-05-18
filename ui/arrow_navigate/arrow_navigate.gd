extends Control

signal page_changed(page)

@export var btn_left: Button
@export var btn_right: Button
@export var lb_limit: Label
@export var ln_current_page: LineEdit

var _page_index = -1
var _total_page = 99

func _ready():

    btn_left.pressed.connect(func():
        _add_page(-1)
    )
    btn_right.pressed.connect(func():
        _add_page(1)
    )


func setup(current_page, total_page):
    _page_index = current_page
    _total_page = total_page 
    lb_limit.text = "/{0}".format([total_page - 1])
    _add_page(0)


func _add_page(by: int):
    _page_index = (_page_index + by + _total_page ) % ( _total_page )
    ln_current_page.text = str(_page_index)
    page_changed.emit(_page_index)