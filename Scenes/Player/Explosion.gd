extends Spatial

var particles
var hitbox
var time

var initiated = false

func _ready():
	particles = get_node("Particles")
	particles.emitting = true
	hitbox = get_node("Area")
	time = 0
	get_node("Sound").play()

func _process(delta):
	time += delta
	if(time > 3):
		queue_free()
	if(time > 2*delta):
		initiated = true;

func _on_Area_body_entered(body):
	var player = get_tree().get_nodes_in_group("Player")[0]
	if(body == player && !initiated):
		initiated = true
		var pheight = player.get_node("CollisionHull").shape.height
		var prad = player.get_node("CollisionHull").shape.radius
		var distance = min((player.get_node("CollisionHull").global_translation
							-Vector3(0,pheight/2+prad,0)
							-global_translation).length(),
							(player.get_node("CollisionHull").global_translation-global_translation).length()); #
		var damage = 90*(1-0.5*clamp(distance/2.305,0,1))
		var direction = player.get_node("CollisionHull").global_translation+Vector3(0, 0.19, 0)-global_translation
		direction /= direction.length()
		var scale = 82/55 * 5 * (1 if player.is_on_floor() else 2)
		player.get_parent().emit_signal("impart_force", direction*scale*damage*1.905/100)
