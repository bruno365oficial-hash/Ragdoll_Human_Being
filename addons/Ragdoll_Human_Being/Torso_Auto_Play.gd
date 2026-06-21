extends RigidBody2D

@export var balance_power: float = 40.0
@export var standing_height: float = 90.0
@export var stand_force: float = 600.0

@export var walk_speed: float = 40.0
@export var run_speed: float = 60.0

@onready var raycast: RayCast2D = $RayCast2D

func _physics_process(delta: float) -> void:
	var is_up_pressed := Input.is_action_pressed("ui_up")
	
	# Gravity control (Turn off gravity when flying)
	if is_up_pressed:
		gravity_scale = 0.0 

		if get_parent():
			for member in get_parent().get_children():
				if member is RigidBody2D:
					member.gravity_scale = 0.0
	else:
		gravity_scale = 1.0 
		
		if get_parent():
			for member in get_parent().get_children():
				if member is RigidBody2D:
					member.gravity_scale = 1.0

	# Movement control: Stops walking (0.0) if flying, otherwise walks right (1.0)
	var direction := 0.0 if is_up_pressed else 1.0
	
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	
	var target_speed = run_speed if is_running else walk_speed
	var force_multiplier = 1.8 if is_running else 1.0
	
	# 1. BALANCE MUSCLE
	var target_angle = 0.0
	if direction != 0:
		target_angle = direction * (0.4 if is_running else 0.12)
		
	var angle_error = target_angle - rotation
	angle_error = wrapf(angle_error, -PI, PI)

	angular_velocity = angle_error * (balance_power * force_multiplier)
	
	# 2. VERTICAL AND HORIZONTAL MUSCLES
	if raycast.is_colliding():
		var distance = global_position.distance_to(raycast.get_collision_point())
		
		if distance < standing_height:
			var proportional_push = (standing_height - distance) * stand_force
			apply_central_force(Vector2.UP * proportional_push)
			
		# MOVEMENT MOTOR
		if direction != 0:
			linear_velocity.x = move_toward(linear_velocity.x, direction * target_speed, 600.0 * delta)
		else:
			linear_velocity.x = move_toward(linear_velocity.x, 0, 600.0 * delta)
