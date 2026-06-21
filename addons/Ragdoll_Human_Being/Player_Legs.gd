extends RigidBody2D

@export var is_right_leg: bool = false
@export var lower_leg: RigidBody2D
@export var leg_speed_multiplier: float = 0.16 

var time: float = 0.0

func _physics_process(delta: float) -> void:
	var real_velocity = abs(linear_velocity.x)
	var direction := Input.get_axis("ui_left", "ui_right")
	var is_running := Input.is_key_pressed(KEY_SHIFT)
	
	# Detects crouching in the legs
	var is_crouching := Input.is_action_pressed("ui_down")
	
	var current_thigh_swing = 32.0 if is_running else (10.0 if is_crouching else 15.0)
	var current_knee_bend = 42.0 if is_running else (12.0 if is_crouching else 18.0)
	
	if direction != 0 and real_velocity > 10.0:
		time += delta * real_velocity * leg_speed_multiplier
		var phase_offset = PI if is_right_leg else 0.0
		
		# Normal movement while walking crouched
		var thigh_motion = cos(time + phase_offset) * current_thigh_swing * direction
		var knee_base = 30.0 if is_crouching else 0.0 # Keeps the knee half-bent while walking
		
		angular_velocity = thigh_motion
		if lower_leg:
			lower_leg.angular_velocity = (sin(time + phase_offset) + 1.0) * current_knee_bend * direction + knee_base
	else:
		# If IDLE and CROUCHING, forces static knee bending
		if is_crouching:
			time = move_toward(time, 0.0, 4.0 * delta)
			angular_velocity = move_toward(angular_velocity, 15.0, 15.0 * delta) # Leans the thigh
			if lower_leg:
				lower_leg.angular_velocity = move_toward(lower_leg.angular_velocity, 50.0, 20.0 * delta) # Bends the knee high
		else:
			# Normal standing position
			time = move_toward(time, 0.0, 4.0 * delta)
			angular_velocity = move_toward(angular_velocity, 0, 15.0 * delta)
			if lower_leg:
				lower_leg.angular_velocity = move_toward(lower_leg.angular_velocity, 0, 15.0 * delta)
