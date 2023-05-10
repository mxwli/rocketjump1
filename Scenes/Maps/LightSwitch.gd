extends Room

onready var lights = get_node("OmniLight")
onready var negative = get_node("NegativeLight")
var switched = false
var att = 10

func _ready():
	lights.visible = false
	negative.visible = true


func _on_Tripwire_area_entered(area):
	lights.visible = true
	negative.visible = false
	get_node("LightClick").play()
	get_node("Tripwire").queue_free()
	switched = true

func _process(delta):
	lights.omni_attenuation = att
	if(switched):
		att = max(1, att-10*delta)
