#PLAYER
extends KinematicBody2D

#THANKS THAT NEED TO BE DONE.
#1. FIGURE OUT HOW TO STOP THE COLLISION OF THE PROJECTILE AND THE PLAYER
#2. COOLDOWN

var player_id = 0
#PROJECTILE SPEED!!
var shoot_speed = 50000
var arrow = preload("Player1_projectile.tscn")

#PLAYER SPEED
export (int) var speed = 4

#TIMER START/ DELAY TIME/ BOOKING IF TIMER IS TRUE
var timer = null
var bullet_delay = 2
var can_shoot = true

#SET VECTOR
enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }
var velocity = Vector2()
slave var slave_position = Vector2()
slave var slave_movement = MoveDirection.NONE

#READY FUNCTION
func _ready():
	#A group name for organization
	add_to_group("player1")
	#TIMER/COOLDOWN
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(bullet_delay)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
	set_process(true)

#PLAYER PROCESS
func _physics_process(delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('ui_left'):
			$Ninja.play("RunLeft")
			direction = MoveDirection.LEFT
		elif Input.is_action_pressed('ui_right'):
			direction = MoveDirection.RIGHT
			$Ninja.play("RunRight")
		elif Input.is_action_pressed('ui_up'):
			$Ninja.play("RunUp")
			direction = MoveDirection.UP
		elif Input.is_action_pressed('ui_down'):
			$Ninja.play("RunDown")
			direction = MoveDirection.DOWN
		else: 
			slave_position = 0
			$Ninja.play("Idle")

		if Input.is_action_just_pressed('ui_select') && can_shoot:
			_shoot_arrow(delta)
			can_shoot = false
			#TIMER STARTS AT 2
			timer.start()
		
		rset_unreliable('slave_position', position)
		rset('slave_movement', direction)
		_move(direction)
	else:
		_move(slave_movement)
		position = slave_position
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)
		
#PROJECTILE BEING SHOT WITH SPACE BAR OR USER INPUT
	if Input.is_action_just_pressed('ui_select') && can_shoot:
		_shoot_arrow(delta)
		can_shoot = false
		#TIMER STARTS AT 2
		timer.start()


func _move(direction):
	match direction:
		MoveDirection.NONE:
			return
	if Input.is_action_pressed('ui_up'):
		$Ninja.play("RunUp")
		MoveDirection.UP
		move_and_collide(Vector2(0, -speed))
	if Input.is_action_pressed('ui_down'):
		$Ninja.play("RunDown")
		MoveDirection.DOWN
		move_and_collide(Vector2(0, speed))
	if Input.is_action_pressed('ui_left'):
		$Ninja.play("RunLeft")
		MoveDirection.LEFT
		move_and_collide(Vector2(-speed, 0))
	if Input.is_action_pressed('ui_right'):
		$Ninja.play("RunRight")
		MoveDirection.RIGHT
		move_and_collide(Vector2(speed, 0))


#TIMER OR COOLDOWN FOR PROJECTILE FUNCTION
func on_timeout_complete():
	can_shoot = true
	#TIMER ENDS AT 0


#NOTE: need to pass in delta from func _fixed_process or func _process
#NEW FULL PROJECTILE CODE
func _shoot_arrow(delta):
	if is_network_master():
		var new_arrow = arrow.instance()
		var arrow_rotation = get_angle_to(get_global_mouse_position()) + self.get_rotation()
		new_arrow.set_rotation(arrow_rotation)
		new_arrow.set_global_position(self.get_global_position())
		get_parent().add_child(new_arrow)
		var rigidbody_vector = (get_global_mouse_position() - self.get_position()).normalized()
		new_arrow.set_linear_velocity(rigidbody_vector * shoot_speed * delta)



func init(nickname, start_position, is_slave):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_slave:
		$Sprite.texture = load('res://Player.gd')
