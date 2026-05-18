extends Node
signal on_page_changed()

var _max_item_per_page= 2
var _items: Array
var _item_index= 0
var _pages= []


func _init(p_owner, p_items, p_max_item_per_page):
    _items= p_items
    _max_item_per_page= p_max_item_per_page
    p_owner.add_child.call_deferred(self)


func update_page(idx):
    _item_index = idx
    _pages.clear()
    _pages.assign(_refresh_page(_items))
    var page= _get_page(idx)
    for i in _pages:
        for j: Control in i:
            j.hide()
    for i in _pages[page]:
        i.show()
    on_page_changed.emit()
    

func has_more_page_down():
    return _get_page(_item_index) < _pages.size() - 1


func has_more_page_up():
    return _get_page(_item_index) > 0


func _refresh_page(items):
    var current_page= []
    var pages= []
    var idx= 0
    for i in items:
        current_page.push_back(i)
        idx+= 1

        if idx== _max_item_per_page:
            pages.push_back(current_page)
            current_page= []
            idx= 0
        
    if !current_page.is_empty():
        pages.push_back(current_page)
    
    return pages


func _get_page(idx):
    return int(floor(idx/_max_item_per_page))
