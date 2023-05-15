extends Area

func _on_CaveMap_body_entered(body):
	print(body.global_translation)
	print(global_translation)
	get_tree().change_scene("res://Scenes/Maps/Cave.tscn")
