class_name DialoguePortraitData


func get_data():
    return _get_portrait_data()
    
    
func _get_portrait_data():
    var data = {}
    data["id"] = {
        "name" : "name",
        "img_id" : "img_id"
    }
    return data
    
    