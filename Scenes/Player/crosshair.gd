extends Camera

onready var fps = get_node("Control2/Label")
var lst = []
var tmp = 0

func _process(delta):
	lst.append(1.0/delta)
	tmp += 1.0/delta
	if(lst.size() > 30):
		tmp -= lst.front()
		lst.pop_front()
	if(delta > 0): fps.text = str(tmp/30)
