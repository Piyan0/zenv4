class_name AssetLoader

var _assets= {}
var _preloaded_asset = {}

# TODO add convention for dir asset we dont have to add it to dict, so asset get based on folder structure, maybe add an alias.
func _init():
    pass



func get_asset(id):
    assert(id in _assets, id)
    return load(_assets[id])


func has_asset(id):
    return id in _assets


func get_keys(prefix = ""):
    var keys = _assets.keys()
    return keys.filter(func(text: String):
        return text.begins_with(prefix)
    )
    

func get_asset_data():
    return _assets
