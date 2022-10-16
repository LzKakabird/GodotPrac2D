extends KinematicBody2D

#func _ready():
#	print("Hello World!")
#	pass
	
#when this node is added and ready, the ready func runs and print hello world
#可以查询
#子节点的ready会率先被触发

#create a var
var velocity = Vector2.ZERO
#这是一个x,y的位置，vector


enum {
	MOVE,
	ROLL,
	ATTACK
}#const with index(123)

var state = MOVE
#state machine


const MAX_SPEED = 50

const ACCELERATION = 120

const FRICTION = 250


#动画：
#var animationPlayer = null #这个初始化是因为var可能没加载出来
#当ready的时候：就是这个节点加载完成，可以用的时候
#用 onready var 可以直接替代 _ready()

#func _ready():
#	animationPlayer = $AnimationPlayer #$符号是用来方便的获取node(节点)的路径

onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
#animationNodeState???get access to 底下的东西

func _ready():
	animationTree.active = true
#一开始一ready就开始

func moveState(delta):
	#for input:
#	if Input.is_action_pressed("ui_right"):
#		velocity.x = 1
#	elif Input.is_action_pressed("ui_left"):
#		velocity.x = -1
#	elif Input.is_action_pressed("ui_down"):
#		velocity.y = 1
#	elif Input.is_action_pressed("ui_up"):
#		velocity.y = -1
#	else:   #we need to stop!!!!!!
#		velocity.x = 0
#		velocity.y = 0
	#上面的是不太好的方法？
	
	#新方法：
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()# 让斜向的统一速度（unit length），而不是根号2
	print(velocity)
	
	
	if input_vector != Vector2.ZERO:
		#不用加速度
		#velocity = input_vector * MAX_SPEED#真正的速度是velocity, input_velocity只是输入的，这样就不用else了，一个global, 一个local
		#set our velocity to the max speed
		
		#用accleration
		#velocity += input_vector * ACCELERATION#a is frame based, so set it to real world time
		
		#velocity += input_vector * ACCELERATION*delta #now based on time
		# = velocity.clamped(MAX_SPEED)
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION*delta)
		#前面是最大值，后面是增量
		
		#当运动的时候
		#if input_vector.x > 0:
		#	
		#	animationPlayer.play("RunRight")#动画名称
		#else:
		#	animationPlayer.play("RunLeft")
		
		animationTree.set("parameters/idle/blend_position", input_vector)#string内是blend position
		animationTree.set("parameters/run/blend_position", input_vector)
		animationTree.set("parameters/attack/blend_position", input_vector)
		
		animationState.travel("run")
		
	else:
		#velocity = Vector2.ZERO #这是外部变量！！！一定要 if else
		#加上friction
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		animationState.travel("idle")
		
		
	#这才让他动起来
	#move_and_collide(velocity * delta)#a magical func
	#这个可以不用写额外的collide func
	#但是遇到碰撞箱的时候不让你沿着墙滑
	
	#想要沿着墙滑行：
	velocity = move_and_slide(velocity)#不用×delta了；既运行，也返回值
	#让return的值成为新的velocity,便于之后使用？？？
	
	if Input.is_action_just_pressed("attack"): #按下了，按完了
		state = ATTACK

func attackState(delta):
	animationState.travel("attack")

func attackAnimationFinished():
	velocity = Vector2.ZERO
	state = MOVE
	#添加轨道：调用方法：切换state
	
func _physics_process(delta):#_代表回调函数call back func， 物理？每一帧都会运行？？？
	#print("hwlooworld! ")#每一帧都会运行一遍every tick
	#control可以查询，
	
	match state: #类似switch
		MOVE: 
			moveState(delta)
		
		ROLL: pass
		
		ATTACK: 
			attackState(delta)
	
	
	
	
	
