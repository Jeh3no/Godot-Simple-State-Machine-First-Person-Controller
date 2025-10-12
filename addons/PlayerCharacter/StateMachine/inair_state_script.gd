extends State

class_name InairState

var stateName : String = "Inair"

var cR : CharacterBody3D

func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
func verifications():
	if cR.floor_snap_length != 0.0:  cR.floor_snap_length = 0.0
	if cR.hitGroundCooldown != cR.hitGroundCooldownRef: cR.hitGroundCooldown = cR.hitGroundCooldownRef
	
func physics_update(delta : float):
	applies(delta)
	
	cR.gravityApply(delta)
	
	inputManagement()
	
	checkIfFloor()
	
	move(delta)
	
func applies(delta : float):
	if !cR.is_on_floor(): 
		if cR.jumpCooldown > 0.0: cR.jumpCooldown -= delta
		if cR.coyoteJumpCooldown > 0.0: cR.coyoteJumpCooldown -= delta
		
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.baseHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.baseModelHeight, cR.heightChangeSpeed * delta)
		
func inputManagement():
	if Input.is_action_just_pressed(cR.jumpAction):
		#check if can jump buffer
		if cR.floorCheck.is_colliding() and cR.lastFramePosition.y > cR.position.y and cR.nbJumpsInAirAllowed <= 0: cR.jumpBuffOn = true
		#check if can coyote jump
		if cR.wasOnFloor and cR.coyoteJumpCooldown > 0.0 and cR.lastFramePosition.y > cR.position.y and cR.jumpCooldown < 0.0:
			cR.coyoteJumpOn = true
			transitioned.emit(self, "JumpState")
		if cR.jumpCooldown < 0.0:
			transitioned.emit(self, "JumpState")
		
	if Input.is_action_just_pressed(cR.dashAction):
		if cR.timeBefCanDashAgain <= 0.0 and cR.nbDashAllowed > 0:
			transitioned.emit(self, "DashState")
		
	if Input.is_action_just_pressed(cR.flyAction):
		transitioned.emit(self, "FlyState")
		
	if Input.is_action_just_pressed(cR.slideAction):
		if cR.slideFloorCheck.is_colliding() and  cR.lastFramePosition.y > cR.position.y and  cR.timeBefCanSlideAgain <= 0.0:
			cR.slideBuffOn = true
			
func checkIfFloor():
	if cR.is_on_floor():
		if cR.jumpBuffOn: 
			cR.bufferedJump = true
			cR.jumpBuffOn = false
			transitioned.emit(self, "JumpState")
		if cR.slideBuffOn:
			cR.slideBuffOn = false
			transitioned.emit(self, "SlideState") 
		else:
			if cR.moveDirection: transitioned.emit(self, cR.walkOrRun)
			else: transitioned.emit(self, "IdleState")
			
	if cR.is_on_wall():
		cR.velocity.x = 0.0
		cR.velocity.z = 0.0
		
func move(delta : float):
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	cR.moveDirection = (cR.camHolder.global_basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y)).normalized()
	
	if !cR.is_on_floor():
		if cR.moveDirection:
			if cR.desiredMoveSpeed < cR.maxSpeed: cR.desiredMoveSpeed += cR.bunnyHopDmsIncre * delta
			
			var contrdDesMoveSpeed : float = cR.desiredMoveSpeedCurve.sample(cR.desiredMoveSpeed)
			var contrdInAirMoveSpeed : float = cR.inAirMoveSpeedCurve.sample(cR.desiredMoveSpeed) * cR.inAirInputMultiplier
			
			cR.velocity.x = lerp(cR.velocity.x, cR.moveDirection.x * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
			cR.velocity.z = lerp(cR.velocity.z, cR.moveDirection.z * contrdDesMoveSpeed, contrdInAirMoveSpeed * delta)
			
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
	
