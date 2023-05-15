extends Spatial



var lockedMouse = true		#is mouse locked in window
var body					#KinematicBody node
var hitbox					#Body's Hitbox Shape
var head					#rotates camera & launcher in Y axis
var upd						#rotates camera & launcher in X axis
var firingpos				#position from which rocket is spawned
var rocket					#res://Scenes/Player/Rocket.tscn; used to instantiate rockets when firing
var recoilanim				#animation player used to play rocket recoil
var dialogue				#node used to send dialogue to the player

var dialoguequeue = []
var picturequeue = []

var config = ConfigFile.new()

var atkint = 0.8			#interval between rocket firing
var cooldown = 0			#internal tracker for rocket cooldown
var prvcrouch = false		#was the player crouching on the previous frame?
var chkpoint = Vector3(0,0,0)#last checkpoint position
var vel = Vector3(0,0,0)	#velocity
var gravity = 15.24			#gravity in m/s^2
var jumpv = 6				#initial velocity when player jumps
var movespeed = 4.7625		#how fast the player walks m/s
var accel = 2*movespeed		#how fast the player accelerates m/s^2
var radius					#hitbox radius
var npos					#standing position of hitbox
var cpos					#crouching position of hitbox
var nheight = 0.601			#standing height of hitbox
var cheight = 0.22015		#crouching height of hitbox
var mousesens				#mouse sensitivity

signal impart_force(force)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	body = get_node("KinematicBody")
	hitbox = body.get_node("CollisionHull")
	radius = hitbox.shape.radius
	npos = nheight/2+radius
	cpos = (nheight+2*radius)-(cheight+2*radius)/2
	head = body.get_node("Head")
	upd = head.get_node("UpDown")
	firingpos = upd.get_node("FiringPos")
	dialogue = upd.get_node("Camera/Dialogue")
	rocket = preload("res://Scenes/Player/Rocket.tscn")
	recoilanim = upd.get_node("Animation")
	config.load("user://config.cfg")
	mousesens = config.get_value("Player", "mousesens")


func fire():
	if(cooldown <= 0):
		var tmp = rocket.instance();
		tmp.global_transform = firingpos.global_transform;
		get_tree().get_root().add_child(tmp)
		cooldown = atkint
		recoilanim.play("recoil")
		body.get_node("ExplosionSound").play()
	pass


func _physics_process(delta):
	
	#GRAVITY AND COOLDOWN
	cooldown -= delta
	vel.y -= gravity*delta
	
	#WASD MOVEMENT
	var dir = (-Vector3(1 if Input.is_key_pressed(KEY_A) else 0, 0, 1 if Input.is_key_pressed(KEY_W) else 0).rotated(Vector3(0,1,0),head.rotation.y)
				+Vector3(1 if Input.is_key_pressed(KEY_D) else 0, 0, 1 if Input.is_key_pressed(KEY_S) else 0).rotated(Vector3(0,1,0),head.rotation.y))
	var keyspressed = (1 if Input.is_key_pressed(KEY_A) else 0)+(1 if Input.is_key_pressed(KEY_W) else 0)
	keyspressed += (1 if Input.is_key_pressed(KEY_D) else 0)+(1 if Input.is_key_pressed(KEY_S) else 0)
	
	if(dir.length()!=0):
		dir *= movespeed/dir.length()
	
	#MOVEMENT CALCULATIONS
	var tmp = vel
	tmp.y = 0
	if(body.is_on_floor()): #GROUND
		if tmp.length() > movespeed:
			tmp *= movespeed/tmp.length()
		else:
			tmp += (dir-tmp)*accel*delta
	elif dir.length()>0.01: #AIR
		var proj = dir.dot(tmp)
		
		if(proj < 0.05 && keyspressed < 3):
			tmp += dir*accel*delta*0.9
		else:
			tmp += dir*accel*delta*0.017
	
	vel.x = tmp.x
	vel.z = tmp.z
	
	#BEFORE WE MOVE, WE CHECK COLLISIONS
	var info = body.move_and_collide(vel*delta, true, true, true)
	if(info != null):
		handle(info.collider)
	#THEN WE CAN MOVE
	vel = body.move_and_slide(vel, Vector3(0, 1, 0), true, 4, min(0.785, 1 if tmp.length()<4 else 4/tmp.length()))
	
	#SHOOTING
	if Input.is_mouse_button_pressed(1):
		fire()
	
	#CROUCHING
	if (Input.is_key_pressed(KEY_SPACE)||Input.is_key_pressed(KEY_SHIFT)) != prvcrouch:
		prvcrouch = !prvcrouch
		if(prvcrouch):
			hitbox.shape.height = cheight
			hitbox.translation.y = cpos
		else:
			hitbox.shape.height = nheight
			hitbox.translation.y = npos
	
	#CONTROLLING DIALOGUE BOX
	dialogue.visible = dialoguequeue.size() > 0
	if(dialogue.visible):
		var tmplabel = dialogue.get_node("DB/Label")
		tmplabel.bbcode_text = dialoguequeue[0].bbcode_text
		tmplabel.visible_characters = tmplabel.visible_characters + 2
		var tmppic = dialogue.get_node("Pic")
		tmppic.texture = picturequeue[0].texture

func _input(event):
	#LOOKING
	if event is InputEventMouseMotion && lockedMouse:
		var movement = event.relative
		head.rotate_y(-movement.x/3600*mousesens)
		upd.rotate_x(-movement.y/3600*mousesens)
		upd.rotation.x = clamp(upd.rotation.x, -1.5707963267948966, 1.5707963267948966);
	if event is InputEventKey:
		#ESCAPING
		if(event.scancode == KEY_ESCAPE && event.pressed && !event.echo):
			lockedMouse = !lockedMouse
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if lockedMouse else Input.MOUSE_MODE_VISIBLE)
		if(event.scancode == KEY_BACKSPACE && event.pressed && !event.echo):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://Scenes/Menu/Main.tscn")
		#JUMPING
		if event.scancode == KEY_SPACE && event.pressed && !event.echo && lockedMouse && body.is_on_floor():
			vel.y += jumpv
		#NEXT DIALOGUE
		if event.scancode == KEY_E && event.pressed && !event.echo && lockedMouse && dialoguequeue.size() > 0 && picturequeue.size() > 0:
			dialoguequeue.pop_front()
			picturequeue.pop_front()
			dialogue.get_node("DB/Label").visible_characters = 0

func _on_Player_impart_force(force):
	vel += force

func handle(obj):
	if(obj.is_in_group("Checkpoint")):
		chkpoint = body.translation
	if(obj.is_in_group("Restarter")):
		body.translation = chkpoint
		vel *= 0
	if(obj.is_in_group("Dialogue")):
		obj.get_node("CollisionShape").queue_free()
		dialoguequeue = obj.get_node("Dialogue").get_children()
		picturequeue = obj.get_node("Pictures").get_children()
	if(obj.is_in_group("Teleporter")):
		vel *= 0
		body.global_translation = obj.get_node("Destination").global_translation
	if(obj.is_in_group("UnlockMap")):
		config.load("user://config.cfg")
		config.set_value("Unlocks", obj.get_child(0).name, true)
		config.save("user://config.cfg")

func _on_AreaScan_area_entered(area):
	handle(area)
func _on_AreaScan_body_entered(body):
	handle(body)
