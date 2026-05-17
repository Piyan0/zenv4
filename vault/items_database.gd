class_name ItemsDatabase
extends Database

var _template_data = {
        "description": "no_desc",
        "icon_path" : "res://assets/chloe/items/item_keycard.png",
        "is_consumable" : false,
        "is_key_item" : true,
    }


func _title():
    return "inventory_items"
    

func _base_path():
    return "res://assets/items_icon/"
    

func _target_class():
    return Inventory.Item.new()


func _get_items():
    var items= []
    _get_test_items()

    return items

func _get_test_items():
   return {
    "test" : _template_data
   }
