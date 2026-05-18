extends MarginContainer

signal tag_added(tag)
signal tag_removed(tag)

@export var op_tag: OptionButton
# @export var avaiable_tags = ["anjay", "mabar"]
# @export var avaiable_tags = ["anjay", "mabar"]
var avaiable_tags: Array[String] = [
    "Apple", "Apricot", "Avocado", "Banana", "Blackberry", 
    "Blueberry", "Boysenberry", "Breadfruit", "Cantaloupe", "Cherimoya", 
    "Cherry", "Clementine", "Coconut", "Cranberry", "Currant", 
    "Date", "Dragonfruit", "Durian", "Elderberry", "Fig", 
    "Gooseberry", "Grape", "Grapefruit", "Guava", "Honeydew", 
    "Jackfruit", "Jujube", "Kiwi", "Kumquat", "Lemon", 
    "Lime", "Longan", "Loquat", "Lychee", "Mandarin", 
    "Mango", "Mangosteen", "Melon", "Mulberry", "Nectarine", 
    "Orange", "Papaya", "Passionfruit", "Peach", "Pear", 
    "Persimmon", "Pineapple", "Plantain", "Plum", "Pomegranate", 
    "Pomelo", "Quince", "Raspberry", "Rambutan", "Redcurrant", 
    "Starfruit", "Strawberry", "Tamarind", "Tangerine", "Watermelon",
    "Yuzu", "Açai", "Bilberry", "Blackcurrant", "Blood Orange",
    "Buddha's Hand", "Canistel", "Cape Gooseberry", "Cashew Apple", "Chayote",
    "Chico Fruit", "Citron", "Cluster Fig", "Damson", "Feijoa",
    "Goji Berry", "Guanabana", "Honeyberry", "Jabuticaba", "Jambolan",
    "Kiwano", "Langsat", "Lanzones", "Mamey Sapote", "Marang",
    "Miracle Fruit", "Nance", "Ogallala Berry", "Olallieberry", "Olive",
    "Oregon Grape", "Pawpaw", "Phalsa", "Physalis", "Prickly Pear",
    "Pulasan", "Sapodilla", "Sea Buckthorn", "Soursop", "Sweetsop"
]

@export var tag_container: Control
@export var ph_tag: Node

var current_active_tags = []
var added_tags = []
func _ready():
    op_tag.clear()
    for tag in avaiable_tags:
        op_tag.add_item(tag)
    
    op_tag.item_selected.connect(func(id):
        var tag = op_tag.get_item_text(id)
        if tag in current_active_tags:
            return
        current_active_tags.append(tag)
        _sync_tags(current_active_tags)
        tag_added.emit(tag)
    )
    

func _sync_tags(p_tags):
    for tag_node in added_tags:
        tag_node.queue_free()
    added_tags.clear()
    
    for tag in p_tags:
        var ins = (ph_tag as InstancePlaceholder).create_instance()
        ins.id = tag
        ins.tag_clicked.connect(func(id):
            current_active_tags.erase(id)
            _sync_tags(current_active_tags)
            tag_removed.emit(id)
        )
        added_tags.append(ins)
    
