class_name GroupControl
extends Node

var items = []
var max_per_group = 3
var parent: Control:
    set(value):
        parent = value
        self.name = "GroupControl"
        parent.add_child.call_deferred(self)
        
var container = func(): return VBoxContainer.new()
var _added_group = []
    
func group():
    var temp_items = items.duplicate()  
    var page = -1
    while true:  
        page += 1
        var item_to_add = []
        for i in range(0, max_per_group):
            var item = temp_items.pop_front()
            if item != null:
                item_to_add.append(item)
        
        var ct = container.call()
        ct.name = str(page)
        for item in item_to_add:
            ct.reparent(item)
        parent.add_child(ct)
        
        if temp_items.is_empty():
            break
        
        
