extends GridContainer

var config = ConfigFile.new()
onready var senslabel = get_node("senslabel")
onready var sensslider = get_node("sensslider")


func _ready():
	#sens settings
	config.load("user://config.cfg")
	if(config.get_value("Player", "mousesens") == null):
		config.set_value("Player", "mousesens", 3)
		config.save("user://config.cfg")
	senslabel.text = "sensitivity: " + str(config.get_value("Player", "mousesens"))
	sensslider.value = config.get_value("Player", "mousesens")
	
	#saves
	config.set_value("Unlocks", "Tutorial", true)
	for node in get_node("GridContainer").get_children():
		if(config.get_value("Unlocks", node.name) == null):
			config.set_value("Unlocks", node.name, false)
	config.save("user://config.cfg")
	
	#load save states
	for key in config.get_section_keys("Unlocks"):
		if(get_node("GridContainer").get_node(key) != null):
			get_node("GridContainer").get_node(key).visible = config.get_value("Unlocks", key)


func _on_Tutorial_pressed():
	get_tree().change_scene("res://Scenes/Maps/Tutorial.tscn")


func _on_StrafeTut_pressed():
	get_tree().change_scene("res://Scenes/Maps/StrafeTut.tscn")


func _on_Walls_pressed():
	get_tree().change_scene("res://Scenes/Maps/Walls.tscn")


func _on_Bsc1_pressed():
	get_tree().change_scene("res://Scenes/Maps/BasicCourse.tscn")


func _on_Playground_pressed():
	get_tree().change_scene("res://Scenes/Maps/Playground.tscn")


func _on_Secret_Cheese_pressed():
	get_tree().change_scene("res://Scenes/Maps/SecretCheese.tscn")


func _on_Caves_pressed():
	get_tree().change_scene("res://Scenes/Maps/Cave.tscn")

func _on_Playground2_pressed():
	get_tree().change_scene("res://Scenes/Maps/Playground2.tscn")


func _on_sensslider_value_changed(value):
	config.set_value("Player", "mousesens", value)
	senslabel.text = "sensitivity: " + str(value)


func _on_save_pressed():
	config.save("user://config.cfg")


func _on_ClearData_pressed():
	get_parent().get_parent().get_node("ConfirmationDialog").visible = true


func _on_ConfirmationDialog_confirmed():
	config.clear()
	config.save("user://config.cfg")
	_ready()

