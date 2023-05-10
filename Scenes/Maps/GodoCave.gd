extends Area

func _on_CaveMap_body_entered(body):
	get_tree().change_scene("res://Scenes/Maps/Cave.tscn")
