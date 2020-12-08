extends KinematicBody2D

export var Acceleration = 700
export var MaxSpeed = 80
export var Friction = 600
export var roll_speed = 200
export var dash_speed = 160

enum {
	WALK,
	RUNNIN,
	ROLL,
	SLEEP,
	DEAD,
	ATTACK
}

var state = WALK
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var active = true
var stats = PlayerStats
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationOnState = animationTree.get("parameters/playback")
onready var SwordHitBox = $HitBoxPivot/SwordHitBox
onready var hurtBox = $HurtBox
onready var switchPlayer = $switchPlayer
onready var startMenu = get_tree().get_root().get_node("/root/StartMenu")
signal player1dead



func _ready():
	startMenu.connect("reloadgame",self,"reloadScene")
	animationTree.active = true
	SwordHitBox.knockback_vector=roll_vector
	
	
func _physics_process(delta):
	match state:
		WALK:
			move_state(delta)
		ROLL:
			roll_state(delta)
		SLEEP:
			sleep_state(delta)
		ATTACK:
			attack_state(delta)
		DEAD:
			dead_state()


func move_state(delta):
	
		var input_vector = Vector2.ZERO
		
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()
		
		if input_vector != Vector2.ZERO:
			roll_vector = input_vector
			SwordHitBox.knockback_vector = input_vector
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Walk/blend_position", input_vector)
			animationTree.set("parameters/Attack/blend_position", input_vector)
			animationTree.set("parameters/Roll/blend_position", input_vector)
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationTree.set("parameters/Sleep/blend_position", input_vector)
			animationOnState.travel("Walk")
			velocity = velocity.move_toward(input_vector * MaxSpeed, Acceleration * delta)
		else:
			animationOnState.travel("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
				
		move()   #||("ui_left")||("ui_up")||("ui_down"))
		if Input.is_action_pressed("Run")&& (Input.is_action_pressed("ui_right")||Input.is_action_pressed("ui_left")||Input.is_action_pressed("ui_up")||Input.is_action_pressed("ui_down")):
			MaxSpeed = dash_speed			
			animationOnState.travel("Run")
			
		
			
		if Input.is_action_just_released("Run"):
			MaxSpeed= 80
			
		if Input.is_action_just_pressed("Roll"):
			state = ROLL
		if Input.is_action_just_pressed("attack"):
			state = ATTACK
		if Input.is_action_just_pressed("sleep"):
			state = SLEEP
			
		if stats.health == 0:
			state = DEAD
			

func sleep_state(_delta):
	velocity= Vector2.ZERO
	animationOnState.travel("Sleep")
	if (Input.is_action_just_pressed("ui_right")||Input.is_action_just_pressed("ui_left")||Input.is_action_just_pressed("ui_up")||Input.is_action_just_pressed("ui_down")):
		state = WALK
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("Roll"):
		state = ROLL

func attack_state(_delta):
	velocity= Vector2.ZERO
	animationOnState.travel("Attack")
	
func roll_state(_delta):
	velocity= roll_vector * roll_speed
	animationOnState.travel("Roll")
	move()
	
func ROLLAnimationFinished():
	velocity = velocity * 0.8
	MaxSpeed = 80
	state=WALK

func attackAnimationFinished():
	MaxSpeed = 80
	state= WALK
	
func move():
	velocity = move_and_slide(velocity)	


func _on_HurtBox_area_entered(_area):
	stats.health -=1
	hurtBox.start_invicibility(0.5)
	hurtBox.create_hit_effect()

func dead_state():
	emit_signal("player1dead")
	#$Sprite.visible = false
	#set_collision_layer_bit(1,false)
	#set_collision_mask_bit(0,false)
	queue_free()
		
	

func reloadScene():
	get_tree().reload_current_scene()
