extends Spatial

var vel = 20.955
var body
var ray
var expl = preload("res://Scenes/Player/Explosion.tscn")

func _ready():
	body = get_node("Body")
	ray = body.get_node("RayCast")
	ray.add_exception(get_tree().get_nodes_in_group("Player")[0])

func _physics_process(delta):
	body.translation.z += vel*delta
	ray.force_raycast_update()
	if(ray.is_colliding() && !ray.get_collider().is_in_group("Player")):
		queue_free()
		if(!ray.get_collider().is_in_group("Absorbant")):
			var point = ray.get_collision_point()
			var tmp = expl.instance()
			tmp.global_translation = point
			get_tree().get_root().add_child(tmp)
