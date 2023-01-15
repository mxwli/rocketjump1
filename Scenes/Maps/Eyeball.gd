extends CSGCombiner

var iypos
var time

func _ready():
	iypos = translation.y
	var tmp = RandomNumberGenerator.new()
	tmp.randomize()
	time = tmp.randf()*6

func _physics_process(delta):
	var lookloc = get_tree().get_nodes_in_group("Player")[0].global_translation - global_translation
	lookloc /= lookloc.length()
	var bx = lookloc.cross(Vector3(0,1,0))
	if(bx.length()<0.001): bx = Vector3(1,0,0)
	bx /= bx.length()
	var by = lookloc.cross(bx)
	if(by.length()<0.001): by = Vector3(0,1,0)
	by /= by.length()
	transform.basis = Basis(bx,by,lookloc)
	
	time += delta
	translation.y = iypos + sin(time)
